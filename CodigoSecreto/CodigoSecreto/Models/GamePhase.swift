import Foundation

/// As fases pelas quais um turno passa. A ordem do ciclo é:
/// `clueEntry` → `handoff` → `guessing` → (volta para `clueEntry` do outro time)
/// até que alguém termine em `roundOver`.
enum GamePhase: Equatable {
    /// O mestre-espião da vez está vendo o mapa e escrevendo a dica.
    case clueEntry
    /// Tela-cortina: "passe o dispositivo". Impede que os operativos vejam o mapa.
    case handoff
    /// Os operativos estão tentando adivinhar as cartas.
    case guessing
    /// A rodada acabou.
    case roundOver(winner: Team, reason: RoundEndReason)
}

enum RoundEndReason: Equatable {
    /// O time revelou todas as suas cartas.
    case allCardsFound
    /// O time adversário tocou na bomba.
    case assassinHit(by: Team)

    func message(winner: Team) -> String {
        switch self {
        case .allCardsFound:
            return "O time \(winner.displayName) encontrou todos os seus agentes."
        case .assassinHit(let loser):
            return "O time \(loser.displayName) acionou a bomba. Fim de jogo."
        }
    }
}
