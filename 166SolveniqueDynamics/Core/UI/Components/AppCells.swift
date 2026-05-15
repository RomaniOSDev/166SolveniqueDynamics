import SwiftUI

struct TermCardCell: View {
    let term: LegalTerm
    var viewCount: Int?
    var isFavorite: Bool = false
    var isInCompare: Bool = false
    var highlighted: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            IconBadge(systemName: term.category.iconName, size: 50)
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(term.name)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 4)
                    HStack(spacing: 6) {
                        if isInCompare {
                            Image(systemName: "rectangle.split.2x1.fill")
                                .font(.caption)
                                .foregroundStyle(Color.appAccent)
                        }
                        if isFavorite {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(Color.appPrimary)
                        }
                    }
                }
                HStack(spacing: 6) {
                    TagPill(text: term.category.displayName)
                    if term.pack != .core {
                        TagPill(text: term.pack.displayName, tint: .appPrimary)
                    }
                    if let viewCount, viewCount > 0 {
                        TagPill(text: "\(viewCount) views", tint: .appTextSecondary)
                    }
                }
                Text(term.briefDefinition)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextSecondary.opacity(0.8))
                .padding(.top, 4)
        }
        .appListCard(highlighted: highlighted)
    }
}

struct CategoryCardCell: View {
    let category: LegalTermCategory
    let termCount: Int

    var body: some View {
        VStack(spacing: 12) {
            IconBadge(systemName: category.iconName, size: 56)
            Text(category.displayName)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text("\(termCount) terms")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 130)
        .appCard(padding: 14, elevation: .raised)
    }
}

struct HistoryCardCell: View {
    let name: String
    let brief: String?
    let dateText: String?
    let isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                IconBadge(systemName: "clock.arrow.circlepath", size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    if let brief {
                        Text(brief)
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(isExpanded ? nil : 1)
                    }
                    if let dateText {
                        Text(dateText)
                            .font(.caption)
                            .foregroundStyle(Color.appAccent)
                    }
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .appListCard(padding: 14, highlighted: isExpanded)
    }
}

struct InsightStatCell: View {
    let term: String
    let count: Int
    var rank: Int?

    var body: some View {
        HStack(spacing: 14) {
            if let rank {
                Text("\(rank)")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 28, height: 28)
                    .background(Color.appPrimary.opacity(0.35))
                    .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(term)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("Looked up \(count) time\(count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
            Text("\(count)")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appAccent)
        }
        .appListCard(padding: 14)
    }
}

struct AchievementBadgeCell: View {
    let title: String
    let description: String
    let iconName: String
    let unlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(unlocked ? Color.appPrimary : Color.appTextSecondary)
                .frame(height: 32)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(description)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 128)
        .appCard(padding: 12, elevation: .raised, highlighted: unlocked)
        .opacity(unlocked ? 1 : 0.65)
    }
}

struct HighlightFeatureCard: View {
    let icon: String
    let badge: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            IconBadge(systemName: icon, size: 52)
            VStack(alignment: .leading, spacing: 6) {
                TagPill(text: badge, tint: .appAccent)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.appTextSecondary)
        }
        .appHeroCard(highlighted: true)
        .padding(.horizontal, 16)
    }
}

struct PracticeFlashcardCell: View {
    let termName: String
    let revealed: Bool
    let brief: String?
    let example: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TagPill(text: revealed ? "Definition" : "Term", tint: revealed ? .appAccent : .appPrimary)
            Text(termName)
                .font(.title.bold())
                .foregroundStyle(Color.appTextPrimary)
            if revealed, let brief, let example {
                VStack(alignment: .leading, spacing: 8) {
                    Text(brief)
                        .font(.body)
                        .foregroundStyle(Color.appTextPrimary)
                    Text(example)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Text("Tap Reveal to see the definition")
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appHeroCard()
    }
}

struct FavoriteNoteCell: View {
    let term: LegalTerm
    @Binding var note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: "star.fill", size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(term.name)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text(term.briefDefinition)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                }
            }
            TextField("Personal note…", text: $note, axis: .vertical)
                .lineLimit(2...4)
                .foregroundStyle(Color.appTextPrimary)
                .padding(12)
                .background(Color.appBackground.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .appListCard(padding: 14)
    }
}

struct PackToggleCell: View {
    let pack: LegalTermPack
    let termCount: Int
    let enabled: Bool

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(systemName: pack == .core ? "books.vertical.fill" : "shippingbox.fill", size: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(pack.displayName)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Text(pack.description)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                Text("\(termCount) terms")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
            }
            Spacer()
            if pack == .core {
                TagPill(text: "Always On", tint: .appPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(padding: 14, elevation: .raised, highlighted: enabled)
    }
}
