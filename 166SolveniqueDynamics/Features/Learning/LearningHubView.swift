import SwiftUI

struct LearningHubView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    SectionHeaderView(
                        title: "Learning Lab",
                        subtitle: "Context, quizzes, graphs, and spaced review",
                        icon: "graduationcap.fill"
                    )
                    .padding(.horizontal, 16)

                    if store.dueReviewCount > 0 {
                        dueReviewBanner
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        hubTile(
                            title: "Term in Context",
                            subtitle: "Guess from scenarios",
                            icon: "text.bubble.fill",
                            destination: TermInContextView()
                        )
                        hubTile(
                            title: "Mini Quiz",
                            subtitle: "5 quick questions",
                            icon: "questionmark.circle.fill",
                            destination: MiniQuizView()
                        )
                        hubTile(
                            title: "Case Study",
                            subtitle: "Daily interactive case",
                            icon: "doc.text.magnifyingglass",
                            destination: CaseStudyView()
                        )
                        hubTile(
                            title: "Don't Confuse",
                            subtitle: "Compare similar terms",
                            icon: "arrow.left.arrow.right",
                            destination: ConfusionPairsListView()
                        )
                        hubTile(
                            title: "Term Families",
                            subtitle: "Visual concept maps",
                            icon: "point.3.connected.trianglepath.dotted",
                            destination: TermFamilyGraphListView()
                        )
                        hubTile(
                            title: "Weak Terms",
                            subtitle: "Focus on trouble spots",
                            icon: "exclamationmark.triangle.fill",
                            destination: WeakTermsPracticeView()
                        )
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Learning Lab")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear { store.ensureReviewSchedulesForFavorites() }
    }

    private var dueReviewBanner: some View {
        NavigationLink {
            SpacedReviewListView()
        } label: {
            HStack(spacing: 12) {
                IconBadge(systemName: "bell.badge.fill", size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Due for Review")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text("\(store.dueReviewCount) favorite terms ready today")
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
        .padding(.horizontal, 16)
    }

    private func hubTile<D: View>(title: String, subtitle: String, icon: String, destination: D) -> some View {
        NavigationLink {
            destination
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                QuickActionIllustration(symbol: icon, accent: .appPrimary)
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
            .appCard(padding: 14, elevation: .raised)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded { FeedbackManager.lightTap() })
    }
}
