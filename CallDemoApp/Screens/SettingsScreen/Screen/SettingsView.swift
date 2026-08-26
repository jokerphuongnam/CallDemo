import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SettingsViewModel
    @State private var showsCurrentUserIDPreview: Bool
    @State private var showsPartnerUserIDPreview: Bool

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        showsCurrentUserIDPreview = viewModel.canSave
        showsPartnerUserIDPreview = !viewModel.partnerSignalingIDPreview.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Call identity") {
                    TextField("Current user ID", text: $viewModel.currentUserID)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if showsCurrentUserIDPreview {
                        signalingIDContent(viewModel.signalingUserIDPreview)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }

                Section("Outgoing partner") {
                    TextField("Partner user ID", text: $viewModel.partnerUserID)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if showsPartnerUserIDPreview {
                        signalingIDContent(viewModel.partnerSignalingIDPreview)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
        .presentationDetents([.medium])
        .onChange(of: viewModel.canSave) { _, canSave in
            withAnimation(.smooth) {
                showsCurrentUserIDPreview = canSave
            }
        }
        .onChange(of: viewModel.partnerSignalingIDPreview.isEmpty) { _, isEmpty in
            withAnimation(.smooth) {
                showsPartnerUserIDPreview = !isEmpty
            }
        }
    }

    private func signalingIDContent(_ id: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ID gửi lên")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(id)
                .font(.body.monospaced())
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
