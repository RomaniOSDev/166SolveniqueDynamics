import SwiftUI

struct Feature2View: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel: Feature2ViewModel
    private let embedded: Bool

    init(store: AppDataStore = .shared, embedded: Bool = false) {
        self.embedded = embedded
        _viewModel = StateObject(wrappedValue: Feature2ViewModel(store: store))
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        content
            .modifier(Feature2ChromeModifier(
                embedded: embedded,
                isEmpty: viewModel.isEmpty,
                showClearAlert: $viewModel.showClearAlert,
                onClearTapped: { viewModel.showClearAlert = true },
                onClearConfirmed: { viewModel.clearHistory() }
            ))
    }

    private var content: some View {
        Group {
            if viewModel.isEmpty {
                ScrollView {
                    EmptyStateView(
                        icon: "clock.arrow.circlepath",
                        title: "Search History",
                        message: "No terms viewed yet. Start exploring legal definitions."
                    )
                    .padding(16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.historyItems, id: \.name) { item in
                            historyBlock(item)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    @ViewBuilder
    private func historyBlock(_ item: (name: String, term: LegalTerm?, accessed: Date?)) -> some View {
        let isExpanded = viewModel.expandedTerms.contains(item.name)
        VStack(spacing: 0) {
            Button {
                viewModel.toggleExpanded(item.name)
            } label: {
                HistoryCardCell(
                    name: item.name,
                    brief: item.term?.briefDefinition,
                    dateText: item.accessed.map { Self.dateFormatter.string(from: $0) },
                    isExpanded: isExpanded
                )
            }
            .buttonStyle(.plain)

            if isExpanded, let term = item.term {
                VStack(alignment: .leading, spacing: 10) {
                    Text(term.fullDefinition)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text(term.relatedNotes)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    HStack(spacing: 12) {
                        Button {
                            viewModel.toggleFavorite(item.name)
                        } label: {
                            Label("Favorite", systemImage: "star")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(Color.appPrimary)
                        Button(role: .destructive) {
                            viewModel.delete(item.name)
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
                .appListCard(padding: 14)
                .padding(.top, -4)
            }
        }
        .scaleEffect(viewModel.pulseTermID == item.name ? 1.01 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.pulseTermID)
    }
}

private struct Feature2ChromeModifier: ViewModifier {
    let embedded: Bool
    let isEmpty: Bool
    @Binding var showClearAlert: Bool
    let onClearTapped: () -> Void
    let onClearConfirmed: () -> Void

    func body(content: Content) -> some View {
        Group {
            if embedded {
                content
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        embeddedFooter
                    }
            } else {
                NavigationStack {
                    ZStack {
                        AppBackgroundView()
                        content
                    }
                    .navigationTitle("Search History")
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) { clearButton }
                    }
                }
            }
        }
        .alert("Clear History?", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) { FeedbackManager.lightTap() }
            Button("Clear", role: .destructive) { onClearConfirmed() }
        } message: {
            Text("This will remove all viewed terms from your history.")
        }
    }

    private var clearButton: some View {
        Button("Clear History") {
            FeedbackManager.lightTap()
            onClearTapped()
        }
        .foregroundStyle(Color.appPrimary)
        .font(.body.weight(.semibold))
        .disabled(isEmpty)
    }

    private var embeddedFooter: some View {
        clearButton
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.appSurface.opacity(0.95))
            .overlay(alignment: .top) {
                Divider().overlay(Color.white.opacity(0.08))
            }
    }
}
