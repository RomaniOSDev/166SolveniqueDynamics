import Combine
import Foundation

@MainActor
final class Feature2ViewModel: ObservableObject {
    @Published var expandedTerms: Set<String> = []
    @Published var showClearAlert = false
    @Published var pulseTermID: String?

    private let store: AppDataStore

    init(store: AppDataStore) {
        self.store = store
    }

    var historyItems: [(name: String, term: LegalTerm?, accessed: Date?)] {
        store.viewedTerms.map { name in
            (
                name: name,
                term: LegalGlossary.term(named: name, enabledPacks: store.enabledPackIds),
                accessed: store.termAccessDates[name]
            )
        }
    }

    var isEmpty: Bool { store.viewedTerms.isEmpty }

    func toggleExpanded(_ name: String) {
        if expandedTerms.contains(name) {
            expandedTerms.remove(name)
        } else {
            expandedTerms.insert(name)
        }
        FeedbackManager.lightTap()
    }

    func delete(_ name: String) {
        store.removeFromHistory(name)
        expandedTerms.remove(name)
        FeedbackManager.historyAction()
        pulseTermID = name
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.pulseTermID = nil
        }
    }

    func toggleFavorite(_ name: String) {
        store.toggleFavorite(name)
        FeedbackManager.historyAction()
    }

    func clearHistory() {
        store.clearHistory()
        expandedTerms = []
        let unlocked = store.checkAchievements()
        if !unlocked.isEmpty {
            FeedbackManager.success()
        }
    }
}
