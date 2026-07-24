import Foundation

/// Constantes da distribuição clássica de Codenames.
enum GameRules {
    static let gridColumns = 5
    static let gridRows = 5
    static let gridSize = gridColumns * gridRows   // 25

    /// O time que começa recebe uma carta a mais.
    static let startingTeamCards = 9
    static let secondTeamCards = 8
    static let neutralCards = 7
    static let assassinCards = 1

    static func cardCount(for team: Team, startingTeam: Team) -> Int {
        team == startingTeam ? startingTeamCards : secondTeamCards
    }

    /// Sanidade: a distribuição precisa somar exatamente 25.
    static var isConsistent: Bool {
        startingTeamCards + secondTeamCards + neutralCards + assassinCards == gridSize
    }
}
