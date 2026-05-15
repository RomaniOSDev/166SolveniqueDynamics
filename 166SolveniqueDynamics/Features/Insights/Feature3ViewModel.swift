import Combine
import Foundation

@MainActor
final class Feature3ViewModel: ObservableObject {
    @Published var period: InsightPeriod = .weekly
    @Published var pulseRowID: String?

    private let store: AppDataStore

    init(store: AppDataStore) {
        self.store = store
    }

    var insights: [(term: String, count: Int)] {
        store.insights(for: period)
    }

    var isEmpty: Bool { insights.isEmpty }

    func refresh() {
        store.refreshInsightsTimestamp()
        pulseRowID = "refresh"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.pulseRowID = nil
        }
        _ = store.checkAchievements()
    }

    func shareTerm(_ name: String) {
        FeedbackManager.lightTap()
    }
}
