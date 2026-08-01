import SwiftUI

enum Metrics {
    static let radiusShell: CGFloat = 14
    static let radiusCard: CGFloat = 8
    static let radiusControl: CGFloat = 6
    static let radiusDayCell: CGFloat = 12
    static let hitAreaMin: CGFloat = 40
    static let pressScale: CGFloat = 0.96
    static let gridSpacing: CGFloat = 4
    static let dayCellHeight: CGFloat = 52
}

/// Toolbar / settings buttons: tactile press scale, respects reduced motion.
struct ToolbarButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(
                configuration.isPressed && !reduceMotion ? Metrics.pressScale : 1
            )
            .animation(
                reduceMotion ? nil : .easeOut(duration: 0.08),
                value: configuration.isPressed
            )
    }
}

extension View {
    /// Layered transparent shadows for popover shell depth.
    func surfaceShadow() -> some View {
        shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 4)
            .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
    }

    /// Subtle card elevation on material surfaces.
    func cardShadow() -> some View {
        shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 2)
            .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 0.5)
    }
}
