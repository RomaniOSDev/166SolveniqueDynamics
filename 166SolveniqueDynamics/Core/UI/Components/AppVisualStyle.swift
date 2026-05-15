import SwiftUI

/// Centralized visuals — single shadow layer, no blur stacks (scroll-friendly).
enum AppVisualStyle {
    static let cardRadius: CGFloat = 16

    static let surfaceGradient = LinearGradient(
        colors: [Color.appSurface, Color.appSurface.opacity(0.88)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.95),
            Color.appPrimary.opacity(0.12),
            Color.appBackground.opacity(0.9)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButtonGradient = LinearGradient(
        colors: [Color.appAccent, Color.appPrimary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentBarGradient = LinearGradient(
        colors: [Color.appPrimary, Color.appAccent],
        startPoint: .leading,
        endPoint: .trailing
    )

    static func cardShape(radius: CGFloat = cardRadius) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }
}

enum AppCardElevation {
    /// Scroll lists — gradient + rim only (no shadow).
    case flat
    /// Default cards — light depth.
    case raised
    /// Hero / featured — stronger rim, one shadow (avoid in long lists).
    case hero
}

struct AppCardModifier: ViewModifier {
    var padding: CGFloat = 16
    var elevation: AppCardElevation = .raised
    var highlighted: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(cardBackground)
            .modifier(ElevationModifier(elevation: elevation, highlighted: highlighted))
    }

    @ViewBuilder
    private var cardBackground: some View {
        let shape = AppVisualStyle.cardShape()
        shape
            .fill(elevation == .hero ? AppVisualStyle.heroGradient : AppVisualStyle.surfaceGradient)
            .overlay(
                shape
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(highlighted ? 0.35 : 0.14),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: highlighted ? 1.5 : 1
                    )
            )
            .overlay(alignment: .top) {
                shape
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.07), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .allowsHitTesting(false)
            }
    }
}

private struct ElevationModifier: ViewModifier {
    let elevation: AppCardElevation
    let highlighted: Bool

    func body(content: Content) -> some View {
        switch elevation {
        case .flat:
            content
        case .raised:
            content
                .shadow(color: .black.opacity(0.14), radius: 6, x: 0, y: 3)
        case .hero:
            content
                .compositingGroup()
                .shadow(color: .black.opacity(highlighted ? 0.22 : 0.18), radius: 10, x: 0, y: 5)
        }
    }
}

extension View {
    func appCard(padding: CGFloat = 16, elevation: AppCardElevation = .raised, highlighted: Bool = false) -> some View {
        modifier(AppCardModifier(padding: padding, elevation: elevation, highlighted: highlighted))
    }

    /// For rows inside ScrollView / List — no shadow cost while scrolling.
    func appListCard(padding: CGFloat = 14, highlighted: Bool = false) -> some View {
        appCard(padding: padding, elevation: .flat, highlighted: highlighted)
    }

    func appHeroCard(padding: CGFloat = 16, highlighted: Bool = false) -> some View {
        appCard(padding: padding, elevation: .hero, highlighted: highlighted)
    }
}

struct GlassBarBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.appSurface.opacity(0.98), Color.appSurface.opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.22), radius: 12, x: 0, y: -4)
    }
}
