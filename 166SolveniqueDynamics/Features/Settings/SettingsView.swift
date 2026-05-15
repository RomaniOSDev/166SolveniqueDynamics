import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel: SettingsViewModel
    @State private var shareText: ShareableText?

    init(store: AppDataStore = .shared) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(store: store))
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 20) {
                        learningGoalCard
                        ActivityChartView(data: store.activityLast7Days())
                        achievementsSection
                        summaryMetricsCard
                        practiceStatsCard
                        statsCard
                        exportCard
                        settingsList
                        versionFooter
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Settings")
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(item: $shareText) { ShareSheet(items: [$0.text]) }
            .alert("Reset All Data?", isPresented: $viewModel.showResetAlert) {
                Button("Cancel", role: .cancel) { FeedbackManager.lightTap() }
                Button("Reset", role: .destructive) { viewModel.resetData() }
            } message: {
                Text("This will erase all local data including history, favorites, and achievements.")
            }
        }
    }

    private var learningGoalCard: some View {
        ProgressBannerView(
            title: "Daily Learning Goal",
            subtitle: "\(store.dailyGoalCount) of \(AppDataStore.dailyGoalTarget) terms today",
            progress: store.dailyGoalProgress,
            icon: "target",
            completeLabel: store.isDailyGoalComplete ? "Complete" : nil
        )
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Achievements", subtitle: "Decorative milestones", icon: "rosette")
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AchievementDefinition.all) { achievement in
                    AchievementBadgeCell(
                        title: achievement.title,
                        description: achievement.description,
                        iconName: achievement.iconName,
                        unlocked: store.achievementsUnlocked[achievement.id] != nil
                    )
                }
            }
        }
    }

    private var summaryMetricsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Summary", icon: "chart.pie.fill")
            LazyVGrid(columns: columns, spacing: 12) {
                MetricTileView(value: "\(store.itemsCreated)", label: "Terms Explored", icon: "book")
                MetricTileView(value: "\(store.totalLookups)", label: "Total Lookups", icon: "eye")
                MetricTileView(value: "\(store.favoriteTerms.count)", label: "Favorites", icon: "star")
                MetricTileView(value: "\(store.streakDays)", label: "Day Streak", icon: "flame")
            }
        }
    }

    private var practiceStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Practice Statistics", icon: "brain")
            statRow(label: "Cards reviewed", value: "\(store.practiceCardsReviewed)")
            statRow(label: "Practice sessions", value: "\(store.practiceSessionsCompleted)")
        }
        .appCard(elevation: .raised)
    }

    private var statsCard: some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: "Statistics", icon: "chart.bar")
                .padding(.bottom, 8)
            statRow(label: "Minutes used", value: "\(store.totalMinutesUsed)")
            Divider().overlay(Color.white.opacity(0.08))
            statRow(label: "Sessions completed", value: "\(store.sessionsCompleted)")
        }
        .appCard(padding: 14, elevation: .raised)
    }

    private var exportCard: some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: "Export & Share", icon: "square.and.arrow.up")
                .padding(.bottom, 8)
            Button {
                shareText = ShareableText(text: ExportService.favoritesList(store: store))
                FeedbackManager.lightTap()
            } label: {
                ActionRowCell(title: "Share Favorites", icon: "star")
            }
            Divider().overlay(Color.white.opacity(0.08))
            Button {
                shareText = ShareableText(text: ExportService.historyList(store: store))
                FeedbackManager.lightTap()
            } label: {
                ActionRowCell(title: "Share History", icon: "clock")
            }
        }
        .appCard(padding: 0, elevation: .raised)
    }

    private var settingsList: some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: "About", icon: "info.circle")
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 4)
            Button {
                FeedbackManager.lightTap()
                viewModel.rateApp()
            } label: {
                ActionRowCell(title: "Rate Us", icon: "star.fill")
            }
            Divider().overlay(Color.white.opacity(0.08))
            Button {
                FeedbackManager.lightTap()
                viewModel.openPrivacyPolicy()
            } label: {
                ActionRowCell(title: "Privacy Policy", icon: "hand.raised")
            }
            Divider().overlay(Color.white.opacity(0.08))
            Button {
                FeedbackManager.lightTap()
                viewModel.openTermsOfService()
            } label: {
                ActionRowCell(title: "Terms of Service", icon: "doc.text")
            }
            Divider().overlay(Color.white.opacity(0.08))
            Button {
                FeedbackManager.lightTap()
                viewModel.showResetAlert = true
            } label: {
                ActionRowCell(title: "Reset All Data", icon: "trash", destructive: true)
            }
        }
        .appCard(padding: 0, elevation: .raised)
    }

    private var versionFooter: some View {
        Text("Version \(viewModel.appVersion)")
            .font(.caption)
            .foregroundStyle(Color.appTextSecondary)
            .frame(maxWidth: .infinity)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextPrimary)
        }
        .font(.subheadline)
        .padding(.vertical, 6)
    }
}
