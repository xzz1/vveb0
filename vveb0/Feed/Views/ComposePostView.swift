import SwiftUI

struct ComposePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""

    let onPublish: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .frame(minHeight: 220)

                Text("支持文本发布，后续可以接入图片/投票/话题。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(16)
            .navigationTitle("发微博")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("发送") {
                        onPublish(text)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
