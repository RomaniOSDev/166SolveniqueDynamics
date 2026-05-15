import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case library
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .library: return "Library"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .library: return "books.vertical.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackgroundView()

            Group {
                switch selectedTab {
                case .home:
                    HomeView(onOpenLibrary: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = .library
                        }
                    })
                case .library:
                    LibraryHubView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 88)
            }

            customTabBar
        }
        .ignoresSafeArea()
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    FeedbackManager.lightTap()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            if selectedTab == tab {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appPrimary.opacity(0.4), Color.appAccent.opacity(0.2)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 52, height: 32)
                            }
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .semibold))
                        }
                        Text(tab.title)
                            .font(.caption2.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(selectedTab == tab ? Color.appPrimary : Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 52)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 22)
        .background {
            GlassBarBackground()
                .padding(.horizontal, 8)
        }
    }
}
