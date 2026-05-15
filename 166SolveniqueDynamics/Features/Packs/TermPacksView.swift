import SwiftUI

struct TermPacksView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        title: "Offline Term Packs",
                        subtitle: "All content stays on your device",
                        icon: "shippingbox.fill"
                    )
                    ForEach(LegalTermPack.allCases) { pack in
                        packRow(pack)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Term Packs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func packRow(_ pack: LegalTermPack) -> some View {
        let count = LegalGlossary.allTerms.filter { $0.packId == pack.rawValue }.count
        let enabled = store.isPackEnabled(pack)

        return Button {
            guard pack != .core else { return }
            FeedbackManager.lightTap()
            store.togglePack(pack)
        } label: {
            HStack {
                PackToggleCell(pack: pack, termCount: count, enabled: enabled)
                if pack != .core {
                    Image(systemName: enabled ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(enabled ? Color.appPrimary : Color.appTextSecondary)
                        .padding(.trailing, 8)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(pack == .core)
    }
}
