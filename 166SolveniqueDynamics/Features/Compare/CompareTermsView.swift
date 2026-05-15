import SwiftUI

struct CompareTermsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var shareText: ShareableText?

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    if store.compareTerms.isEmpty {
                        EmptyStateView(
                            icon: "rectangle.split.2x1",
                            title: "Compare Terms",
                            message: "Add up to 3 terms from any definition screen to compare side by side."
                        )
                    } else {
                        SectionHeaderView(
                            title: "Side-by-Side",
                            subtitle: "\(store.compareTerms.count) of \(AppDataStore.maxCompareTerms) selected",
                            icon: "rectangle.split.2x1"
                        )
                        ForEach(store.compareTerms) { term in
                            compareCard(term)
                        }
                        actionButtons
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(item: $shareText) { ShareSheet(items: [$0.text]) }
    }

    private func compareCard(_ term: LegalTerm) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconBadge(systemName: term.category.iconName, size: 44)
                Text(term.name)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Button {
                    _ = store.toggleCompare(term.name)
                    FeedbackManager.lightTap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.appTextSecondary)
                }
                .frame(width: 44, height: 44)
            }
            Text(term.briefDefinition)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appAccent)
            Text(term.fullDefinition)
                .font(.caption)
                .foregroundStyle(Color.appTextPrimary)
        }
        .appCard(elevation: .raised)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                shareText = ShareableText(text: ExportService.compareList(terms: store.compareTerms))
                FeedbackManager.lightTap()
            } label: {
                Text("Share Comparison")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button {
                store.clearCompare()
                FeedbackManager.mediumTap()
            } label: {
                Text("Clear Selection")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .frame(minHeight: 44)
        }
    }
}
