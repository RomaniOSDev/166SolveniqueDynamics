import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    private let store: AppDataStore

    init(store: AppDataStore) {
        self.store = store
    }

    var termOfTheDay: LegalTerm? {
        LegalGlossary.termOfTheDay(enabledPacks: store.enabledPackIds)
    }

    var recentTerms: [LegalTerm] {
        store.searchedTerms.prefix(8).compactMap {
            LegalGlossary.term(named: $0, enabledPacks: store.enabledPackIds)
        }
    }

    var favoriteCount: Int { store.favoriteTerms.count }
    var streakDays: Int { store.streakDays }
    var termsExplored: Int { store.itemsCreated }
    var dailyProgress: Double { store.dailyGoalProgress }
    var dailyCount: Int { store.dailyGoalCount }
    var hasCompare: Bool { !store.compareTermNames.isEmpty }

    var activityToday: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: Date())
        return store.dailyActivityCounts[key] ?? 0
    }

    var dueReviewCount: Int { store.dueReviewCount }

    var caseStudyOfTheDay: CaseStudy? {
        LearningContent.caseStudyOfTheDay(enabledPacks: store.enabledPackIds)
    }

    var weakTermCount: Int {
        LearningEngine.weakTermNames(store: store).count
    }
}
