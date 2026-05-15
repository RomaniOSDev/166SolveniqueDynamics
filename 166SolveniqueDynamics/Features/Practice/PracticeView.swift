import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var deck: [LegalTerm] = []
    @State private var index = 0
    @State private var revealed = false
    @State private var sessionCount = 0
    @State private var useWeakDeck = false

    private var current: LegalTerm? {
        guard index < deck.count else { return nil }
        return deck[index]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SectionHeaderView(
                    title: "Practice Mode",
                    subtitle: useWeakDeck ? "Reviewing your weak terms deck." : "Reveal definitions at your pace — no scores or penalties.",
                    icon: "brain.head.profile"
                )
                practiceModePicker
                if !LearningEngine.weakTermNames(store: store).isEmpty {
                    NavigationLink {
                        WeakTermsPracticeView()
                    } label: {
                        ActionRowCell(
                            title: "Weak Terms Deck",
                            icon: "exclamationmark.triangle.fill",
                            trailingIcon: "chevron.right"
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                }
                if let term = current {
                    Text("Card \(index + 1) of \(deck.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appAccent)
                    PracticeFlashcardCell(
                        termName: term.name,
                        revealed: revealed,
                        brief: revealed ? term.briefDefinition : nil,
                        example: revealed ? term.usageExample : nil
                    )
                    .padding(.horizontal, 16)
                    .animation(.easeInOut(duration: 0.3), value: revealed)
                    controls
                } else {
                    finishedState
                }
            }
            .padding(.vertical, 16)
            .padding(.bottom, 24)
        }
        .onAppear(perform: startNewDeck)
    }

    private var controls: some View {
        VStack(spacing: 12) {
            if !revealed {
                Button {
                    FeedbackManager.lightTap()
                    withAnimation { revealed = true }
                } label: {
                    Text("Reveal Definition")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 16)
            } else {
                Button {
                    FeedbackManager.mediumTap()
                    store.recordPracticeCardReviewed()
                    store.recordTermViewed(current?.name ?? "")
                    nextCard()
                } label: {
                    Text("Got It")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 16)

                Button {
                    FeedbackManager.lightTap()
                    if let name = current?.name {
                        store.recordPracticeAgain(name)
                    }
                    nextCard()
                } label: {
                    Text("Review Again Later")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.appTextPrimary)
                }
                .frame(minHeight: 44)
            }
        }
    }

    private var finishedState: some View {
        VStack(spacing: 16) {
            EmptyStateView(
                icon: "checkmark.circle",
                title: "Session Complete",
                message: "You reviewed \(sessionCount) cards this session."
            )
            Button {
                store.completePracticeSession()
                startNewDeck()
            } label: {
                Text("Start New Session")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 16)
        }
    }

    private var practiceModePicker: some View {
        Picker("Deck", selection: $useWeakDeck) {
            Text("Random").tag(false)
            Text("Weak Terms").tag(true)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .onChange(of: useWeakDeck) { _ in
            FeedbackManager.lightTap()
            startNewDeck()
        }
    }

    private func startNewDeck() {
        if useWeakDeck {
            let weak = LearningEngine.weakTermNames(store: store)
            deck = weak.compactMap { LegalGlossary.term(named: $0, enabledPacks: store.enabledPackIds) }.shuffled()
        } else {
            let active = LegalGlossary.activeTerms(enabledPacks: store.enabledPackIds).shuffled()
            deck = Array(active.prefix(min(10, active.count)))
        }
        index = 0
        revealed = false
        sessionCount = 0
    }

    private func nextCard() {
        sessionCount += 1
        revealed = false
        if index + 1 < deck.count {
            index += 1
        } else {
            index = deck.count
        }
    }
}
