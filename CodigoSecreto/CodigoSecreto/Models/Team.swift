import SwiftUI

/// Um dos dois times em jogo.
enum Team: String, Codable, CaseIterable, Identifiable {
    case red
    case blue

    var id: String { rawValue }

    var opponent: Team {
        self == .red ? .blue : .red
    }

    var displayName: String {
        switch self {
        case .red: return "Vermelho"
        case .blue: return "Azul"
        }
    }

    /// Nome curto, para caber em espaços apertados no iPhone.
    var shortName: String {
        switch self {
        case .red: return "VER"
        case .blue: return "AZU"
        }
    }

    var color: Color {
        switch self {
        case .red: return Theme.teamRed
        case .blue: return Theme.teamBlue
        }
    }

    var softColor: Color {
        switch self {
        case .red: return Theme.teamRedSoft
        case .blue: return Theme.teamBlueSoft
        }
    }

    var symbol: String {
        switch self {
        case .red: return "flame.fill"
        case .blue: return "drop.fill"
        }
    }
}
