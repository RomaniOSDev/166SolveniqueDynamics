import SwiftUI

struct FavoritesNotesView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var shareText: ShareableText?

    var body: some View {
        Group {
            if store.favoriteTerms.isEmpty {
                ScrollView {
                    EmptyStateView(
                        icon: "star",
                        title: "No Favorites Yet",
                        message: "Star terms and add personal notes for quick reference during study."
                    )
                    .padding(16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        favoritesHeader
                        ForEach(store.favoriteTerms, id: \.self) { name in
                            if let term = LegalGlossary.term(named: name, enabledPacks: store.enabledPackIds) {
                                FavoriteNoteCell(
                                    term: term,
                                    note: noteBinding(for: name)
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(item: $shareText) { ShareSheet(items: [$0.text]) }
    }

    private var favoritesHeader: some View {
        HStack {
            SectionHeaderView(title: "Favorites", subtitle: "Notes & starred terms", icon: "star.fill")
            Spacer()
            Button {
                shareText = ShareableText(text: ExportService.favoritesList(store: store))
                FeedbackManager.lightTap()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
    }

    private func noteBinding(for name: String) -> Binding<String> {
        Binding(
            get: { store.note(for: name) },
            set: { store.setNote($0, for: name) }
        )
    }
}
