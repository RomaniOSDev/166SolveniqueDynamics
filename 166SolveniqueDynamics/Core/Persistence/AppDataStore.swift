import Combine
import Foundation

@MainActor
final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()
    static let dailyGoalTarget = 5
    static let maxCompareTerms = 3

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let sessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let searchedTerms = "searchedTerms"
        static let favoriteTerms = "favoriteTerms"
        static let viewedTerms = "viewedTerms"
        static let termAccessDates = "termAccessDates"
        static let termViewCounts = "termViewCounts"
        static let lastUpdatedDate = "lastUpdatedDate"
        static let uniqueTermsViewed = "uniqueTermsViewed"
        static let sessionActive = "sessionActive"
        static let sessionStart = "sessionStart"
        static let termNotes = "termNotes"
        static let enabledPackIds = "enabledPackIds"
        static let compareTermNames = "compareTermNames"
        static let dailyGoalCount = "dailyGoalCount"
        static let dailyGoalDateKey = "dailyGoalDateKey"
        static let dailyActivityCounts = "dailyActivityCounts"
        static let practiceCardsReviewed = "practiceCardsReviewed"
        static let practiceSessionsCompleted = "practiceSessionsCompleted"
        static let practiceAgainCounts = "practiceAgainCounts"
        static let termReviewSchedules = "termReviewSchedules"
        static let caseStudyCompletedDayKey = "caseStudyCompletedDayKey"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var sessionTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var sessionsCompleted: Int {
        didSet { defaults.set(sessionsCompleted, forKey: Keys.sessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let lastActivityDate {
                defaults.set(lastActivityDate.timeIntervalSince1970, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveDictionary(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }

    @Published var searchedTerms: [String] {
        didSet { saveArray(searchedTerms, key: Keys.searchedTerms) }
    }

    @Published var favoriteTerms: [String] {
        didSet { saveArray(favoriteTerms, key: Keys.favoriteTerms) }
    }

    @Published var viewedTerms: [String] {
        didSet { saveArray(viewedTerms, key: Keys.viewedTerms) }
    }

    @Published var termAccessDates: [String: Date] {
        didSet { saveDictionary(termAccessDates, key: Keys.termAccessDates) }
    }

    @Published var termViewCounts: [String: Int] {
        didSet { saveDictionary(termViewCounts, key: Keys.termViewCounts) }
    }

    @Published var lastUpdatedDate: String {
        didSet { defaults.set(lastUpdatedDate, forKey: Keys.lastUpdatedDate) }
    }

    @Published private(set) var uniqueTermsViewed: Set<String> {
        didSet { saveArray(Array(uniqueTermsViewed).sorted(), key: Keys.uniqueTermsViewed) }
    }

    @Published var termNotes: [String: String] {
        didSet { saveDictionary(termNotes, key: Keys.termNotes) }
    }

    @Published var enabledPackIds: Set<String> {
        didSet { saveArray(Array(enabledPackIds).sorted(), key: Keys.enabledPackIds) }
    }

    @Published var compareTermNames: [String] {
        didSet { saveArray(compareTermNames, key: Keys.compareTermNames) }
    }

    @Published var dailyGoalCount: Int {
        didSet { defaults.set(dailyGoalCount, forKey: Keys.dailyGoalCount) }
    }

    @Published var dailyGoalDateKey: String {
        didSet { defaults.set(dailyGoalDateKey, forKey: Keys.dailyGoalDateKey) }
    }

    @Published var dailyActivityCounts: [String: Int] {
        didSet { saveDictionary(dailyActivityCounts, key: Keys.dailyActivityCounts) }
    }

    @Published var practiceCardsReviewed: Int {
        didSet { defaults.set(practiceCardsReviewed, forKey: Keys.practiceCardsReviewed) }
    }

    @Published var practiceSessionsCompleted: Int {
        didSet { defaults.set(practiceSessionsCompleted, forKey: Keys.practiceSessionsCompleted) }
    }

    @Published var practiceAgainCounts: [String: Int] {
        didSet { saveDictionary(practiceAgainCounts, key: Keys.practiceAgainCounts) }
    }

    @Published var termReviewSchedules: [String: TermReviewSchedule] {
        didSet { saveDictionary(termReviewSchedules, key: Keys.termReviewSchedules) }
    }

    @Published var caseStudyCompletedDayKey: String {
        didSet { defaults.set(caseStudyCompletedDayKey, forKey: Keys.caseStudyCompletedDayKey) }
    }

    var itemsCreated: Int { uniqueTermsViewed.count }
    var uniqueTermsCount: Int { uniqueTermsViewed.count }
    var totalLookups: Int { termViewCounts.values.reduce(0, +) }

    var dailyGoalProgress: Double {
        min(1, Double(dailyGoalCount) / Double(Self.dailyGoalTarget))
    }

    var isDailyGoalComplete: Bool { dailyGoalCount >= Self.dailyGoalTarget }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        sessionsCompleted = defaults.integer(forKey: Keys.sessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        if let interval = defaults.object(forKey: Keys.lastActivityDate) as? TimeInterval {
            lastActivityDate = Date(timeIntervalSince1970: interval)
        } else {
            lastActivityDate = nil
        }
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked, defaults: defaults, decoder: decoder) ?? [:]
        searchedTerms = Self.loadArray(key: Keys.searchedTerms, defaults: defaults, decoder: decoder) ?? []
        favoriteTerms = Self.loadArray(key: Keys.favoriteTerms, defaults: defaults, decoder: decoder) ?? []
        viewedTerms = Self.loadArray(key: Keys.viewedTerms, defaults: defaults, decoder: decoder) ?? []
        termAccessDates = Self.loadDictionary(key: Keys.termAccessDates, defaults: defaults, decoder: decoder) ?? [:]
        termViewCounts = Self.loadDictionary(key: Keys.termViewCounts, defaults: defaults, decoder: decoder) ?? [:]
        lastUpdatedDate = defaults.string(forKey: Keys.lastUpdatedDate) ?? ""
        let uniqueList: [String] = Self.loadArray(key: Keys.uniqueTermsViewed, defaults: defaults, decoder: decoder) ?? []
        uniqueTermsViewed = Set(uniqueList)
        termNotes = Self.loadDictionary(key: Keys.termNotes, defaults: defaults, decoder: decoder) ?? [:]
        let packList: [String] = Self.loadArray(key: Keys.enabledPackIds, defaults: defaults, decoder: decoder) ?? []
        enabledPackIds = Set(packList.isEmpty ? LegalTermPack.allCases.map(\.rawValue) : packList)
        compareTermNames = Self.loadArray(key: Keys.compareTermNames, defaults: defaults, decoder: decoder) ?? []
        dailyGoalCount = defaults.integer(forKey: Keys.dailyGoalCount)
        dailyGoalDateKey = defaults.string(forKey: Keys.dailyGoalDateKey) ?? ""
        dailyActivityCounts = Self.loadDictionary(key: Keys.dailyActivityCounts, defaults: defaults, decoder: decoder) ?? [:]
        practiceCardsReviewed = defaults.integer(forKey: Keys.practiceCardsReviewed)
        practiceSessionsCompleted = defaults.integer(forKey: Keys.practiceSessionsCompleted)
        practiceAgainCounts = Self.loadDictionary(key: Keys.practiceAgainCounts, defaults: defaults, decoder: decoder) ?? [:]
        termReviewSchedules = Self.loadDictionary(key: Keys.termReviewSchedules, defaults: defaults, decoder: decoder) ?? [:]
        caseStudyCompletedDayKey = defaults.string(forKey: Keys.caseStudyCompletedDayKey) ?? ""

        resetDailyGoalIfNeeded()

        NotificationCenter.default.publisher(for: .dataReset)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.reloadFromDefaults()
            }
            .store(in: &cancellables)
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        beginSessionIfNeeded()
    }

    func beginSessionIfNeeded() {
        guard !defaults.bool(forKey: Keys.sessionActive) else { return }
        defaults.set(true, forKey: Keys.sessionActive)
        defaults.set(Date().timeIntervalSince1970, forKey: Keys.sessionStart)
        startSessionTimer()
    }

    func completeSession() {
        guard defaults.bool(forKey: Keys.sessionActive) else { return }
        defaults.set(false, forKey: Keys.sessionActive)
        sessionTimer?.invalidate()
        sessionTimer = nil
        if let start = defaults.object(forKey: Keys.sessionStart) as? TimeInterval {
            let minutes = max(1, Int((Date().timeIntervalSince1970 - start) / 60))
            totalMinutesUsed += minutes
        }
        sessionsCompleted += 1
        defaults.removeObject(forKey: Keys.sessionStart)
        checkAchievements()
    }

    func recordTermViewed(_ termName: String) {
        let name = termName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        beginSessionIfNeeded()
        updateStreak()
        resetDailyGoalIfNeeded()
        incrementDailyGoal()

        let dayKey = Self.dayKey(for: Date())
        dailyActivityCounts[dayKey, default: 0] += 1

        if !uniqueTermsViewed.contains(name) {
            uniqueTermsViewed.insert(name)
        }

        termViewCounts[name, default: 0] += 1

        if !viewedTerms.contains(name) {
            viewedTerms.insert(name, at: 0)
        } else {
            viewedTerms.removeAll { $0 == name }
            viewedTerms.insert(name, at: 0)
        }

        termAccessDates[name] = Date()

        if isFavorite(name), isSpacedReviewDue(for: name) {
            completeSpacedReview(for: name)
        }

        if !searchedTerms.contains(name) {
            searchedTerms.insert(name, at: 0)
        } else {
            searchedTerms.removeAll { $0 == name }
            searchedTerms.insert(name, at: 0)
        }
        if searchedTerms.count > 50 {
            searchedTerms = Array(searchedTerms.prefix(50))
        }

        checkAchievements()
    }

    func toggleFavorite(_ termName: String) {
        if favoriteTerms.contains(termName) {
            favoriteTerms.removeAll { $0 == termName }
            termReviewSchedules.removeValue(forKey: termName)
        } else {
            favoriteTerms.insert(termName, at: 0)
            scheduleReview(for: termName, stage: 0)
        }
        FeedbackManager.mediumTap()
    }

    func isFavorite(_ termName: String) -> Bool {
        favoriteTerms.contains(termName)
    }

    func note(for termName: String) -> String {
        termNotes[termName] ?? ""
    }

    func setNote(_ note: String, for termName: String) {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            termNotes.removeValue(forKey: termName)
        } else {
            termNotes[termName] = trimmed
        }
    }

    func toggleCompare(_ termName: String) -> Bool {
        if compareTermNames.contains(termName) {
            compareTermNames.removeAll { $0 == termName }
            return false
        }
        guard compareTermNames.count < Self.maxCompareTerms else { return false }
        compareTermNames.append(termName)
        return true
    }

    func isInCompare(_ termName: String) -> Bool {
        compareTermNames.contains(termName)
    }

    func clearCompare() {
        compareTermNames = []
    }

    var compareTerms: [LegalTerm] {
        compareTermNames.compactMap { LegalGlossary.term(named: $0, enabledPacks: enabledPackIds) }
    }

    func togglePack(_ pack: LegalTermPack) {
        if pack == .core { return }
        if enabledPackIds.contains(pack.rawValue) {
            enabledPackIds.remove(pack.rawValue)
        } else {
            enabledPackIds.insert(pack.rawValue)
        }
        enabledPackIds.insert(LegalTermPack.core.rawValue)
    }

    func isPackEnabled(_ pack: LegalTermPack) -> Bool {
        pack == .core || enabledPackIds.contains(pack.rawValue)
    }

    func recordPracticeCardReviewed() {
        practiceCardsReviewed += 1
    }

    func recordPracticeAgain(_ termName: String) {
        practiceAgainCounts[termName, default: 0] += 1
    }

    func completePracticeSession() {
        practiceSessionsCompleted += 1
        FeedbackManager.success()
    }

    var dueReviewTermNames: [String] {
        favoriteTerms.filter { isSpacedReviewDue(for: $0) }
    }

    var dueReviewCount: Int { dueReviewTermNames.count }

    func scheduleReview(for termName: String, stage: Int) {
        let capped = min(stage, TermReviewSchedule.intervalsDays.count - 1)
        let days = TermReviewSchedule.intervalsDays[capped]
        let next = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        termReviewSchedules[termName] = TermReviewSchedule(stage: capped, nextReviewDate: next)
    }

    func completeSpacedReview(for termName: String) {
        let current = termReviewSchedules[termName]?.stage ?? 0
        let nextStage = min(current + 1, TermReviewSchedule.intervalsDays.count - 1)
        scheduleReview(for: termName, stage: nextStage)
    }

    func isCaseStudyCompletedToday() -> Bool {
        caseStudyCompletedDayKey == Self.dayKey(for: Date())
    }

    func markCaseStudyCompletedToday() {
        caseStudyCompletedDayKey = Self.dayKey(for: Date())
    }

    func ensureReviewSchedulesForFavorites() {
        for name in favoriteTerms where termReviewSchedules[name] == nil {
            scheduleReview(for: name, stage: 0)
        }
    }

    func isSpacedReviewDue(for termName: String) -> Bool {
        guard let schedule = termReviewSchedules[termName] else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.startOfDay(for: schedule.nextReviewDate) <= today
    }

    func activityLast7Days() -> [(label: String, count: Int)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return (0..<7).reversed().compactMap { offset -> (String, Int)? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let key = Self.dayKey(for: date)
            return (formatter.string(from: date), dailyActivityCounts[key] ?? 0)
        }
    }

    func removeFromHistory(_ termName: String) {
        viewedTerms.removeAll { $0 == termName }
        termAccessDates.removeValue(forKey: termName)
    }

    func clearHistory() {
        viewedTerms = []
        termAccessDates = [:]
        FeedbackManager.success()
    }

    func refreshInsightsTimestamp() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        lastUpdatedDate = formatter.string(from: Date())
        FeedbackManager.refreshInsights()
    }

    @discardableResult
    func checkAchievements() -> [AchievementDefinition] {
        var newlyUnlocked: [AchievementDefinition] = []
        for achievement in AchievementDefinition.all {
            guard achievementsUnlocked[achievement.id] == nil else { continue }
            if achievement.isUnlocked(self) {
                achievementsUnlocked[achievement.id] = Date()
                newlyUnlocked.append(achievement)
            }
        }
        return newlyUnlocked
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func insights(for period: InsightPeriod) -> [(term: String, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        let filtered: [String: Int]

        switch period {
        case .weekly:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            filtered = termAccessDates.filter { $0.value >= weekAgo }
                .reduce(into: [String: Int]()) { result, pair in
                    result[pair.key] = termViewCounts[pair.key] ?? 0
                }
        case .monthly:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            filtered = termAccessDates.filter { $0.value >= monthAgo }
                .reduce(into: [String: Int]()) { result, pair in
                    result[pair.key] = termViewCounts[pair.key] ?? 0
                }
        case .allTime:
            filtered = termViewCounts
        }

        return filtered
            .map { (term: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    private func resetDailyGoalIfNeeded() {
        let today = Self.dayKey(for: Date())
        if dailyGoalDateKey != today {
            dailyGoalDateKey = today
            dailyGoalCount = 0
        }
    }

    private func incrementDailyGoal() {
        resetDailyGoalIfNeeded()
        if dailyGoalCount < Self.dailyGoalTarget {
            dailyGoalCount += 1
        }
    }

    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            if lastDay == today { return }
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               lastDay == yesterday {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastActivityDate = today
    }

    private func startSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.totalMinutesUsed += 1
            }
        }
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        sessionsCompleted = defaults.integer(forKey: Keys.sessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        if let interval = defaults.object(forKey: Keys.lastActivityDate) as? TimeInterval {
            lastActivityDate = Date(timeIntervalSince1970: interval)
        } else {
            lastActivityDate = nil
        }
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked, defaults: defaults, decoder: decoder) ?? [:]
        searchedTerms = Self.loadArray(key: Keys.searchedTerms, defaults: defaults, decoder: decoder) ?? []
        favoriteTerms = Self.loadArray(key: Keys.favoriteTerms, defaults: defaults, decoder: decoder) ?? []
        viewedTerms = Self.loadArray(key: Keys.viewedTerms, defaults: defaults, decoder: decoder) ?? []
        termAccessDates = Self.loadDictionary(key: Keys.termAccessDates, defaults: defaults, decoder: decoder) ?? [:]
        termViewCounts = Self.loadDictionary(key: Keys.termViewCounts, defaults: defaults, decoder: decoder) ?? [:]
        lastUpdatedDate = defaults.string(forKey: Keys.lastUpdatedDate) ?? ""
        let uniqueList: [String] = Self.loadArray(key: Keys.uniqueTermsViewed, defaults: defaults, decoder: decoder) ?? []
        uniqueTermsViewed = Set(uniqueList)
        termNotes = Self.loadDictionary(key: Keys.termNotes, defaults: defaults, decoder: decoder) ?? [:]
        let packList: [String] = Self.loadArray(key: Keys.enabledPackIds, defaults: defaults, decoder: decoder) ?? []
        enabledPackIds = Set(packList.isEmpty ? LegalTermPack.allCases.map(\.rawValue) : packList)
        compareTermNames = Self.loadArray(key: Keys.compareTermNames, defaults: defaults, decoder: decoder) ?? []
        dailyGoalCount = defaults.integer(forKey: Keys.dailyGoalCount)
        dailyGoalDateKey = defaults.string(forKey: Keys.dailyGoalDateKey) ?? ""
        dailyActivityCounts = Self.loadDictionary(key: Keys.dailyActivityCounts, defaults: defaults, decoder: decoder) ?? [:]
        practiceCardsReviewed = defaults.integer(forKey: Keys.practiceCardsReviewed)
        practiceSessionsCompleted = defaults.integer(forKey: Keys.practiceSessionsCompleted)
        practiceAgainCounts = Self.loadDictionary(key: Keys.practiceAgainCounts, defaults: defaults, decoder: decoder) ?? [:]
        termReviewSchedules = Self.loadDictionary(key: Keys.termReviewSchedules, defaults: defaults, decoder: decoder) ?? [:]
        caseStudyCompletedDayKey = defaults.string(forKey: Keys.caseStudyCompletedDayKey) ?? ""
        resetDailyGoalIfNeeded()
        sessionTimer?.invalidate()
        sessionTimer = nil
    }

    private func saveArray<T: Codable>(_ value: [T], key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func saveDictionary<T: Codable>(_ value: [String: T], key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func loadArray<T: Codable>(key: String, defaults: UserDefaults, decoder: JSONDecoder) -> [T]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode([T].self, from: data)
    }

    private static func loadDictionary<T: Codable>(key: String, defaults: UserDefaults, decoder: JSONDecoder) -> [String: T]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode([String: T].self, from: data)
    }
}

enum InsightPeriod: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case allTime = "All-Time"

    var id: String { rawValue }
}
