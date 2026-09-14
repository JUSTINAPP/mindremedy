import SwiftUI

/// Mind Remedy's "Midnight" theme — extends Remedy Reminder's own theme,
/// spec'd in ~/Desktop/RemedyReminder/THEME_PICKER_BRIEF.md but never built
/// there. Built as a proper token system from the start rather than
/// hardcoding hex values throughout every view — see CLAUDE.md "Visual
/// identity" for why (237 `Color(hex:)` call sites across 33 files in
/// Remedy Reminder is the cautionary example).
enum AppTheme {
    static let background = Color(hex: "#12201e")
    static let card = Color(hex: "#1c2e2b")
    static let border = Color(hex: "#2c3f3c")
    static let accent = Color(hex: "#4fd1a5")
    static let onAccent = Color(hex: "#0b1a17")

    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.55)
    static let textTertiary = Color.white.opacity(0.45)
    static let textFaint = Color.white.opacity(0.35)

    static let pillBackground = Color.white.opacity(0.06)
    static let pillBorder = Color.white.opacity(0.12)
    static let hairline = Color.white.opacity(0.07)

    enum Radius {
        static let card: CGFloat = 20
        static let row: CGFloat = 16
        static let control: CGFloat = 14
        static let pill: CGFloat = 12
        static let capsule: CGFloat = 999
    }

    enum Spacing {
        static let screenPadding: CGFloat = 24
    }
}
