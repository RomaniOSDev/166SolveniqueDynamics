import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var pageIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            stepLabel: "Learn",
            headline: "Understand Legal Terms",
            description: "This app helps you comprehend and reference complex legal terminology.",
            icon: "books.vertical.fill",
            illustration: .books
        ),
        OnboardingPage(
            stepLabel: "Explore",
            headline: "Tap for Definitions",
            description: "Simply tap on any term to instantly view its definition and usage.",
            icon: "hand.tap.fill",
            illustration: .tap
        ),
        OnboardingPage(
            stepLabel: "Begin",
            headline: "Start Learning Now",
            description: "Begin by entering a legal term in the search bar to explore its meaning.",
            icon: "magnifyingglass",
            illustration: .search
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                onboardingHeader

                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, index: index, total: pages.count)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: pageIndex)

                pageIndicator
                actionButton
            }
        }
    }

    private var onboardingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
                Text("Legal Glossary")
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)
            }
            Spacer()
            Text("\(pageIndex + 1)/\(pages.count)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.appSurface, Color.appBackground.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == pageIndex
                            ? AnyShapeStyle(AppVisualStyle.accentBarGradient)
                            : AnyShapeStyle(Color.appTextSecondary.opacity(0.35))
                    )
                    .frame(width: index == pageIndex ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: pageIndex)
            }
        }
        .padding(.bottom, 20)
    }

    private var actionButton: some View {
        Button {
            if pageIndex < pages.count - 1 {
                FeedbackManager.lightTap()
                withAnimation(.easeInOut(duration: 0.3)) {
                    pageIndex += 1
                }
            } else {
                FeedbackManager.mediumTap()
                store.completeOnboarding()
            }
        } label: {
            HStack(spacing: 8) {
                Text(pageIndex == pages.count - 1 ? "Get Started" : "Next")
                if pageIndex < pages.count - 1 {
                    Image(systemName: "arrow.right")
                        .font(.body.weight(.bold))
                } else {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.bold))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}

// MARK: - Page model

private struct OnboardingPage {
    let stepLabel: String
    let headline: String
    let description: String
    let icon: String
    let illustration: OnboardingIllustration
}

// MARK: - Page view

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let index: Int
    let total: Int
    @State private var appeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                illustrationHero
                textCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .onAppear {
            appeared = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                appeared = true
            }
        }
        .onDisappear { appeared = false }
    }

    private var illustrationHero: some View {
        VStack(spacing: 16) {
            TagPill(text: page.stepLabel, tint: .appPrimary)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appPrimary.opacity(0.28), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)

                page.illustration.view
                    .frame(height: 160)
                    .scaleEffect(appeared ? 1 : 0.75)
                    .opacity(appeared ? 1 : 0)
            }

            HStack(spacing: 6) {
                Image(systemName: page.icon)
                    .foregroundStyle(Color.appAccent)
                Text("Step \(index + 1) of \(total)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .appHeroCard(padding: 20)
    }

    private var textCard: some View {
        VStack(spacing: 12) {
            Text(page.headline)
                .font(.title2.bold())
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
            Text(page.description)
                .font(.body)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appCard(padding: 20, elevation: .raised)
        .offset(y: appeared ? 0 : 12)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.06), value: appeared)
    }
}

// MARK: - Illustrations

private enum OnboardingIllustration {
    case books, tap, search

    @ViewBuilder
    var view: some View {
        switch self {
        case .books: OnboardingBooksIllustration()
        case .tap: OnboardingTapIllustration()
        case .search: OnboardingSearchIllustration()
        }
    }
}

private struct OnboardingBooksIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary, Color.appPrimary.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 54, height: 118)
                .rotationEffect(.degrees(-10))
                .offset(x: -34, y: 6)
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appAccent, Color.appPrimary.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 56, height: 132)
                .shadow(color: .black.opacity(0.18), radius: 8, y: 4)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppVisualStyle.surfaceGradient)
                .frame(width: 52, height: 112)
                .rotationEffect(.degrees(10))
                .offset(x: 34, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            Image(systemName: "text.book.closed.fill")
                .font(.title)
                .foregroundStyle(Color.appPrimary.opacity(0.9))
                .offset(y: -8)
        }
    }
}

private struct OnboardingTapIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.appPrimary, Color.appAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 110, height: 110)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.appAccent.opacity(0.45), Color.appPrimary.opacity(0.15)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 50
                    )
                )
                .frame(width: 72, height: 72)

            Image(systemName: "hand.tap.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appTextPrimary)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
        }
    }
}

private struct OnboardingSearchIllustration: View {
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appTextSecondary.opacity(0.5), Color.appTextSecondary.opacity(0.25)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 10)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(width: 220)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppVisualStyle.surfaceGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.5), Color.white.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.16), radius: 8, y: 4)

            HStack(spacing: 8) {
                ForEach(["Affidavit", "Subpoena", "Writ"], id: \.self) { word in
                    Text(word)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.appSurface.opacity(0.9))
                        )
                        .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
            }
        }
    }
}
