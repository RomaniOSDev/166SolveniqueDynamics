import SwiftUI

struct HomeHeroIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.appPrimary.opacity(0.35), .clear],
                        center: .center,
                        startRadius: 8,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)

            Canvas { context, size in
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.55)
                var scale = Path()
                scale.move(to: CGPoint(x: center.x, y: size.height * 0.15))
                scale.addLine(to: CGPoint(x: center.x, y: center.y))
                scale.addLine(to: CGPoint(x: size.width * 0.22, y: size.height * 0.88))
                scale.move(to: CGPoint(x: center.x, y: center.y))
                scale.addLine(to: CGPoint(x: size.width * 0.78, y: size.height * 0.88))
                context.stroke(scale, with: .color(.white.opacity(0.9)), lineWidth: 3)

                let leftPan = CGRect(x: size.width * 0.14, y: size.height * 0.82, width: 28, height: 8)
                let rightPan = CGRect(x: size.width * 0.64, y: size.height * 0.82, width: 28, height: 8)
                context.fill(Path(ellipseIn: leftPan), with: .color(Color.appPrimary))
                context.fill(Path(ellipseIn: rightPan), with: .color(Color.appPrimary))

                let book = CGRect(x: size.width * 0.38, y: size.height * 0.42, width: 36, height: 44)
                context.fill(
                    Path(roundedRect: book, cornerRadius: 4),
                    with: .color(Color.appAccent.opacity(0.85))
                )
                context.stroke(
                    Path(roundedRect: book, cornerRadius: 4),
                    with: .color(.white.opacity(0.5)),
                    lineWidth: 1
                )
            }
            .frame(width: 120, height: 110)
        }
    }
}

struct TermSpotlightIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.appPrimary.opacity(0.2))
                .frame(width: 88, height: 100)
            VStack(spacing: 6) {
                Image(systemName: "doc.text.fill")
                    .font(.title)
                    .foregroundStyle(Color.appPrimary)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.appTextSecondary.opacity(0.5))
                    .frame(width: 56, height: 4)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.appTextSecondary.opacity(0.35))
                    .frame(width: 44, height: 4)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.appTextSecondary.opacity(0.35))
                    .frame(width: 50, height: 4)
            }
        }
    }
}

struct QuickActionIllustration: View {
    let symbol: String
    let accent: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.2))
                .frame(width: 52, height: 52)
            Image(systemName: symbol)
                .font(.title2.weight(.semibold))
                .foregroundStyle(accent)
        }
    }
}

struct CategoryMiniIllustration: View {
    let category: LegalTermCategory

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface, Color.appBackground.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: category.iconName)
                .font(.title2)
                .foregroundStyle(Color.appPrimary)
        }
        .frame(width: 64, height: 64)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct StreakRingIllustration: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appBackground.opacity(0.6), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(colors: [.appPrimary, .appAccent], startPoint: .top, endPoint: .bottom),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundStyle(Color.appAccent)
        }
        .frame(width: 64, height: 64)
    }
}
