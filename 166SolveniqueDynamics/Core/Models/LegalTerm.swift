import Foundation

struct LegalTerm: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let briefDefinition: String
    let fullDefinition: String
    let usageExample: String
    let relatedNotes: String
    let category: LegalTermCategory
    let packId: String
    let relatedTermNames: [String]

    init(
        name: String,
        briefDefinition: String,
        fullDefinition: String,
        usageExample: String,
        relatedNotes: String,
        category: LegalTermCategory = .general,
        packId: String = LegalTermPack.core.rawValue,
        relatedTermNames: [String] = []
    ) {
        self.id = name.lowercased().replacingOccurrences(of: " ", with: "_")
        self.name = name
        self.briefDefinition = briefDefinition
        self.fullDefinition = fullDefinition
        self.usageExample = usageExample
        self.relatedNotes = relatedNotes
        self.category = category
        self.packId = packId
        self.relatedTermNames = relatedTermNames
    }

    var pack: LegalTermPack {
        LegalTermPack(rawValue: packId) ?? .core
    }
}
