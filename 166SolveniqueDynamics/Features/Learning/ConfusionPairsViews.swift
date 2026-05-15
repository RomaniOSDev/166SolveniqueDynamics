import SwiftUI

struct ConfusionPairsListView: View {
    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                LazyVStack(spacing: 12) {
                    SectionHeaderView(
                        title: "Don't Confuse",
                        subtitle: "Side-by-side differences for commonly mixed-up terms",
                        icon: "arrow.left.arrow.right"
                    )
                    ForEach(LearningContent.confusionPairs) { pair in
                        NavigationLink {
                            ConfusionPairDetailView(pair: pair)
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("\(pair.termA) vs \(pair.termB)")
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)
                                    Text(pair.summary)
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .lineLimit(2)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.appPrimary)
                            }
                            .appListCard()
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded { FeedbackManager.lightTap() })
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Don't Confuse")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct ConfusionPairDetailView: View {
    @EnvironmentObject private var store: AppDataStore
    let pair: ConfusionPair

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(pair.summary)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .appCard(elevation: .raised)

                    comparisonTable

                    termLinks
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var comparisonTable: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Aspect")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(pair.termA)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(pair.termB)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appAccent)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color.appBackground.opacity(0.4))

            ForEach(pair.rows, id: \.self) { row in
                Divider().overlay(Color.white.opacity(0.08))
                HStack(alignment: .top, spacing: 8) {
                    Text(row.aspect)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.termA)
                        .font(.caption)
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.termB)
                        .font(.caption)
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(12)
            }
        }
        .appCard(padding: 0, elevation: .raised)
    }

    private var termLinks: some View {
        VStack(spacing: 10) {
            termLink(pair.termA)
            termLink(pair.termB)
            Button {
                FeedbackManager.lightTap()
                if !store.isInCompare(pair.termA) { _ = store.toggleCompare(pair.termA) }
                if !store.isInCompare(pair.termB) { _ = store.toggleCompare(pair.termB) }
            } label: {
                ActionRowCell(title: "Add Both to Compare", icon: "rectangle.split.2x1")
            }
            .buttonStyle(.plain)
        }
        .appCard(padding: 0, elevation: .raised)
    }

    @ViewBuilder
    private func termLink(_ name: String) -> some View {
        if let term = LegalGlossary.term(named: name, enabledPacks: store.enabledPackIds) {
            NavigationLink {
                TermDetailView(term: term)
            } label: {
                ActionRowCell(title: name, icon: term.category.iconName, trailingIcon: "arrow.right")
            }
            .buttonStyle(.plain)
        }
    }
}
