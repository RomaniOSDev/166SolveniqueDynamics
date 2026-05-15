import Foundation

enum AppExternalLink {
    case privacyPolicy
    case termsOfService

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://solvenique166dynamics.site/privacy/168"
        case .termsOfService:
            return "https://solvenique166dynamics.site/terms/168"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
