import Foundation

enum AppExternalLink {
    case privacyPolicy
    case termsOfService

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://solveniquedynamics.com/privacy-policy.html"
        case .termsOfService:
            return "https://solveniquedynamics.com/support.html"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
