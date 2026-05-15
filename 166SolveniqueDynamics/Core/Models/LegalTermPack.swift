import Foundation

enum LegalTermPack: String, Codable, CaseIterable, Identifiable {
    case core
    case tax
    case intellectualProperty = "ip"
    case familyLaw = "family"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .core: return "Core Glossary"
        case .tax: return "Tax Law"
        case .intellectualProperty: return "Intellectual Property"
        case .familyLaw: return "Family Law"
        }
    }

    var description: String {
        switch self {
        case .core: return "Essential legal terms for everyday reference."
        case .tax: return "Taxation, audits, and compliance terminology."
        case .intellectualProperty: return "Copyright, patents, trademarks, and IP rights."
        case .familyLaw: return "Custody, support, and domestic relations terms."
        }
    }
}
