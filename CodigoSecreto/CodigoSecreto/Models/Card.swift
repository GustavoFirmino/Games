import SwiftUI

/// A identidade secreta de uma carta na grade.
enum CardType: Equatable, Codable, Hashable {
    case team(Team)
    case neutral
    case assassin

    var color: Color {
        switch self {
        case .team(let team): return team.color
        case .neutral: return Theme.neutral
        case .assassin: return Theme.assassin
        }
    }

    /// Cor de fundo usada na visão do mestre-espião (mais suave, para leitura confortável).
    var revealHintColor: Color {
        switch self {
        case .team(let team): return team.softColor
        case .neutral: return Theme.neutralSoft
        case .assassin: return Theme.assassinSoft
        }
    }

    var foregroundColor: Color {
        switch self {
        case .team, .assassin: return .white
        case .neutral: return Theme.neutralText
        }
    }

    var label: String {
        switch self {
        case .team(let team): return team.displayName
        case .neutral: return "Neutra"
        case .assassin: return "Bomba"
        }
    }
}

/// Uma das 25 cartas da grade.
struct Card: Identifiable, Equatable {
    let id = UUID()
    let word: String
    let type: CardType
    var isRevealed: Bool = false

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id && lhs.isRevealed == rhs.isRevealed
    }
}
