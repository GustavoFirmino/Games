import SwiftUI

/// Toda a lógica da partida. As views só leem estado e chamam intenções daqui.
@MainActor
final class GameViewModel: ObservableObject {

    // MARK: - Estado da rodada

    @Published private(set) var cards: [Card] = []
    @Published private(set) var startingTeam: Team = .red
    @Published private(set) var currentTeam: Team = .red
    @Published private(set) var phase: GamePhase = .clueEntry
    @Published private(set) var clue: Clue?
    @Published private(set) var guessesRemaining: Int = 0
    @Published private(set) var lastRevealedCardID: UUID?

    // MARK: - Estado da sessão (sobrevive entre rodadas)

    @Published private(set) var score: [Team: Int] = [.red: 0, .blue: 0]
    @Published private(set) var roundNumber: Int = 1
    @Published var selectedPackID: String = WordBank.defaultPack.id

    // MARK: - Init

    init() {
        assert(GameRules.isConsistent, "A distribuição de cartas não soma \(GameRules.gridSize).")
        startNewRound(resetScore: false)
    }

    // MARK: - Derivados

    var isRoundOver: Bool {
        if case .roundOver = phase { return true }
        return false
    }

    var winner: Team? {
        if case .roundOver(let winner, _) = phase { return winner }
        return nil
    }

    var endReason: RoundEndReason? {
        if case .roundOver(_, let reason) = phase { return reason }
        return nil
    }

    func remainingCards(for team: Team) -> Int {
        cards.filter { $0.type == .team(team) && !$0.isRevealed }.count
    }

    func totalCards(for team: Team) -> Int {
        cards.filter { $0.type == .team(team) }.count
    }

    func score(for team: Team) -> Int {
        score[team] ?? 0
    }

    var availablePacks: [WordPack] { WordBank.allPacks }

    var selectedPack: WordPack {
        availablePacks.first(where: { $0.id == selectedPackID }) ?? WordBank.defaultPack
    }

    // MARK: - Ciclo de vida da rodada

    /// Sorteia uma grade nova. Quem começa também é sorteado a cada rodada.
    func startNewRound(resetScore: Bool) {
        if resetScore {
            score = [.red: 0, .blue: 0]
            roundNumber = 1
        }

        let starter = Team.allCases.randomElement() ?? .red
        startingTeam = starter
        currentTeam = starter
        clue = nil
        guessesRemaining = 0
        lastRevealedCardID = nil
        cards = Self.makeGrid(startingTeam: starter, pack: selectedPack)
        phase = .clueEntry
    }

    /// Nova rodada mantendo o placar acumulado.
    func startNextRound() {
        roundNumber += 1
        startNewRound(resetScore: false)
    }

    func resetEverything() {
        startNewRound(resetScore: true)
    }

    // MARK: - Intenções

    /// O mestre-espião confirmou a dica → cortina de troca de dispositivo.
    func submitClue(word: String, count: Int) {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isRoundOver else { return }

        let bounded = min(max(count, 0), remainingCards(for: currentTeam))
        clue = Clue(word: trimmed, count: bounded, team: currentTeam)
        guessesRemaining = bounded + 1
        phase = .handoff
    }

    /// O dispositivo chegou aos operativos.
    func beginGuessing() {
        guard case .handoff = phase else { return }
        phase = .guessing
    }

    /// Os operativos tocaram numa carta.
    func revealCard(_ card: Card) {
        guard case .guessing = phase,
              let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isRevealed
        else { return }

        cards[index].isRevealed = true
        lastRevealedCardID = card.id
        guessesRemaining -= 1

        switch cards[index].type {
        case .assassin:
            // Quem tocou perde na hora; o ponto vai para o adversário.
            finishRound(winner: currentTeam.opponent,
                        reason: .assassinHit(by: currentTeam))

        case .team(let owner) where owner == currentTeam:
            if remainingCards(for: currentTeam) == 0 {
                finishRound(winner: currentTeam, reason: .allCardsFound)
            } else if guessesRemaining <= 0 {
                endTurn()
            }

        case .team(let owner):
            // Revelou carta do adversário — pode até entregar a vitória a ele.
            if remainingCards(for: owner) == 0 {
                finishRound(winner: owner, reason: .allCardsFound)
            } else {
                endTurn()
            }

        case .neutral:
            endTurn()
        }
    }

    /// O time decidiu parar de arriscar.
    func passTurn() {
        guard case .guessing = phase else { return }
        endTurn()
    }

    // MARK: - Privado

    private func endTurn() {
        currentTeam = currentTeam.opponent
        clue = nil
        guessesRemaining = 0
        phase = .clueEntry
    }

    private func finishRound(winner: Team, reason: RoundEndReason) {
        score[winner, default: 0] += 1
        clue = nil
        guessesRemaining = 0
        // Ao fim da rodada o mapa inteiro fica visível.
        for index in cards.indices { cards[index].isRevealed = true }
        phase = .roundOver(winner: winner, reason: reason)
    }

    /// Sorteia 25 palavras e distribui as identidades secretas.
    private static func makeGrid(startingTeam: Team, pack: WordPack) -> [Card] {
        let words = Array(Set(pack.words)).shuffled().prefix(GameRules.gridSize)

        var types: [CardType] = []
        types += Array(repeating: .team(startingTeam), count: GameRules.startingTeamCards)
        types += Array(repeating: .team(startingTeam.opponent), count: GameRules.secondTeamCards)
        types += Array(repeating: .neutral, count: GameRules.neutralCards)
        types += Array(repeating: .assassin, count: GameRules.assassinCards)
        types.shuffle()

        return zip(words, types).map { Card(word: $0, type: $1) }
    }
}
