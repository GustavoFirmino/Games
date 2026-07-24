import Foundation

/// A dica dada pelo mestre-espião: uma palavra + a quantidade de cartas relacionadas.
struct Clue: Equatable, Identifiable {
    let id = UUID()
    let word: String
    let count: Int
    let team: Team

    /// Regra clássica: o time pode arriscar `count + 1` palpites.
    var maxGuesses: Int { count + 1 }

    var display: String { "\(word.uppercased()) · \(count)" }
}
