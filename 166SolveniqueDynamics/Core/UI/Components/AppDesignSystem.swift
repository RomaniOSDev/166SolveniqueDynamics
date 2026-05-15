import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?
    var icon: String?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appPrimary.opacity(0.35), Color.appAccent.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

struct TagPill: View {
    let text: String
    var tint: Color = .appAccent

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.28), tint.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(Capsule().stroke(tint.opacity(0.35), lineWidth: 0.5))
    }
}

struct IconBadge: View {
    let systemName: String
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary.opacity(0.4), Color.appAccent.opacity(0.22)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            Image(systemName: systemName)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(Color.appPrimary)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            IconBadge(systemName: icon, size: 72)
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .appHeroCard(padding: 20)
    }
}

struct CustomSearchBar: View {
    @Binding var text: String
    let placeholder: String
    var shakeTrigger: Int = 0
    var onClear: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
            TextField(placeholder, text: $text)
                .foregroundStyle(Color.appTextPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .shake(trigger: shakeTrigger)
            if !text.isEmpty {
                Button {
                    FeedbackManager.lightTap()
                    text = ""
                    onClear?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.appTextSecondary)
                }
                .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .appHeroCard(padding: 0, highlighted: false)
        .overlay(
            RoundedRectangle(cornerRadius: AppVisualStyle.cardRadius, style: .continuous)
                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

struct ProgressBannerView: View {
    let title: String
    let subtitle: String
    let progress: Double
    var icon: String = "target"
    var completeLabel: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.appPrimary)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                if let completeLabel, progress >= 1 {
                    TagPill(text: completeLabel, tint: .appPrimary)
                } else {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.appBackground.opacity(0.55))
                    Capsule()
                        .fill(AppVisualStyle.accentBarGradient)
                        .frame(width: max(8, geo.size.width * progress))
                }
            }
            .frame(height: 8)
        }
        .appCard(elevation: .raised)
        .padding(.horizontal, 16)
    }
}

struct ActionRowCell: View {
    let title: String
    let icon: String
    var trailingIcon: String = "chevron.right"
    var tint: Color = .appPrimary
    var destructive: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(destructive ? .red : tint)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [(destructive ? Color.red : tint).opacity(0.28), (destructive ? Color.red : tint).opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(destructive ? .red : Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Image(systemName: trailingIcon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minHeight: 56)
    }
}

struct MetricTileView: View {
    let value: String
    let label: String
    var icon: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(Color.appPrimary)
            }
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color.appAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(padding: 12, elevation: .raised)
    }
}
