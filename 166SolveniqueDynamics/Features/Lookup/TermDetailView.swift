import SwiftUI

struct TermDetailView: View {
    let term: LegalTerm
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var bannerManager: AchievementBannerManager
    @State private var showSuccessCheck = false
    @State private var noteText = ""
    @State private var compareMessage: String?
    @State private var usePlainEnglish = false

    private var related: [LegalTerm] {
        LegalGlossary.relatedTerms(for: term, enabledPacks: store.enabledPackIds)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerCard
                    definitionSection
                    detailSection(icon: "quote.bubble", title: "Usage", body: term.usageExample)
                    detailSection(icon: "note.text", title: "Notes", body: term.relatedNotes)
                    if !related.isEmpty { seeAlsoSection }
                    if store.isFavorite(term.name) { noteSection }
                    compareSection
                }
                .padding(16)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .overlay { SuccessCheckmarkOverlay(isVisible: $showSuccessCheck) }
        .onAppear {
            noteText = store.note(for: term.name)
            store.recordTermViewed(term.name)
            bannerManager.showIfNeeded(store.checkAchievements())
        }
        .alert("Compare", isPresented: Binding(
            get: { compareMessage != nil },
            set: { if !$0 { compareMessage = nil } }
        )) {
            Button("OK", role: .cancel) { compareMessage = nil }
        } message: {
            Text(compareMessage ?? "")
        }
    }

    private var headerCard: some View {
        HStack(alignment: .top, spacing: 14) {
            IconBadge(systemName: term.category.iconName, size: 56)
            VStack(alignment: .leading, spacing: 8) {
                Text(term.name)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)
                HStack(spacing: 6) {
                    TagPill(text: term.category.displayName)
                    if term.pack != .core {
                        TagPill(text: term.pack.displayName, tint: .appPrimary)
                    }
                }
            }
            Spacer()
            Button {
                store.toggleFavorite(term.name)
                FeedbackManager.success()
                SuccessCheckmarkOverlay.flash(binding: $showSuccessCheck)
            } label: {
                Image(systemName: store.isFavorite(term.name) ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 44, height: 44)
            }
        }
        .appHeroCard()
    }

    private var definitionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionHeaderView(title: "Definition", icon: "text.alignleft")
                Spacer()
                Picker("Style", selection: $usePlainEnglish) {
                    Text("Legal").tag(false)
                    Text("Plain").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }
            Text(usePlainEnglish ? LearningContent.plainEnglish(for: term) : term.fullDefinition)
                .font(.body)
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .animation(.easeInOut(duration: 0.2), value: usePlainEnglish)
        }
        .appCard(elevation: .raised)
    }

    private func detailSection(icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: title, icon: icon)
            Text(body)
                .font(.body)
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appCard(elevation: .raised)
    }

    private var seeAlsoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "See Also", subtitle: "Related legal terms", icon: "link")
            ForEach(related) { relatedTerm in
                NavigationLink {
                    TermDetailView(term: relatedTerm)
                } label: {
                    ActionRowCell(title: relatedTerm.name, icon: relatedTerm.category.iconName, trailingIcon: "arrow.right")
                }
                .buttonStyle(.plain)
            }
        }
        .appCard(elevation: .raised)
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Personal Note", icon: "pencil.line")
            TextField("Add a note for this favorite…", text: $noteText, axis: .vertical)
                .lineLimit(2...5)
                .foregroundStyle(Color.appTextPrimary)
                .onChange(of: noteText) { store.setNote($0, for: term.name) }
        }
        .appCard(elevation: .raised)
    }

    private var compareSection: some View {
        Button {
            if store.isInCompare(term.name) {
                _ = store.toggleCompare(term.name)
                FeedbackManager.lightTap()
            } else if store.compareTermNames.count >= AppDataStore.maxCompareTerms {
                compareMessage = "You can compare up to \(AppDataStore.maxCompareTerms) terms."
                FeedbackManager.warning()
            } else {
                _ = store.toggleCompare(term.name)
                FeedbackManager.success()
            }
        } label: {
            ActionRowCell(
                title: store.isInCompare(term.name) ? "Remove from Compare" : "Add to Compare",
                icon: "rectangle.split.2x1",
                trailingIcon: store.isInCompare(term.name) ? "checkmark.circle.fill" : "plus.circle"
            )
        }
        .buttonStyle(.plain)
        .appCard(padding: 0)
    }
}
