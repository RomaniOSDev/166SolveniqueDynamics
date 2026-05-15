import Combine
import Foundation
import StoreKit
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var showResetAlert = false

    let store: AppDataStore

    init(store: AppDataStore) {
        self.store = store
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    func openPrivacyPolicy() {
        open(link: .privacyPolicy)
    }

    func openTermsOfService() {
        open(link: .termsOfService)
    }

    private func open(link: AppExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    func resetData() {
        store.resetAllData()
        FeedbackManager.success()
    }
}
