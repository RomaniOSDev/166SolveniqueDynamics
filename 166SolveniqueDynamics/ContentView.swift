import Combine
import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore.shared
    @StateObject private var bannerManager = AchievementBannerManager()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showBanner = false

    var body: some View {
        ZStack(alignment: .top) {
            AppBackgroundView()

            Group {
                if store.hasSeenOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(store)
            .environmentObject(bannerManager)

            if let achievement = bannerManager.currentBanner {
                AchievementBannerView(achievement: achievement)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.3), value: bannerManager.currentBanner?.id)
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                store.beginSessionIfNeeded()
            case .background:
                store.completeSession()
            default:
                break
            }
        }
        .onAppear {
            store.beginSessionIfNeeded()
            _ = store.checkAchievements()
        }
    }
}

#Preview {
    ContentView()
}
