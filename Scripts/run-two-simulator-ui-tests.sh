#!/bin/zsh

set -u
set -o pipefail

project_root="${0:A:h:h}"
artifacts_root="$project_root/.ui-test-artifacts/$(date +%Y%m%d-%H%M%S)"
derived_data="$artifacts_root/DerivedData"

developer_dir="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
simulator_os="${SIMULATOR_OS:-26.5}"

destination_for() {
  local device_name="$1"
  local booted_line
  local udid

  booted_line=$(DEVELOPER_DIR="$developer_dir" xcrun simctl list devices booted | \
    awk -v name="$device_name" 'index($0, "    " name " (") == 1 && /\(Booted\)/ { print; exit }')

  if [[ -n "$booted_line" ]]; then
    udid=$(echo "$booted_line" | sed -E 's/.*\(([0-9A-F-]+)\) \(Booted\).*/\1/')
    echo "platform=iOS Simulator,id=$udid"
    return
  fi

  echo "platform=iOS Simulator,name=$device_name,OS=$simulator_os"
}

caller_destination="${CALLER_DESTINATION:-$(destination_for "iPhone 17 Pro")}"
callee_destination="${CALLEE_DESTINATION:-$(destination_for "iPhone 17 Pro Max")}"

mkdir -p "$artifacts_root"

echo "Building UI tests..."
DEVELOPER_DIR="$developer_dir" xcodebuild \
  -project "$project_root/CallDemoApp.xcodeproj" \
  -scheme CallDemoApp \
  -destination "$caller_destination" \
  -derivedDataPath "$derived_data" \
  CODE_SIGNING_ALLOWED=NO \
  build-for-testing

xctestrun_source=("$derived_data"/Build/Products/*.xctestrun)
caller_xctestrun="$derived_data/Build/Products/Caller.xctestrun"
callee_xctestrun="$derived_data/Build/Products/Receiver.xctestrun"
cp "$xctestrun_source[1]" "$caller_xctestrun"
cp "$xctestrun_source[1]" "$callee_xctestrun"

if [[ -n "${CALLER_CURRENT_USER_ID:-}" ]]; then
  plutil -insert CallDemoAppUITests.EnvironmentVariables.CALL_DEMO_CURRENT_USER_ID \
    -string "$CALLER_CURRENT_USER_ID" "$caller_xctestrun"
fi

if [[ -n "${CALLER_PARTNER_USER_ID:-}" ]]; then
  plutil -insert CallDemoAppUITests.EnvironmentVariables.CALL_DEMO_PARTNER_USER_ID \
    -string "$CALLER_PARTNER_USER_ID" "$caller_xctestrun"
fi

if [[ -n "${CALLEE_CURRENT_USER_ID:-}" ]]; then
  plutil -insert CallDemoAppUITests.EnvironmentVariables.CALL_DEMO_CURRENT_USER_ID \
    -string "$CALLEE_CURRENT_USER_ID" "$callee_xctestrun"
fi

if [[ -n "${CALLEE_PARTNER_USER_ID:-}" ]]; then
  plutil -insert CallDemoAppUITests.EnvironmentVariables.CALL_DEMO_PARTNER_USER_ID \
    -string "$CALLEE_PARTNER_USER_ID" "$callee_xctestrun"
fi

echo "Starting Receiver first on: $callee_destination"
DEVELOPER_DIR="$developer_dir" xcodebuild \
  -xctestrun "$callee_xctestrun" \
  -destination "$callee_destination" \
  -resultBundlePath "$artifacts_root/Receiver.xcresult" \
  -only-testing:CallDemoAppUITests/CallDemoAppUITests/testTapReceiveCallIfAvailable \
  test-without-building > "$artifacts_root/receiver.log" 2>&1
callee_status=$?

echo "Starting Caller after Receiver on: $caller_destination"
DEVELOPER_DIR="$developer_dir" xcodebuild \
  -xctestrun "$caller_xctestrun" \
  -destination "$caller_destination" \
  -resultBundlePath "$artifacts_root/Caller.xcresult" \
  -only-testing:CallDemoAppUITests/CallDemoAppUITests/testTapCallIfAvailable \
  test-without-building > "$artifacts_root/caller.log" 2>&1
caller_status=$?

echo "Caller log: $artifacts_root/caller.log"
echo "Receiver log: $artifacts_root/receiver.log"

if (( caller_status != 0 )); then
  echo "Caller test failed with status $caller_status"
fi

if (( callee_status != 0 )); then
  echo "Receiver test failed with status $callee_status"
fi

if (( caller_status != 0 || callee_status != 0 )); then
  exit 1
fi

echo "Receiver ran first, then Caller. Both apps remain available for manual interaction."
