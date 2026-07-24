import SwiftUI

/// Fase dos operativos: grade sem cores, dica no topo, palpites restantes.
struct GuessingView: View {
    @ObservedObject var viewModel: GameViewModel

    @Environment(\.isRoomyLayout) private var isRoomy

    private var team: Team { viewModel.currentTeam }

    var body: some View {
        VStack(spacing: 14) {
            clueBanner

            BoardView(
                cards: viewModel.cards,
                showsSecret: false,
                isInteractive: true,
                onTapCard: { card in
                    Haptics.impact(.light)
                    viewModel.revealCard(card)
                }
            )

            Button {
                Haptics.impact(.soft)
                viewModel.passTurn()
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "flag.fill")
                    Text("Encerrar turno")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .foregroundStyle(team.color)
            .background(
                RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                    .fill(Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                    .strokeBorder(team.color.opacity(0.4), lineWidth: 1.5)
            )
        }
    }

    private var clueBanner: some View {
        VStack(spacing: 8) {
            Text("DICA DO MESTRE-ESPIÃO")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.75))

            Text(viewModel.clue?.word.uppercased() ?? "—")
                .font(.system(size: isRoomy ? 40 : 30, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            HStack(spacing: 10) {
                pill("\(viewModel.clue?.count ?? 0) cartas")
                pill("\(max(viewModel.guessesRemaining, 0)) palpites")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isRoomy ? 22 : 16)
        .background(
            RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                .fill(team.color.gradient)
        )
        .shadow(color: team.color.opacity(0.3), radius: 8, y: 4)
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Capsule().fill(.white.opacity(0.22)))
    }
}
