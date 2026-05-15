import SwiftUI

struct Feature1View: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel: Feature1ViewModel
    @State private var navigationPath = NavigationPath()
    @State private var showBrowse = false
    @State private var showCompare = false

    init(store: AppDataStore = .shared) {
        _viewModel = StateObject(wrappedValue: Feature1ViewModel(store: store))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 14) {
                        CustomSearchBar(
                            text: $viewModel.searchText,
                            placeholder: "Enter legal term",
                            shakeTrigger: viewModel.shakeTrigger
                        ) {
                            viewModel.results = []
                            viewModel.validationError = nil
                        }
                        if let error = viewModel.validationError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal, 16)
                        }
                        filterBar
                        compareBar
                        resultsSection
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(for: LegalTerm.self) { term in
                TermDetailView(term: term)
            }
            .navigationDestination(isPresented: $showBrowse) {
                BrowseByCategoryView()
            }
            .navigationDestination(isPresented: $showCompare) {
                CompareTermsView()
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    toolbarButton(title: "Recent", icon: "clock.arrow.circlepath", active: viewModel.showRecent) {
                        viewModel.showFavorites = false
                        viewModel.showRecent.toggle()
                        viewModel.searchText = ""
                        viewModel.results = []
                    }
                    toolbarButton(title: "Browse", icon: "square.grid.2x2", active: false) {
                        showBrowse = true
                    }
                    toolbarButton(title: "Favorites", icon: "star.fill", active: viewModel.showFavorites) {
                        viewModel.showRecent = false
                        viewModel.showFavorites.toggle()
                        viewModel.searchText = ""
                        viewModel.results = []
                    }
                }
            }
        }
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Filters", subtitle: "Refine your search", icon: "line.3.horizontal.decrease.circle")
                .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SearchFieldFilter.allCases) { filter in
                        filterChip(title: filter.rawValue, selected: viewModel.fieldFilter == filter) {
                            viewModel.fieldFilter = filter
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(title: "All", selected: viewModel.categoryFilter == nil) {
                        viewModel.categoryFilter = nil
                    }
                    ForEach(LegalTermCategory.allCases) { cat in
                        filterChip(title: cat.displayName, selected: viewModel.categoryFilter == cat) {
                            viewModel.categoryFilter = cat
                        }
                    }
                    ForEach(SearchSortOption.allCases) { sort in
                        filterChip(title: sort.rawValue, selected: viewModel.sortOption == sort) {
                            viewModel.sortOption = sort
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func filterChip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .foregroundStyle(selected ? Color.appTextPrimary : Color.appTextSecondary)
                .background(
                    Capsule().fill(
                        selected
                            ? AnyShapeStyle(AppVisualStyle.accentBarGradient)
                            : AnyShapeStyle(Color.appSurface.opacity(0.9))
                    )
                )
                .overlay(
                    Capsule().stroke(Color.white.opacity(selected ? 0.2 : 0.08), lineWidth: 1)
                )
        }
        .frame(minHeight: 36)
    }

    @ViewBuilder
    private var compareBar: some View {
        if !store.compareTermNames.isEmpty {
            Button {
                showCompare = true
                FeedbackManager.lightTap()
            } label: {
                ActionRowCell(
                    title: "Compare \(store.compareTermNames.count) selected terms",
                    icon: "rectangle.split.2x1",
                    trailingIcon: "arrow.right.circle.fill"
                )
                .appHeroCard(padding: 0, highlighted: true)
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var resultsSection: some View {
        if viewModel.isEmptyState {
            EmptyStateView(
                icon: "magnifyingglass",
                title: "Search Legal Terms",
                message: "Enter a term, apply filters, or browse by legal category."
            )
        } else if viewModel.displayTerms.isEmpty {
            EmptyStateView(
                icon: "doc.text.magnifyingglass",
                title: "No Results",
                message: "Try another keyword or enable more term packs in Library."
            )
        } else {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeaderView(
                    title: "Results",
                    subtitle: "\(viewModel.displayTerms.count) terms",
                    icon: "list.bullet.rectangle"
                )
                .padding(.horizontal, 16)
                ForEach(viewModel.displayTerms) { term in
                    Button {
                        FeedbackManager.lightTap()
                        viewModel.selectTerm(term)
                        navigationPath.append(term)
                    } label: {
                        TermCardCell(
                            term: term,
                            viewCount: store.termViewCounts[term.name],
                            isFavorite: store.isFavorite(term.name),
                            isInCompare: store.isInCompare(term.name),
                            highlighted: viewModel.pulseTermID == term.id
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .scaleEffect(viewModel.pulseTermID == term.id ? 1.02 : 1)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.pulseTermID)
                }
            }
        }
    }

    private func toolbarButton(title: String, icon: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(active ? Color.appPrimary : Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(minHeight: 44)
    }
}
