import SwiftUI

/// Cortina entre a fase de dica e a de adivinhação.
/// Nada do mapa aparece aqui — é justamente o ponto.
struct HandoffView: View {
    let team: Team
    let onContinue: () -> Void

    @State private var pulse = false

    var body: some View {
        VStack(spacing: 26) {
            Spacer()

            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                .font(.system(size: 62, weight: .light))
                .foregroundStyle(team.color)
                .scaleEffect(pulse ? 1.06 : 0.96)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)

            VStack(spacing: 10) {
                Text("Passe o dispositivo")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)

                Text("Operativos do time \(team.displayName)")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(team.color)

                Text("O mestre-espião já registrou a dica.\nToque abaixo quando estiver com o time certo em mãos.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 4)
            }

            Spacer()

            Button {
                Haptics.impact(.medium)
                onContinue()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "eye.fill")
                    Text("Ver a dica")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: Theme.panelCornerRadius, style: .continuous)
                    .fill(team.color)
            )
            .padding(.bottom, 10)
        }
        .frame(maxWidth: 520)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { pulse = true }
    }
}
