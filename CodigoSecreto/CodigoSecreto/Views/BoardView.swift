import SwiftUI

/// A grade 5×5 de cartas.
struct BoardView: View {
    let cards: [Card]
    let showsSecret: Bool
    let isInteractive: Bool
    let onTapCard: (Card) -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass

    /// Layout mais espaçoso no iPad (e no iPhone Max em landscape).
    private var isRoomy: Bool { sizeClass == .regular }

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: spacing),
            count: GameRules.gridColumns
        )
    }

    private var spacing: CGFloat {
        isRoomy ? Theme.gridSpacing * 1.6 : Theme.gridSpacing
    }

    var body: some View {
        GeometryReader { proxy in
            let totalSpacing = spacing * CGFloat(GameRules.gridColumns - 1)
            let cardWidth = (proxy.size.width - totalSpacing) / CGFloat(GameRules.gridColumns)
            // Cartas levemente "paisagem", como no jogo de tabuleiro.
            let cardHeight = min(cardWidth * 0.72, availableHeight(proxy))

            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(cards) { card in
                    CardView(
                        card: card,
                        showsSecret: showsSecret,
                        isInteractive: isInteractive,
                        onTap: { onTapCard(card) }
                    )
                    .frame(height: cardHeight)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(gridAspectRatio, contentMode: .fit)
    }

    private func availableHeight(_ proxy: GeometryProxy) -> CGFloat {
        let totalSpacing = spacing * CGFloat(GameRules.gridRows - 1)
        return max((proxy.size.height - totalSpacing) / CGFloat(GameRules.gridRows), 40)
    }

    private var gridAspectRatio: CGFloat {
        // 5 colunas de largura 1 × 5 linhas de altura 0.72.
        CGFloat(GameRules.gridColumns) / (CGFloat(GameRules.gridRows) * 0.72)
    }
}
