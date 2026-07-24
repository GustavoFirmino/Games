import SwiftUI

/// Uma carta da grade. Faz um flip 3D ao ser revelada.
struct CardView: View {
    let card: Card
    /// Mostra a identidade secreta mesmo sem a carta estar revelada (visão do mestre-espião).
    let showsSecret: Bool
    let isInteractive: Bool
    let onTap: () -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass

    /// Layout mais espaçoso no iPad (e no iPhone Max em landscape).
    private var isRoomy: Bool { sizeClass == .regular }

    private var isFaceUp: Bool { card.isRevealed }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                background
                // Contra-rotação: o container gira 180°, o conteúdo desgira
                // para o texto não sair espelhado no fim do flip.
                content
                    .rotation3DEffect(.degrees(isFaceUp ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: .black.opacity(isFaceUp ? 0.04 : 0.10),
                    radius: isFaceUp ? 2 : 5, x: 0, y: isFaceUp ? 1 : 3)
            .rotation3DEffect(.degrees(isFaceUp ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(isFaceUp ? 0.97 : 1)
            .opacity(isFaceUp && !showsSecret ? 0.9 : 1)
            .animation(.spring(response: 0.45, dampingFraction: 0.75), value: card.isRevealed)
        }
        .buttonStyle(CardButtonStyle(isInteractive: isInteractive))
        .disabled(!isInteractive || card.isRevealed)
        .accessibilityLabel(accessibilityText)
    }

    // MARK: - Partes

    @ViewBuilder
    private var background: some View {
        if isFaceUp {
            card.type.color
        } else if showsSecret {
            card.type.revealHintColor
        } else {
            Theme.hiddenCard
        }
    }

    private var content: some View {
        VStack(spacing: 4) {
            if isFaceUp, case .assassin = card.type {
                Image(systemName: "burst.fill")
                    .font(.system(size: isRoomy ? 24 : 16, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
            }

            Text(card.word)
                .font(.system(size: isRoomy ? 20 : 13, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(wordColor)
                .padding(.horizontal, 4)

            if showsSecret && !isFaceUp {
                // Faixa discreta identificando o dono da carta, para o mestre-espião.
                Capsule()
                    .fill(card.type.color)
                    .frame(width: isRoomy ? 44 : 26, height: isRoomy ? 5 : 3)
            }
        }
        .padding(isRoomy ? 10 : 4)
    }

    private var wordColor: Color {
        if isFaceUp { return card.type.foregroundColor }
        if showsSecret, case .assassin = card.type { return .white }
        return .primary
    }

    private var borderColor: Color {
        if isFaceUp { return .clear }
        if showsSecret { return card.type.color.opacity(0.55) }
        return Theme.cardBorder
    }

    private var borderWidth: CGFloat {
        showsSecret && !isFaceUp ? 2 : 1
    }

    private var accessibilityText: String {
        var parts = [card.word]
        if isFaceUp || showsSecret { parts.append(card.type.label) }
        if card.isRevealed { parts.append("revelada") }
        return parts.joined(separator: ", ")
    }
}

/// Feedback tátil-visual de toque, sem o realce padrão de Button.
private struct CardButtonStyle: ButtonStyle {
    let isInteractive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && isInteractive ? 0.94 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
