import SwiftUI

struct Feature3View: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel: Feature3ViewModel
    @State private var shareText: ShareableText?
    private let embedded: Bool

    init(store: AppDataStore = .shared, embedded: Bool = false) {
        self.embedded = embedded
        _viewModel = StateObject(wrappedValue: Feature3ViewModel(store: store))
    }

    var body: some View {
        Group {
            if embedded {
                insightsContent(showEmbeddedFooter: true)
            } else {
                NavigationStack {
                    ZStack {
                        AppBackgroundView()
                        insightsContent(showEmbeddedFooter: false)
                    }
                    .navigationTitle("Term Insights")
                    .toolbar { ToolbarItem(placement: .bottomBar) { refreshButton } }
                }
            }
        }
        .sheet(item: $shareText) { ShareSheet(items: [$0.text]) }
    }

    private func insightsContent(showEmbeddedFooter: Bool) -> some View {
        VStack(spacing: 12) {
            Picker("Period", selection: $viewModel.period) {
                ForEach(InsightPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .onChange(of: viewModel.period) { _ in FeedbackManager.lightTap() }

            if !store.lastUpdatedDate.isEmpty {
                Text("Last updated: \(store.lastUpdatedDate)")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            if viewModel.isEmpty {
                ScrollView {
                    EmptyStateView(
                        icon: "book.circle",
                        title: "No Terms Viewed Yet",
                        message: "Start exploring legal terms to build your insights."
                    )
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        SectionHeaderView(
                            title: "Top Terms",
                            subtitle: viewModel.period.rawValue,
                            icon: "chart.bar.fill"
                        )
                        .padding(.horizontal, 16)
                        ForEach(Array(viewModel.insights.enumerated()), id: \.element.term) { index, item in
                            InsightStatCell(term: item.term, count: item.count, rank: index + 1)
                                .padding(.horizontal, 16)
                                .contextMenu {
                                    Button {
                                        shareText = ShareableText(text: "\(item.term): \(item.count) views")
                                    } label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    if !store.isFavorite(item.term) {
                                        Button {
                                            store.toggleFavorite(item.term)
                                            FeedbackManager.success()
                                        } label: {
                                            Label("Save", systemImage: "star")
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }

            if showEmbeddedFooter {
                refreshButton
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var refreshButton: some View {
        Button {
            viewModel.refresh()
        } label: {
            Label("Refresh Insights", systemImage: "arrow.clockwise")
                .font(.body.weight(.semibold))
        }
        .foregroundStyle(Color.appPrimary)
        .frame(minHeight: 44)
    }
}
