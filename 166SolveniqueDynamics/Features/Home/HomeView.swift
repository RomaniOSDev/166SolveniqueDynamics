import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var bannerManager: AchievementBannerManager
    @StateObject private var viewModel: HomeViewModel
    @State private var navigationPath = NavigationPath()
    @State private var showSearch = false
    @State private var showBrowse = false
    @State private var showCompare = false
    @State private var showPractice = false
    @State private var showLearningHub = false
    @State private var showCaseStudy = false
    @State private var showSpacedReview = false
    @State private var showMiniQuiz = false
    var onOpenLibrary: (() -> Void)?

    init(store: AppDataStore = .shared, onOpenLibrary: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(store: store))
        self.onOpenLibrary = onOpenLibrary
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                AppBackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        heroSection
                        quickStatsRow
                        learningHighlightsSection
                        termOfTheDayWidget
                        dailyGoalWidget
                        quickActionsGrid
                        if viewModel.hasCompare { compareWidget }
                        recentTermsWidget
                        categoriesWidget
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(for: LegalTerm.self) { term in
                TermDetailView(term: term)
            }
            .navigationDestination(isPresented: $showSearch) {
                Feature1View()
            }
            .navigationDestination(isPresented: $showBrowse) {
                BrowseByCategoryView()
            }
            .navigationDestination(isPresented: $showCompare) {
                CompareTermsView()
            }
            .navigationDestination(isPresented: $showPractice) {
                PracticeView()
            }
            .navigationDestination(isPresented: $showLearningHub) {
                LearningHubView()
            }
            .navigationDestination(isPresented: $showCaseStudy) {
                CaseStudyView()
            }
            .navigationDestination(isPresented: $showSpacedReview) {
                SpacedReviewListView()
            }
            .navigationDestination(isPresented: $showMiniQuiz) {
                MiniQuizView()
            }
        }
        .onAppear { store.ensureReviewSchedulesForFavorites() }
    }

    // MARK: - Hero

    private var heroSection: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)
                Text("Your legal glossary dashboard")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                HStack(spacing: 8) {
                    TagPill(text: "\(viewModel.streakDays) day streak", tint: .appAccent)
                    TagPill(text: "\(viewModel.termsExplored) explored", tint: .appPrimary)
                    if viewModel.dueReviewCount > 0 {
                        TagPill(text: "\(viewModel.dueReviewCount) due today", tint: .appPrimary)
                    }
                }
            }
            HomeHeroIllustration()
        }
        .appHeroCard(highlighted: true)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    // MARK: - Stats row

    private var quickStatsRow: some View {
        HStack(spacing: 10) {
            miniStatWidget(
                illustration: AnyView(StreakRingIllustration(progress: min(1, Double(viewModel.streakDays) / 7))),
                value: "\(viewModel.streakDays)",
                label: "Streak"
            )
            miniStatWidget(
                illustration: AnyView(QuickActionIllustration(symbol: "eye.fill", accent: .appAccent)),
                value: "\(viewModel.activityToday)",
                label: "Today"
            )
            miniStatWidget(
                illustration: AnyView(QuickActionIllustration(symbol: "star.fill", accent: .appPrimary)),
                value: "\(viewModel.favoriteCount)",
                label: "Saved"
            )
        }
    }

    private func miniStatWidget(illustration: AnyView, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            illustration
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .appCard(padding: 12, elevation: .raised)
    }

    // MARK: - Learning highlights

    private var learningHighlightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Learn & Apply",
                subtitle: "Context quizzes, case studies, spaced review",
                icon: "graduationcap.fill"
            )

            Button {
                showLearningHub = true
                FeedbackManager.lightTap()
            } label: {
                HStack(spacing: 12) {
                    QuickActionIllustration(symbol: "brain.head.profile", accent: .appPrimary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Learning Lab")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        Text("Context · Quiz · Graphs · Confusion pairs")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.appPrimary)
                }
                .appHeroCard()
            }
            .buttonStyle(.plain)

            if viewModel.dueReviewCount > 0 {
                Button {
                    showSpacedReview = true
                    FeedbackManager.lightTap()
                } label: {
                    HStack {
                        IconBadge(systemName: "bell.badge.fill", size: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Spaced Review Due")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.appTextPrimary)
                            Text("\(viewModel.dueReviewCount) favorites ready to review")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.appPrimary)
                    }
                    .appCard(elevation: .raised)
                }
                .buttonStyle(.plain)
            }

            if let study = viewModel.caseStudyOfTheDay {
                Button {
                    showCaseStudy = true
                    FeedbackManager.lightTap()
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TagPill(
                                text: store.isCaseStudyCompletedToday() ? "Case Complete" : "Case Study of the Day",
                                tint: store.isCaseStudyCompletedToday() ? .appPrimary : .appAccent
                            )
                            Spacer()
                            if viewModel.weakTermCount > 0 {
                                TagPill(text: "\(viewModel.weakTermCount) weak", tint: .appPrimary)
                            }
                        }
                        Text(study.title)
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                            .multilineTextAlignment(.leading)
                        Text(study.narrative)
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                        Label("Start case", systemImage: "arrow.right.circle.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appPrimary)
                    }
                    .appCard(elevation: .raised)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Term of the Day

    @ViewBuilder
    private var termOfTheDayWidget: some View {
        if let term = viewModel.termOfTheDay {
            Button {
                openTerm(term)
            } label: {
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        TagPill(text: "Term of the Day", tint: .appAccent)
                        Text(term.name)
                            .font(.title3.bold())
                            .foregroundStyle(Color.appTextPrimary)
                            .multilineTextAlignment(.leading)
                        Text(term.briefDefinition)
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                        Label("Read definition", systemImage: "arrow.right.circle.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appPrimary)
                    }
                    TermSpotlightIllustration()
                }
                .appHeroCard(highlighted: true)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Daily goal

    private var dailyGoalWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Daily Goal",
                subtitle: "Study \(AppDataStore.dailyGoalTarget) terms today",
                icon: "target"
            )
            HStack(spacing: 16) {
                StreakRingIllustration(progress: viewModel.dailyProgress)
                    .frame(width: 72, height: 72)
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(viewModel.dailyCount) of \(AppDataStore.dailyGoalTarget) complete")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.appBackground.opacity(0.55))
                            Capsule()
                                .fill(LinearGradient(colors: [.appPrimary, .appAccent], startPoint: .leading, endPoint: .trailing))
                                .frame(width: max(8, geo.size.width * viewModel.dailyProgress))
                        }
                    }
                    .frame(height: 10)
                    if store.isDailyGoalComplete {
                        Label("Goal reached today", systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appPrimary)
                    }
                }
            }
        }
        .appCard(elevation: .raised)
    }

    // MARK: - Quick actions

    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Actions", subtitle: "Jump to key tools", icon: "bolt.fill")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                quickActionTile(
                    title: "Search Terms",
                    subtitle: "Full glossary lookup",
                    symbol: "magnifyingglass",
                    accent: .appPrimary
                ) { showSearch = true }

                quickActionTile(
                    title: "Browse",
                    subtitle: "By legal category",
                    symbol: "square.grid.2x2.fill",
                    accent: .appAccent
                ) { showBrowse = true }

                quickActionTile(
                    title: "Practice",
                    subtitle: "Flashcard review",
                    symbol: "brain.head.profile",
                    accent: .appPrimary
                ) { showPractice = true }

                quickActionTile(
                    title: "Mini Quiz",
                    subtitle: "5-question challenge",
                    symbol: "questionmark.circle.fill",
                    accent: .appAccent
                ) { showMiniQuiz = true }

                quickActionTile(
                    title: "Library",
                    subtitle: "History & insights",
                    symbol: "books.vertical.fill",
                    accent: .appAccent
                ) {
                    onOpenLibrary?()
                }
            }
        }
    }

    private func quickActionTile(
        title: String,
        subtitle: String,
        symbol: String,
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                QuickActionIllustration(symbol: symbol, accent: accent)
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .appCard(padding: 14, elevation: .raised)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Compare

    private var compareWidget: some View {
        Button {
            showCompare = true
            FeedbackManager.lightTap()
        } label: {
            HStack {
                QuickActionIllustration(symbol: "rectangle.split.2x1", accent: .appAccent)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Compare Queue")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text("\(store.compareTermNames.count) terms ready")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.appPrimary)
            }
            .appHeroCard(highlighted: true)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent

    @ViewBuilder
    private var recentTermsWidget: some View {
        if !viewModel.recentTerms.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(title: "Recent", subtitle: "Pick up where you left off", icon: "clock.arrow.circlepath")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.recentTerms) { term in
                            Button {
                                openTerm(term)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    CategoryMiniIllustration(category: term.category)
                                        .frame(width: 56, height: 56)
                                    Text(term.name)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .leading)
                                }
                                .appListCard(padding: 12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Categories

    private var categoriesWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Explore Topics", subtitle: "Legal categories", icon: "folder.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(LegalTermCategory.allCases) { category in
                        Button {
                            showBrowse = true
                            FeedbackManager.lightTap()
                        } label: {
                            VStack(spacing: 8) {
                                CategoryMiniIllustration(category: category)
                                Text(category.displayName)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color.appTextSecondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 72)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func openTerm(_ term: LegalTerm) {
        FeedbackManager.lightTap()
        store.recordTermViewed(term.name)
        FeedbackManager.definitionViewed()
        bannerManager.showIfNeeded(store.checkAchievements())
        navigationPath.append(term)
    }
}
