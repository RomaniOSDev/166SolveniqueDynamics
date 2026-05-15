import SwiftUI

struct BrowseByCategoryView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedCategory: LegalTermCategory?

    var body: some View {
        ZStack {
            AppBackgroundView()
            if let category = selectedCategory {
                termList(for: category)
            } else {
                categoryGrid
            }
        }
        .navigationTitle(selectedCategory?.displayName ?? "Browse by Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            if selectedCategory != nil {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        FeedbackManager.lightTap()
                        selectedCategory = nil
                    } label: {
                        Label("Categories", systemImage: "chevron.left")
                            .foregroundStyle(Color.appPrimary)
                    }
                }
            }
        }
    }

    private var categoryGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeaderView(
                    title: "Legal Categories",
                    subtitle: "Explore terms organized by practice area",
                    icon: "square.grid.2x2.fill"
                )
                .padding(.horizontal, 16)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(LegalTermCategory.allCases) { category in
                        Button {
                            FeedbackManager.lightTap()
                            selectedCategory = category
                        } label: {
                            CategoryCardCell(
                                category: category,
                                termCount: LegalGlossary.terms(in: category, enabledPacks: store.enabledPackIds).count
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
    }

    private func termList(for category: LegalTermCategory) -> some View {
        let terms = LegalGlossary.terms(in: category, enabledPacks: store.enabledPackIds)
        return Group {
            if terms.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No Terms",
                    message: "Enable more term packs to see terms in this category."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(terms) { term in
                            NavigationLink {
                                TermDetailView(term: term)
                            } label: {
                                TermCardCell(
                                    term: term,
                                    viewCount: store.termViewCounts[term.name],
                                    isFavorite: store.isFavorite(term.name)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}
