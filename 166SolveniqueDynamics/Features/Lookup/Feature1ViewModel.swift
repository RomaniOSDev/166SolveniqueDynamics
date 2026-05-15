import Combine
import Foundation

@MainActor
final class Feature1ViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [LegalTerm] = []
    @Published var showRecent = false
    @Published var showFavorites = false
    @Published var validationError: String?
    @Published var shakeTrigger = 0
    @Published var selectedTerm: LegalTerm?
    @Published var pulseTermID: String?
    @Published var fieldFilter: SearchFieldFilter = .all
    @Published var sortOption: SearchSortOption = .alphabetical
    @Published var categoryFilter: LegalTermCategory?

    private let store: AppDataStore
    private var cancellables = Set<AnyCancellable>()

    init(store: AppDataStore) {
        self.store = store
        Publishers.CombineLatest4($searchText, $fieldFilter, $sortOption, $categoryFilter)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] text, field, sort, category in
                self?.performSearch(text, field: field, sort: sort, category: category)
            }
            .store(in: &cancellables)

        store.$enabledPackIds
            .sink { [weak self] _ in
                guard let self else { return }
                self.performSearch(self.searchText, field: self.fieldFilter, sort: self.sortOption, category: self.categoryFilter)
            }
            .store(in: &cancellables)
    }

    var termOfTheDay: LegalTerm? {
        LegalGlossary.termOfTheDay(enabledPacks: store.enabledPackIds)
    }

    var displayTerms: [LegalTerm] {
        if showFavorites {
            return store.favoriteTerms.compactMap { LegalGlossary.term(named: $0, enabledPacks: store.enabledPackIds) }
        }
        if showRecent {
            return store.searchedTerms.compactMap { LegalGlossary.term(named: $0, enabledPacks: store.enabledPackIds) }
        }
        return results
    }

    var isEmptyState: Bool {
        displayTerms.isEmpty && searchText.isEmpty && !showRecent && !showFavorites
    }

    func performSearch(
        _ query: String,
        field: SearchFieldFilter? = nil,
        sort: SearchSortOption? = nil,
        category: LegalTermCategory? = nil
    ) {
        validationError = nil
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let field = field ?? fieldFilter
        let sort = sort ?? sortOption
        let category = category ?? categoryFilter

        if trimmed.isEmpty && category == nil {
            results = []
            return
        }

        results = LegalGlossary.search(
            query: trimmed,
            field: field,
            sort: sort,
            viewCounts: store.termViewCounts,
            category: category,
            enabledPacks: store.enabledPackIds
        )

        if !trimmed.isEmpty && results.isEmpty {
            validationError = "No matching legal term found."
            shakeTrigger += 1
            FeedbackManager.warning()
        }
    }

    func selectTerm(_ term: LegalTerm) {
        selectedTerm = term
        FeedbackManager.definitionViewed()
        pulseTermID = term.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.pulseTermID = nil
        }
    }

    func toggleFavorite(_ term: LegalTerm) {
        store.toggleFavorite(term.name)
        FeedbackManager.success()
    }
}
