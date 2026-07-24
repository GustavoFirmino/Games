import Foundation

/// Um conjunto nomeado de palavras. O `words.json` do bundle traz o pacote padrão,
/// e novos pacotes podem ser adicionados no mesmo arquivo sem alterar código.
struct WordPack: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let words: [String]

    var isPlayable: Bool { words.count >= GameRules.gridSize }
}

/// Wrapper do arquivo `words.json`.
struct WordPackFile: Codable {
    let packs: [WordPack]
}

/// Carrega os pacotes de palavras do bundle do app.
enum WordBank {
    static let allPacks: [WordPack] = load()

    static var defaultPack: WordPack {
        allPacks.first(where: { $0.id == "padrao" }) ?? allPacks[0]
    }

    private static func load() -> [WordPack] {
        guard
            let url = Bundle.main.url(forResource: "words", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let file = try? JSONDecoder().decode(WordPackFile.self, from: data),
            !file.packs.isEmpty
        else {
            assertionFailure("words.json não foi encontrado ou está malformado.")
            return [fallbackPack]
        }
        // Só expõe pacotes com palavras suficientes para formar uma grade.
        let usable = file.packs.filter(\.isPlayable)
        return usable.isEmpty ? [fallbackPack] : usable
    }

    /// Rede de segurança para o app nunca crashar caso o JSON suma do bundle.
    private static let fallbackPack = WordPack(
        id: "fallback",
        name: "Emergência",
        emoji: "🛟",
        words: (1...GameRules.gridSize).map { "PALAVRA \($0)" }
    )
}
