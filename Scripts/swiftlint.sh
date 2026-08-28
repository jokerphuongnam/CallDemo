#!/bin/sh

set -eu

script_directory="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_root="${SRCROOT:-$(dirname -- "$script_directory")}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

if command -v swiftlint >/dev/null 2>&1; then
    swiftlint_path="$(command -v swiftlint)"
elif [ -x /opt/homebrew/bin/swiftlint ]; then
    swiftlint_path="/opt/homebrew/bin/swiftlint"
elif [ -x /usr/local/bin/swiftlint ]; then
    swiftlint_path="/usr/local/bin/swiftlint"
else
    echo "error: SwiftLint is not installed. Run: brew install swiftlint"
    exit 1
fi

for lint_path in \
    "$project_root/CallDemoApp" \
    "$project_root/CallDemoAppTests" \
    "$project_root/CallDemoAppUITests"; do
    "$swiftlint_path" lint \
        --config "$project_root/.swiftlint.yml" \
        --no-cache \
        --strict \
        "$lint_path"
done
