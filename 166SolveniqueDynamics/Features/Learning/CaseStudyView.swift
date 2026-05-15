import SwiftUI

struct CaseStudyView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var questionIndex = 0
    @State private var selections: [Int?] = []
    @State private var showResults = false

    private var study: CaseStudy? {
        LearningContent.caseStudyOfTheDay(enabledPacks: store.enabledPackIds)
    }

    private var currentQuestion: CaseStudyQuestion? {
        guard let study, questionIndex < study.questions.count else { return nil }
        return study.questions[questionIndex]
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if let study {
                if showResults {
                    resultsView(study: study)
                } else {
                    activeView(study: study)
                }
            } else {
                EmptyStateView(
                    icon: "doc.text",
                    title: "No Case Available",
                    message: "Enable more term packs to unlock today's case study."
                )
                .padding(16)
            }
        }
        .navigationTitle("Case Study")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            if let study {
                selections = Array(repeating: nil, count: study.questions.count)
            }
        }
    }

    private func activeView(study: CaseStudy) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TagPill(text: "Case Study of the Day", tint: .appAccent)
                    if store.isCaseStudyCompletedToday() {
                        TagPill(text: "Completed", tint: .appPrimary)
                    }
                }

                Text(study.title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)

                Text(study.narrative)
                    .font(.body)
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .appCard(elevation: .raised)

                if let question = currentQuestion {
                    Text("Question \(questionIndex + 1) of \(study.questions.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appTextSecondary)
                    Text(question.prompt)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    ForEach(Array(question.options.enumerated()), id: \.offset) { offset, option in
                        Button {
                            FeedbackManager.lightTap()
                            selections[questionIndex] = offset
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(
                                        selections[questionIndex] == offset ? Color.appTextPrimary : Color.appTextSecondary
                                    )
                                Spacer()
                                if selections[questionIndex] == offset {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.appPrimary)
                                }
                            }
                            .appListCard(padding: 14)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        advanceQuestion(study: study)
                    } label: {
                        Text(questionIndex + 1 < study.questions.count ? "Next Question" : "Submit Answers")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(selections[questionIndex] == nil)
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }

    private func resultsView(study: CaseStudy) -> some View {
        let correct = zip(study.questions, selections).filter { question, selection in
            guard let selection, selection < question.options.count else { return false }
            return question.options[selection] == question.correctTermName
        }.count

        return ScrollView {
            VStack(spacing: 16) {
                EmptyStateView(
                    icon: "doc.text.magnifyingglass",
                    title: "\(correct)/\(study.questions.count) Correct",
                    message: "Great work analyzing \"\(study.title)\"."
                )

                ForEach(study.questions) { question in
                    reviewRow(question: question, study: study)
                }

                Button {
                    questionIndex = 0
                    selections = Array(repeating: nil, count: study.questions.count)
                    showResults = false
                } label: {
                    Text("Review Case Again")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private func reviewRow(question: CaseStudyQuestion, study: CaseStudy) -> some View {
        let qIndex = study.questions.firstIndex(where: { $0.id == question.id }) ?? 0
        let selection = selections[qIndex]
        let isCorrect = selection.map { question.options[$0] == question.correctTermName } ?? false

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(isCorrect ? Color.appPrimary : .red.opacity(0.85))
                Text(question.prompt)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            Text("Answer: \(question.correctTermName)")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
            if let term = LegalGlossary.term(named: question.correctTermName, enabledPacks: store.enabledPackIds) {
                NavigationLink {
                    TermDetailView(term: term)
                } label: {
                    ActionRowCell(title: "Open \(term.name)", icon: "arrow.right.circle", trailingIcon: "chevron.right")
                }
                .buttonStyle(.plain)
            }
        }
        .appCard(elevation: .raised)
    }

    private func advanceQuestion(study: CaseStudy) {
        FeedbackManager.lightTap()
        if questionIndex + 1 < study.questions.count {
            questionIndex += 1
        } else {
            showResults = true
            store.markCaseStudyCompletedToday()
            FeedbackManager.success()
        }
    }
}
