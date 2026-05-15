import SwiftUI

struct TermInContextView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var index = 0
    @State private var options: [String] = []
    @State private var selected: String?
    @State private var score = 0
    @State private var answered = 0

    private var scenarios: [TermContextScenario] {
        LearningContent.activeScenarios(enabledPacks: store.enabledPackIds)
    }

    private var current: TermContextScenario? {
        guard index < scenarios.count else { return nil }
        return scenarios[index]
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if scenarios.isEmpty {
                EmptyStateView(
                    icon: "text.bubble",
                    title: "No Scenarios",
                    message: "Enable more term packs to unlock context scenarios."
                )
                .padding(16)
            } else if let scenario = current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        progressHeader
                        scenarioCard(scenario)
                        optionsGrid(scenario)
                        if selected != nil { feedbackSection(scenario) }
                        navigationButtons
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            } else {
                sessionSummary
            }
        }
        .navigationTitle("Term in Context")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear { loadScenario() }
        .onChange(of: index) { _ in loadScenario() }
    }

    private var progressHeader: some View {
        HStack {
            TagPill(text: "Scenario \(index + 1) of \(scenarios.count)", tint: .appAccent)
            Spacer()
            Text("Score \(score)/\(max(answered, 1))")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
        }
    }

    private func scenarioCard(_ scenario: TermContextScenario) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Read the situation", icon: "text.quote")
            Text(scenario.contextText)
                .font(.body)
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("Which legal term fits best?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appAccent)
        }
        .appHeroCard()
    }

    private func optionsGrid(_ scenario: TermContextScenario) -> some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                Button {
                    guard selected == nil else { return }
                    FeedbackManager.lightTap()
                    selected = option
                    answered += 1
                    if option == scenario.correctTermName {
                        score += 1
                        FeedbackManager.success()
                    } else {
                        FeedbackManager.warning()
                    }
                } label: {
                    HStack {
                        Text(option)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(optionColor(option, scenario: scenario))
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if selected != nil, option == scenario.correctTermName {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.appPrimary)
                        } else if selected == option, option != scenario.correctTermName {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red.opacity(0.85))
                        }
                    }
                    .appListCard(padding: 14)
                }
                .buttonStyle(.plain)
                .disabled(selected != nil)
            }
        }
    }

    private func optionColor(_ option: String, scenario: TermContextScenario) -> Color {
        guard let selected else { return .appTextPrimary }
        if option == scenario.correctTermName { return .appPrimary }
        if option == selected { return .red.opacity(0.9) }
        return .appTextSecondary
    }

    @ViewBuilder
    private func feedbackSection(_ scenario: TermContextScenario) -> some View {
        if let term = LegalGlossary.term(named: scenario.correctTermName, enabledPacks: store.enabledPackIds) {
            VStack(alignment: .leading, spacing: 8) {
                Text(scenario.hint)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                NavigationLink {
                    TermDetailView(term: term)
                } label: {
                    ActionRowCell(title: "View \(term.name)", icon: "arrow.right.circle", trailingIcon: "chevron.right")
                }
                .buttonStyle(.plain)
            }
            .appCard(elevation: .raised)
        }
    }

    private var navigationButtons: some View {
        Button {
            FeedbackManager.lightTap()
            advance()
        } label: {
            Text(index + 1 < scenarios.count ? "Next Scenario" : "Finish")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(selected == nil)
    }

    private var sessionSummary: some View {
        VStack(spacing: 16) {
            EmptyStateView(
                icon: "checkmark.seal.fill",
                title: "Session Complete",
                message: "You scored \(score) out of \(scenarios.count) scenarios."
            )
            .padding(16)
            Button {
                index = 0
                score = 0
                answered = 0
                loadScenario()
            } label: {
                Text("Play Again")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 16)
        }
    }

    private func loadScenario() {
        guard let scenario = current else { return }
        selected = nil
        options = LearningEngine.options(for: scenario, enabledPacks: store.enabledPackIds)
    }

    private func advance() {
        selected = nil
        if index + 1 < scenarios.count {
            index += 1
        } else {
            index = scenarios.count
        }
    }
}
