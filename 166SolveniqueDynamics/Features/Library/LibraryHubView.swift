import SwiftUI

enum LibrarySection: String, CaseIterable, Identifiable {
    case history = "History"
    case insights = "Insights"
    case practice = "Practice"
    case favorites = "Favorites"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .history: return "clock.arrow.circlepath"
        case .insights: return "chart.bar"
        case .practice: return "brain.head.profile"
        case .favorites: return "star.fill"
        }
    }
}

struct LibraryHubView: View {
    @State private var section: LibrarySection = .history
    @State private var showBrowse = false
    @State private var showCompare = false
    @State private var showPacks = false
    @State private var showLearningLab = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AppBackgroundView()
                VStack(spacing: 0) {
                    librarySegmentPicker
                    Group {
                        switch section {
                        case .history:
                            Feature2View(embedded: true)
                        case .insights:
                            Feature3View(embedded: true)
                        case .practice:
                            PracticeView()
                        case .favorites:
                            FavoritesNotesView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showBrowse) {
                BrowseByCategoryView()
            }
            .navigationDestination(isPresented: $showCompare) {
                CompareTermsView()
            }
            .navigationDestination(isPresented: $showPacks) {
                TermPacksView()
            }
            .navigationDestination(isPresented: $showLearningLab) {
                LearningHubView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showLearningLab = true } label: {
                            Label("Learning Lab", systemImage: "graduationcap.fill")
                        }
                        Button { showBrowse = true } label: {
                            Label("Browse by Category", systemImage: "square.grid.2x2")
                        }
                        Button { showCompare = true } label: {
                            Label("Compare Terms", systemImage: "rectangle.split.2x1")
                        }
                        Button { showPacks = true } label: {
                            Label("Term Packs", systemImage: "shippingbox")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.appPrimary)
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
    }

    private var librarySegmentPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LibrarySection.allCases) { item in
                    Button {
                        FeedbackManager.lightTap()
                        withAnimation(.easeInOut(duration: 0.25)) {
                            section = item
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: item.icon)
                            Text(item.rawValue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .foregroundStyle(section == item ? Color.appTextPrimary : Color.appTextSecondary)
                        .background(
                            Capsule().fill(
                                section == item
                                    ? AnyShapeStyle(AppVisualStyle.accentBarGradient)
                                    : AnyShapeStyle(Color.appSurface.opacity(0.88))
                            )
                        )
                        .overlay(
                            Capsule().stroke(Color.white.opacity(section == item ? 0.22 : 0.08), lineWidth: 1)
                        )
                    }
                    .frame(minHeight: 40)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var navigationTitle: String {
        switch section {
        case .history: return "Search History"
        case .insights: return "Term Insights"
        case .practice: return "Practice"
        case .favorites: return "Favorites"
        }
    }
}
