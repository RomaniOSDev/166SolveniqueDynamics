import Foundation

enum LegalTermCategory: String, Codable, CaseIterable, Identifiable {
    case criminalLaw = "criminal_law"
    case civilProcedure = "civil_procedure"
    case contracts = "contracts"
    case general = "general"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .criminalLaw: return "Criminal Law"
        case .civilProcedure: return "Civil Procedure"
        case .contracts: return "Contracts"
        case .general: return "General Law"
        }
    }

    var iconName: String {
        switch self {
        case .criminalLaw: return "building.columns"
        case .civilProcedure: return "doc.text.magnifyingglass"
        case .contracts: return "signature"
        case .general: return "books.vertical"
        }
    }
}
