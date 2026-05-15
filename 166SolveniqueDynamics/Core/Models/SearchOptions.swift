import Foundation

enum SearchFieldFilter: String, CaseIterable, Identifiable {
    case all = "All Fields"
    case definition = "Definition"
    case example = "Example"

    var id: String { rawValue }
}

enum SearchSortOption: String, CaseIterable, Identifiable {
    case alphabetical = "A–Z"
    case frequency = "Most Viewed"

    var id: String { rawValue }
}
