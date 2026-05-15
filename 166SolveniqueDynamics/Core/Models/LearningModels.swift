import Foundation

struct TermContextScenario: Identifiable, Hashable {
    let id: String
    let contextText: String
    let correctTermName: String
    let hint: String
}

struct ConfusionPair: Identifiable, Hashable {
    let id: String
    let termA: String
    let termB: String
    let summary: String
    let rows: [ConfusionRow]
}

struct ConfusionRow: Hashable {
    let aspect: String
    let termA: String
    let termB: String
}

struct TermGraphCluster: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let nodes: [TermGraphNode]
    let edges: [TermGraphEdge]
}

struct TermGraphNode: Identifiable, Hashable {
    let id: String
    let termName: String
    let x: CGFloat
    let y: CGFloat
}

struct TermGraphEdge: Identifiable, Hashable {
    let id: String
    let fromNodeId: String
    let toNodeId: String
    let label: String
}

struct CaseStudy: Identifiable, Hashable {
    let id: String
    let title: String
    let narrative: String
    let questions: [CaseStudyQuestion]
}

struct CaseStudyQuestion: Identifiable, Hashable {
    let id: String
    let prompt: String
    let options: [String]
    let correctTermName: String
}

enum MiniQuizMode: String, CaseIterable, Identifiable {
    case definitionToTerm = "Definition → Term"
    case termToCategory = "Term → Category"
    case oddOneOut = "Odd One Out"

    var id: String { rawValue }
}

struct MiniQuizQuestion: Identifiable {
    let id: String
    let mode: MiniQuizMode
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let relatedTermName: String?
}

struct TermReviewSchedule: Codable, Equatable {
    var stage: Int
    var nextReviewDate: Date

    static let intervalsDays = [1, 3, 7]
}
