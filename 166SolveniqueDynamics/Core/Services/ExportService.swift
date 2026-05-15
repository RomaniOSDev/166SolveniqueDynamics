import Foundation

enum ExportService {
    static func favoritesList(store: AppDataStore) -> String {
        var lines = ["Favorite Legal Terms", "Generated locally — no data leaves your device.", ""]
        for name in store.favoriteTerms {
            guard let term = LegalGlossary.term(named: name, enabledPacks: store.enabledPackIds) else { continue }
            lines.append("• \(term.name)")
            lines.append("  \(term.briefDefinition)")
            if let note = store.termNotes[name], !note.isEmpty {
                lines.append("  Note: \(note)")
            }
            lines.append("")
        }
        if store.favoriteTerms.isEmpty {
            lines.append("No favorites saved yet.")
        }
        return lines.joined(separator: "\n")
    }

    static func historyList(store: AppDataStore) -> String {
        var lines = ["Search History", "Generated locally — no data leaves your device.", ""]
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        for name in store.viewedTerms {
            guard let term = LegalGlossary.term(named: name, enabledPacks: store.enabledPackIds) else {
                lines.append("• \(name)")
                continue
            }
            lines.append("• \(term.name)")
            lines.append("  \(term.briefDefinition)")
            if let date = store.termAccessDates[name] {
                lines.append("  Last viewed: \(formatter.string(from: date))")
            }
            lines.append("")
        }
        if store.viewedTerms.isEmpty {
            lines.append("No terms viewed yet.")
        }
        return lines.joined(separator: "\n")
    }

    static func compareList(terms: [LegalTerm]) -> String {
        var lines = ["Term Comparison", ""]
        for term in terms {
            lines.append("=== \(term.name) ===")
            lines.append(term.briefDefinition)
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }
}
