import SwiftUI

/// Placar da sessão + cartas restantes de cada time na rodada atual.
struct ScoreboardView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        HStack(spacing: 10) {
            teamPanel(.red)
            VStack(spacing: 2) {
                Text("RODADA")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundStyle(.secondary)
                Text("\(viewModel.roundNumber)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 54)
            teamPanel(.blue)
        }
    }

    private func teamPanel(_ team: Team) -> some View {
        let isActive = viewModel.currentTeam == team && !viewModel.isRoundOver

        return VStack(spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: team.symbol)
                    .font(.system(size: 11, weight: .bold))
                Text(team.displayName.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(team.color)

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("\(viewModel.score(for: team))")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)

                Text("\(viewModel.remainingCards(for: team)) restam")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                .fill(Theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                .strokeBorder(isActive ? team.color : Color.clear, lineWidth: 2.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .animation(.easeInOut(duration: 0.25), value: isActive)
    }
}
