import Combine
import Foundation
import SwiftUI

@MainActor
final class AchievementBannerManager: ObservableObject {
    @Published private(set) var currentBanner: AchievementDefinition?
    private var queue: [AchievementDefinition] = []
    private var dismissTask: Task<Void, Never>?

    func showIfNeeded(_ achievements: [AchievementDefinition]) {
        guard !achievements.isEmpty else { return }
        queue.append(contentsOf: achievements)
        presentNextIfIdle()
    }

    private func presentNextIfIdle() {
        guard currentBanner == nil, let next = queue.first else { return }
        queue.removeFirst()
        currentBanner = next
        FeedbackManager.achievementUnlocked()
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                currentBanner = nil
            }
            try? await Task.sleep(nanoseconds: 350_000_000)
            presentNextIfIdle()
        }
    }
}
