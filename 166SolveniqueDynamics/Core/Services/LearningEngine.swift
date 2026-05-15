import Foundation

enum LearningEngine {
    static func options(for scenario: TermContextScenario, enabledPacks: Set<String>) -> [String] {
        let correct = scenario.correctTermName
        let pool = LegalGlossary.activeTerms(enabledPacks: enabledPacks)
            .map(\.name)
            .filter { $0 != correct }
        let distractors = Array(pool.shuffled().prefix(3))
        return (distractors + [correct]).shuffled()
    }

    static func weakTermNames(store: AppDataStore) -> [String] {
        let active = Set(LegalGlossary.activeTerms(enabledPacks: store.enabledPackIds).map(\.name))
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now

        var scores: [String: Int] = [:]

        for name in active {
            var score = 0
            let again = store.practiceAgainCounts[name] ?? 0
            if again >= 2 { score += 3 }
            else if again >= 1 { score += 1 }

            if store.uniqueTermsViewed.contains(name), !store.isFavorite(name) {
                score += 1
            }

            if let accessed = store.termAccessDates[name], accessed < weekAgo {
                score += 2
            }

            if (store.termViewCounts[name] ?? 0) <= 1, store.uniqueTermsViewed.contains(name) {
                score += 1
            }

            if score > 0 { scores[name] = score }
        }

        return scores.sorted { $0.value > $1.value }.map(\.key)
    }

    static func buildMiniQuiz(enabledPacks: Set<String>, count: Int = 5) -> [MiniQuizQuestion] {
        let terms = LegalGlossary.activeTerms(enabledPacks: enabledPacks)
        guard terms.count >= 4 else { return [] }

        var questions: [MiniQuizQuestion] = []
        let modes = MiniQuizMode.allCases
        var index = 0

        while questions.count < count && index < count * 3 {
            let mode = modes[index % modes.count]
            if let q = question(for: mode, terms: terms, seed: index) {
                questions.append(q)
            }
            index += 1
        }
        return Array(questions.prefix(count))
    }

    private static func question(for mode: MiniQuizMode, terms: [LegalTerm], seed: Int) -> MiniQuizQuestion? {
        guard !terms.isEmpty else { return nil }
        let term = terms[seed % terms.count]

        switch mode {
        case .definitionToTerm:
            let others = terms.filter { $0.name != term.name }.shuffled().prefix(3).map(\.name)
            let options = (others + [term.name]).shuffled()
            guard let correctIndex = options.firstIndex(of: term.name) else { return nil }
            return MiniQuizQuestion(
                id: "def_\(seed)",
                mode: mode,
                prompt: term.briefDefinition,
                options: options,
                correctIndex: correctIndex,
                relatedTermName: term.name
            )

        case .termToCategory:
            let categories = LegalTermCategory.allCases
            let correct = term.category.displayName
            var options = categories.map(\.displayName).filter { $0 != correct }.shuffled().prefix(3)
            options.append(correct)
            let shuffled = Array(options).shuffled()
            guard let correctIndex = shuffled.firstIndex(of: correct) else { return nil }
            return MiniQuizQuestion(
                id: "cat_\(seed)",
                mode: mode,
                prompt: "Which category best fits \"\(term.name)\"?",
                options: shuffled,
                correctIndex: correctIndex,
                relatedTermName: term.name
            )

        case .oddOneOut:
            let sameCategory = terms.filter { $0.category == term.category && $0.name != term.name }
            let otherCategory = terms.first { $0.category != term.category }
            guard let odd = otherCategory, sameCategory.count >= 2 else { return nil }
            let group = Array(sameCategory.prefix(2)) + [odd]
            let shuffled = group.shuffled()
            guard let correctIndex = shuffled.firstIndex(where: { $0.name == odd.name }) else { return nil }
            return MiniQuizQuestion(
                id: "odd_\(seed)",
                mode: mode,
                prompt: "Which term does not belong with the others?",
                options: shuffled.map(\.name),
                correctIndex: correctIndex,
                relatedTermName: odd.name
            )
        }
    }
}
