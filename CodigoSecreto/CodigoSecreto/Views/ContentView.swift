import SwiftUI

/// Raiz do app: placar fixo no topo e a fase atual do turno abaixo.
struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showsSettings = false

    @Environment(\.isRoomyLayout) private var isRoomy

    var body: some View {
        ZStack {
            Theme.backgroundGradient(for: viewModel.isRoundOver ? viewModel.winner : viewModel.currentTeam)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: viewModel.currentTeam)

            VStack(spacing: isRoomy ? 20 : 12) {
                topBar
                ScoreboardView(viewModel: viewModel)
                phaseContent
                Spacer(minLength: 0)
            }
            .padding(.horizontal, isRoomy ? 40 : 14)
            .padding(.top, 6)
            .frame(maxWidth: 780)
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showsSettings) {
            SettingsView(viewModel: viewModel)
        }
    }

    // MARK: - Partes

    private var topBar: some View {
        HStack {
            Text("Código Secreto")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(.primary)

            Spacer()

            Button {
                showsSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(Circle().fill(Theme.surface))
            }
            .accessibilityLabel("Ajustes")
        }
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch viewModel.phase {
        case .clueEntry:
            ClueEntryView(viewModel: viewModel)
                .transition(.opacity)

        case .handoff:
            HandoffView(team: viewModel.currentTeam) {
                viewModel.beginGuessing()
            }
            .transition(.opacity)

        case .guessing:
            GuessingView(viewModel: viewModel)
                .transition(.opacity)

        case .roundOver(let winner, let reason):
            RoundOverView(viewModel: viewModel, winner: winner, reason: reason)
                .transition(.opacity)
        }
    }
}

#Preview {
    ContentView()
}
