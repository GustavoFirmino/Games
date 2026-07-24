import SwiftUI

/// Fim de rodada: mapa inteiro aberto + opções de continuar ou zerar.
struct RoundOverView: View {
    @ObservedObject var viewModel: GameViewModel
    let winner: Team
    let reason: RoundEndReason

    var body: some View {
        VStack(spacing: 14) {
            banner

            BoardView(
                cards: viewModel.cards,
                showsSecret: true,
                isInteractive: false,
                onTapCard: { _ in }
            )

            HStack(spacing: 10) {
                Button {
                    Haptics.impact(.medium)
                    viewModel.startNextRound()
                } label: {
                    Text("Próxima rodada")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                        .fill(winner.color)
                )

                Button {
                    Haptics.impact(.soft)
                    viewModel.resetEverything()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 17, weight: .bold))
                        .frame(width: 54)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .background(
                    RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                        .fill(Theme.surface)
                )
                .accessibilityLabel("Zerar placar e começar do início")
            }
        }
    }

    private var banner: some View {
        VStack(spacing: 6) {
            Image(systemName: isAssassin ? "burst.fill" : "trophy.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)

            Text("Time \(winner.displayName) venceu")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(reason.message(winner: winner))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                .fill(winner.color.gradient)
        )
        .shadow(color: winner.color.opacity(0.3), radius: 10, y: 5)
    }

    private var isAssassin: Bool {
        if case .assassinHit = reason { return true }
        return false
    }
}
