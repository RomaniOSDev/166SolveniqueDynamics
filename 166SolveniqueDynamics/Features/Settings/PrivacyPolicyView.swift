import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdown = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    if markdown.isEmpty {
                        ProgressView()
                            .tint(Color.appPrimary)
                            .padding(.top, 40)
                    } else {
                        policyText
                            .padding(16)
                    }
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color.appPrimary)
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .onAppear { loadPolicy() }
        }
    }

    @ViewBuilder
    private var policyText: some View {
        if let attributed = try? AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        ) {
            Text(attributed)
                .foregroundStyle(Color.appTextPrimary)
                .tint(Color.appPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text(markdown)
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func loadPolicy() {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            markdown = "# Privacy Policy\n\nContent unavailable."
            return
        }
        markdown = text
    }
}
