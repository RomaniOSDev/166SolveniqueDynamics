import SwiftUI

struct WeakTermsPracticeView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var deck: [LegalTerm] = []
    @State private var index = 0
    @State private var revealed = false

    private var weakNames: [String] {
        LearningEngine.weakTermNames(store: store)
    }

    private var current: LegalTerm? {
        guard index < deck.count else { return nil }
        return deck[index]
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if weakNames.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "No Weak Terms Yet",
                    message: "Mark cards as \"Review Again\" in Practice or explore more terms to build a weak list."
                )
                .padding(16)
            } else if let term = current {
                ScrollView {
                    VStack(spacing: 20) {
                        SectionHeaderView(
                            title: "Weak Terms Deck",
                            subtitle: "\(weakNames.count) terms need extra attention",
                            icon: "exclamationmark.triangle.fill"
                        )
                        Text("Card \(index + 1) of \(deck.count)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                        PracticeFlashcardCell(
                            termName: term.name,
                            revealed: revealed,
                            brief: revealed ? term.briefDefinition : nil,
                            example: revealed ? term.usageExample : nil
                        )
                        controls(for: term)
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            } else {
                EmptyStateView(
                    icon: "flag.checkered",
                    title: "Deck Complete",
                    message: "You reviewed all weak terms in this session."
                )
                .padding(16)
                Button {
                    rebuildDeck()
                } label: {
                    Text("Practice Again")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("Weak Terms")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear(perform: rebuildDeck)
    }

    private func controls(for term: LegalTerm) -> some View {
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
            } else {
                Button {
                    FeedbackManager.mediumTap()
                    store.recordPracticeCardReviewed()
                    store.recordTermViewed(term.name)
                    nextCard()
                } label: {
                    Text("Got It")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    FeedbackManager.lightTap()
                    store.recordPracticeAgain(term.name)
                    nextCard()
                } label: {
                    Text("Still Weak")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.appTextPrimary)
                }
                .frame(minHeight: 44)
            }
        }
    }

    private func rebuildDeck() {
        deck = weakNames.compactMap { LegalGlossary.term(named: $0, enabledPacks: store.enabledPackIds) }
        index = 0
        revealed = false
    }

    private func nextCard() {
        revealed = false
        if index + 1 < deck.count {
            index += 1
        } else {
            index = deck.count
        }
    }
}

struct SpacedReviewListView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        ZStack {
            AppBackgroundView()
            if store.dueReviewTermNames.isEmpty {
                EmptyStateView(
                    icon: "bell.slash",
                    title: "Nothing Due Today",
                    message: "Favorite terms will return for spaced review on days 1, 3, and 7."
                )
                .padding(16)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(
                            title: "Spaced Review",
                            subtitle: "Intervals: 1 → 3 → 7 days after each review",
                            icon: "calendar.badge.clock"
                        )
                        ForEach(store.dueReviewTermNames, id: \.self) { name in
                            if let term = LegalGlossary.term(named: name, enabledPacks: store.enabledPackIds) {
                                NavigationLink {
                                    TermDetailView(term: term)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(term.name)
                                                .font(.headline)
                                                .foregroundStyle(Color.appTextPrimary)
                                            if let schedule = store.termReviewSchedules[name] {
                                                Text("Stage \(schedule.stage + 1) · review today")
                                                    .font(.caption)
                                                    .foregroundStyle(Color.appTextSecondary)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(Color.appPrimary)
                                    }
                                    .appListCard()
                                }
                                .buttonStyle(.plain)
                                .simultaneousGesture(TapGesture().onEnded { FeedbackManager.lightTap() })
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Due for Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
