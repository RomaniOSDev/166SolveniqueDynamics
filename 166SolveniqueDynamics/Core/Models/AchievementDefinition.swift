import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let isUnlocked: (AppDataStore) -> Bool

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_definition",
            title: "First Definition",
            description: "Accessed your first legal term definition.",
            iconName: "doc.text",
            isUnlocked: { $0.itemsCreated >= 1 }
        ),
        AchievementDefinition(
            id: "glossary_guru",
            title: "Glossary Guru",
            description: "Accessed ten different term definitions.",
            iconName: "books.vertical",
            isUnlocked: { $0.uniqueTermsCount >= 10 }
        ),
        AchievementDefinition(
            id: "legal_lexicon",
            title: "Legal Lexicon",
            description: "Explored fifty different term definitions.",
            iconName: "text.book.closed",
            isUnlocked: { $0.uniqueTermsCount >= 50 }
        ),
        AchievementDefinition(
            id: "daily_learner",
            title: "Daily Learner",
            description: "Accessed terms three days in a row.",
            iconName: "calendar",
            isUnlocked: { $0.streakDays >= 3 }
        ),
        AchievementDefinition(
            id: "hundred_terms",
            title: "+100 Terms Explored",
            description: "Looked up one hundred terms.",
            iconName: "eye.circle.fill",
            isUnlocked: { $0.totalLookups >= 100 }
        ),
        AchievementDefinition(
            id: "weekly_insight",
            title: "Weekly Insight",
            description: "Used the app every day for a week.",
            iconName: "chart.line.uptrend.xyaxis",
            isUnlocked: { $0.streakDays >= 7 }
        ),
        AchievementDefinition(
            id: "session_starter",
            title: "Session Starter",
            description: "Completed your first session.",
            iconName: "play.circle",
            isUnlocked: { $0.sessionsCompleted >= 1 }
        ),
        AchievementDefinition(
            id: "consistent_user",
            title: "Consistent User",
            description: "Completed twenty sessions.",
            iconName: "checkmark.seal",
            isUnlocked: { $0.sessionsCompleted >= 20 }
        )
    ]
}
