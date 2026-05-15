import SwiftUI

struct MiniQuizView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var questions: [MiniQuizQuestion] = []
    @State private var index = 0
    @State private var selectedIndex: Int?
    @State private var correctCount = 0
    @State private var wrongTerms: [String] = []
    @State private var finished = false

    private var current: MiniQuizQuestion? {
        guard index < questions.count else { return nil }
        return questions[index]
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if finished {
                resultsView
            } else if questions.isEmpty {
                EmptyStateView(
                    icon: "questionmark.circle",
                    title: "Not Enough Terms",
                    message: "Enable more packs to build a mini quiz."
                )
                .padding(16)
            } else if let question = current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        TagPill(text: question.mode.rawValue, tint: .appAccent)
                        Text("Question \(index + 1) of \(questions.count)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appTextSecondary)
                        Text(question.prompt)
                            .font(.title3.bold())
                            .foregroundStyle(Color.appTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                            .appHeroCard()

                        ForEach(Array(question.options.enumerated()), id: \.offset) { offset, option in
                            optionButton(option: option, offset: offset, question: question)
                        }

                        if selectedIndex != nil {
                            Button {
                                advance()
                            } label: {
                                Text(index + 1 < questions.count ? "Next Question" : "See Results")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Mini Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear(perform: startQuiz)
    }

    private func optionButton(option: String, offset: Int, question: MiniQuizQuestion) -> some View {
        Button {
            guard selectedIndex == nil else { return }
            FeedbackManager.lightTap()
            selectedIndex = offset
            if offset == question.correctIndex {
                correctCount += 1
                FeedbackManager.success()
            } else {
                if let name = question.relatedTermName {
                    wrongTerms.append(name)
                }
                FeedbackManager.warning()
            }
        } label: {
            HStack {
                Text(option)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(optionTextColor(offset: offset, question: question))
                    .multilineTextAlignment(.leading)
                Spacer()
                if let selectedIndex {
                    if offset == question.correctIndex {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.appPrimary)
                    } else if offset == selectedIndex {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red.opacity(0.85))
                    }
                }
            }
            .appListCard(padding: 14)
        }
        .buttonStyle(.plain)
        .disabled(selectedIndex != nil)
    }

    private func optionTextColor(offset: Int, question: MiniQuizQuestion) -> Color {
        guard let selectedIndex else { return .appTextPrimary }
        if offset == question.correctIndex { return .appPrimary }
        if offset == selectedIndex { return .red.opacity(0.9) }
        return .appTextSecondary
    }

    private var resultsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                let percent = questions.isEmpty ? 0 : Int((Double(correctCount) / Double(questions.count)) * 100)
                EmptyStateView(
                    icon: percent >= 80 ? "star.fill" : "chart.bar.fill",
                    title: "\(percent)% Correct",
                    message: "You answered \(correctCount) of \(questions.count) questions correctly."
                )

                if !wrongTerms.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeaderView(title: "Review These Terms", icon: "arrow.counterclockwise")
                        ForEach(Array(Set(wrongTerms)), id: \.self) { name in
                            if let term = LegalGlossary.term(named: name, enabledPacks: store.enabledPackIds) {
                                NavigationLink {
                                    TermDetailView(term: term)
                                } label: {
                                    ActionRowCell(title: term.name, icon: term.category.iconName, trailingIcon: "arrow.right")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .appCard(padding: 0, elevation: .raised)
                }

                Button {
                    startQuiz()
                } label: {
                    Text("Try Again")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }

    private func startQuiz() {
        questions = LearningEngine.buildMiniQuiz(enabledPacks: store.enabledPackIds, count: 5)
        index = 0
        selectedIndex = nil
        correctCount = 0
        wrongTerms = []
        finished = false
    }

    private func advance() {
        selectedIndex = nil
        if index + 1 < questions.count {
            index += 1
        } else {
            finished = true
        }
    }
}
