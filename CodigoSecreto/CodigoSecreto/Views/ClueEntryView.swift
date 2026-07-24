import SwiftUI

/// Fase do mestre-espião: ver o mapa secreto (protegido) e registrar a dica.
struct ClueEntryView: View {
    @ObservedObject var viewModel: GameViewModel

    @State private var clueWord: String = ""
    @State private var clueCount: Int = 1
    @State private var isMapUnlocked = false
    @FocusState private var isWordFieldFocused: Bool

    @Environment(\.horizontalSizeClass) private var sizeClass

    /// Layout mais espaçoso no iPad (e no iPhone Max em landscape).
    private var isRoomy: Bool { sizeClass == .regular }

    private var team: Team { viewModel.currentTeam }

    private var maxCount: Int {
        max(viewModel.remainingCards(for: team), 1)
    }

    private var canSubmit: Bool {
        !clueWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 14) {
            header

            ZStack {
                BoardView(
                    cards: viewModel.cards,
                    showsSecret: isMapUnlocked,
                    isInteractive: false,
                    onTapCard: { _ in }
                )
                .blur(radius: isMapUnlocked ? 0 : 14)
                .allowsHitTesting(false)

                if !isMapUnlocked {
                    lockedOverlay
                }
            }
            .animation(.easeInOut(duration: 0.22), value: isMapUnlocked)

            holdButton
            clueForm
        }
        .onChange(of: viewModel.currentTeam) { _, _ in resetForm() }
        .onAppear { resetForm() }
    }

    // MARK: - Partes

    private var header: some View {
        VStack(spacing: 3) {
            Text("MESTRE-ESPIÃO")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.secondary)
            Text("Time \(team.displayName)")
                .font(.system(size: isRoomy ? 30 : 24, weight: .black, design: .rounded))
                .foregroundStyle(team.color)
            Text("Faltam \(viewModel.remainingCards(for: team)) agentes seus")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private var lockedOverlay: some View {
        VStack(spacing: 8) {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 30, weight: .semibold))
            Text("Mapa secreto oculto")
                .font(.system(size: 15, weight: .bold, design: .rounded))
            Text("Segure o botão abaixo para revelar")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous))
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    /// Precisa manter o dedo pressionado: soltou, o mapa some.
    /// Evita que os operativos vejam o mapa por descuido.
    private var holdButton: some View {
        HStack(spacing: 8) {
            Image(systemName: isMapUnlocked ? "eye.fill" : "hand.tap.fill")
            Text(isMapUnlocked ? "Solte para ocultar" : "Segure para ver o mapa")
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                .fill(isMapUnlocked ? team.color : Color.primary.opacity(0.8))
        )
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isMapUnlocked {
                        isMapUnlocked = true
                        Haptics.impact(.medium)
                        isWordFieldFocused = false
                    }
                }
                .onEnded { _ in isMapUnlocked = false }
        )
    }

    private var clueForm: some View {
        VStack(spacing: 12) {
            TextField("Palavra da dica", text: $clueWord)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .focused($isWordFieldFocused)
                .submitLabel(.done)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                        .fill(Theme.surface)
                )

            HStack(spacing: 14) {
                Text("Quantidade")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)

                Spacer()

                Stepper(value: $clueCount, in: 0...maxCount) {
                    Text("\(clueCount)")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(team.color)
                }
                .fixedSize()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                    .fill(Theme.surface)
            )

            Button {
                isWordFieldFocused = false
                Haptics.impact(.rigid)
                viewModel.submitClue(word: clueWord, count: clueCount)
            } label: {
                Text("Registrar dica")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                    .fill(canSubmit ? team.color : Color.gray.opacity(0.4))
            )
            .disabled(!canSubmit)
            .animation(.easeInOut(duration: 0.2), value: canSubmit)
        }
    }

    private func resetForm() {
        clueWord = ""
        clueCount = min(1, maxCount)
        isMapUnlocked = false
        isWordFieldFocused = false
    }
}
