import SwiftUI

/// Paleta e métricas do app. Todas as cores são adaptativas (light/dark).
enum Theme {

    // MARK: - Times

    static let teamRed      = adaptive(light: 0xD13D45, dark: 0xE65A60)
    static let teamBlue     = adaptive(light: 0x2A6BBF, dark: 0x5494EB)

    /// Versões dessaturadas, usadas como fundo na visão do mestre-espião.
    static let teamRedSoft  = adaptive(light: 0xF8DEDE, dark: 0x4E2528)
    static let teamBlueSoft = adaptive(light: 0xDCE8F9, dark: 0x1F3659)

    // MARK: - Cartas neutras e bomba

    static let neutral      = adaptive(light: 0xD9CCB8, dark: 0x6B6459)
    static let neutralSoft  = adaptive(light: 0xF0EAE0, dark: 0x3F3A33)
    static let neutralText  = adaptive(light: 0x3D362B, dark: 0xF0EAE0)

    static let assassin     = adaptive(light: 0x1E1C21, dark: 0x121114)
    static let assassinSoft = adaptive(light: 0x45424A, dark: 0x2A282E)

    // MARK: - Superfícies

    static let background   = adaptive(light: 0xF4F4F6, dark: 0x111114)
    static let surface      = adaptive(light: 0xFFFFFF, dark: 0x1D1D21)
    static let hiddenCard   = adaptive(light: 0xFCFAF6, dark: 0x2B2B31)
    static let cardBorder   = adaptive(light: 0xDEDCD7, dark: 0x3A3A42)

    // MARK: - Métricas

    static let cardCornerRadius: CGFloat = 14
    static let panelCornerRadius: CGFloat = 20
    static let gridSpacing: CGFloat = 8

    /// Gradiente sutil de fundo, puxando para a cor do time da vez.
    static func backgroundGradient(for team: Team?) -> LinearGradient {
        let tint = (team?.color ?? Color.gray).opacity(0.14)
        return LinearGradient(
            colors: [tint, background, background],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Infra

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red:   CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue:  CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
