import SwiftUI

/// Static gradient background — no Canvas (better scroll performance).
struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appSurface.opacity(0.92),
                    Color.appBackground.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.appPrimary.opacity(0.14), Color.clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: -120, y: -200)
                .allowsHitTesting(false)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.appAccent.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: 140, y: 320)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}
