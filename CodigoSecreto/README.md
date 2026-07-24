# 🕵️ Código Secreto

Um clone do **Codenames** em SwiftUI, universal (iPhone + iPad), 100% offline —
sem backend, sem login, sem internet. Feito por hobby, para jogar com amigos usando
um único aparelho.

---

## 🎲 Como funciona

Uma grade de **25 palavras**. Dois times — Vermelho e Azul — tentam descobrir quais
palavras pertencem a eles, guiados apenas pela dica do **mestre-espião**.

Distribuição sorteada a cada rodada (inclusive quem começa):

| Tipo | Quantidade |
|------|-----------|
| Time que começa | 9 |
| Time adversário | 8 |
| Neutras (civis) | 7 |
| 💣 Bomba (assassino) | 1 |

**Fluxo do turno:**

1. O mestre-espião vê o mapa secreto e registra uma dica: **uma palavra + um número**.
2. O dispositivo passa para os operativos (com tela-cortina no meio).
3. Os operativos tocam nas cartas, uma por vez. Podem arriscar até **número + 1** palpites.
4. Acertou carta do próprio time → continua. Neutra ou do adversário → **turno encerrado**.
5. Tocou na bomba → **derrota imediata**, ponto para o adversário.
6. Quem revelar todos os seus agentes primeiro leva o ponto.

---

## 📱 Modo pass-and-play

Como é para jogar num aparelho só, o app tem duas visões que se alternam sozinhas
conforme a fase do turno:

- **Visão do mestre-espião** — o mapa começa **borrado**. Só aparece enquanto você
  mantém o dedo pressionado no botão *"Segure para ver o mapa"*. Soltou, some.
  Ninguém vê o mapa por acidente.
- **Tela de transição** — *"Passe o dispositivo"*, entre a dica e a adivinhação.
- **Visão dos operativos** — só as palavras e a dica atual. Nenhuma cor secreta.

---

## ✨ Recursos

- Placar acumulado entre rodadas na mesma sessão (com opção de zerar)
- Animação de flip 3D ao revelar cada carta
- Dark Mode completo, com paleta própria adaptativa
- Layout compacto no iPhone e espaçoso no iPad
- Feedback tátil (haptics) nas ações principais
- **444 palavras** em português no pacote padrão + pacotes extras (Cinema & TV, Brasil)
- Banco de palavras em JSON — dá para editar e expandir sem tocar em código

---

## 🚀 Como rodar

**Requisitos:** macOS com **Xcode 16+**, iPhone/iPad com **iOS 17+**.

1. Abra `CodigoSecreto.xcodeproj` no Xcode.
2. Em **Signing & Capabilities**, selecione o seu *Team* (conta de desenvolvedor
   pessoal já serve) e troque o **Bundle Identifier** para algo único seu
   (ex.: `com.seunome.CodigoSecreto`).
3. Conecte o iPhone/iPad por cabo, selecione o dispositivo no topo do Xcode e dê **⌘R**.
4. Na primeira execução: *Ajustes → Geral → VPN e Gerenciamento de Dispositivo* no
   iPhone, e confie no seu certificado de desenvolvedor.

> Com conta gratuita da Apple, o app expira em 7 dias e precisa ser reinstalado.
> Com o Apple Developer Program pago, vale 1 ano.

---

## 📁 Estrutura

```
CodigoSecreto/
├── CodigoSecreto.xcodeproj/
└── CodigoSecreto/
    ├── App/
    │   └── CodigoSecretoApp.swift     # entrada @main
    ├── Models/
    │   ├── Card.swift                 # Card + CardType
    │   ├── Team.swift
    │   ├── Clue.swift                 # palavra + número
    │   ├── GamePhase.swift            # fases do turno
    │   ├── GameRules.swift            # constantes 9/8/7/1
    │   └── WordPack.swift             # carregamento do JSON
    ├── ViewModels/
    │   └── GameViewModel.swift        # toda a lógica da partida
    ├── Views/
    │   ├── ContentView.swift          # raiz, roteia por fase
    │   ├── BoardView.swift            # grade 5×5
    │   ├── CardView.swift             # carta + flip
    │   ├── ScoreboardView.swift
    │   ├── ClueEntryView.swift        # mestre-espião
    │   ├── HandoffView.swift          # cortina de troca
    │   ├── GuessingView.swift         # operativos
    │   ├── RoundOverView.swift
    │   └── SettingsView.swift
    ├── Theme/
    │   ├── Theme.swift                # paleta light/dark
    │   └── Haptics.swift
    └── Resources/
        ├── words.json                 # banco de palavras
        └── Assets.xcassets
```

Arquitetura: **SwiftUI + MVVM**. O `GameViewModel` é a única fonte de verdade;
as views só leem estado e disparam intenções. Zero dependências externas.

---

## 🧩 Adicionar um pacote de palavras

Basta acrescentar um objeto ao array `packs` em
[`words.json`](CodigoSecreto/Resources/words.json):

```json
{
  "id": "musica",
  "name": "Música",
  "emoji": "🎸",
  "words": ["Acorde", "Refrão", "Ensaio", "..."]
}
```

Ele aparece sozinho no seletor de *Ajustes*. Pacotes com menos de 25 palavras são
ignorados automaticamente.

---

## 💡 Ideias para depois

- [ ] Persistir o placar entre sessões (`@AppStorage`)
- [ ] Histórico de dicas dadas na rodada
- [ ] Timer opcional por turno
- [ ] Ícone de app de verdade
- [ ] Editor de pacotes dentro do app

---

Parte do repo [Games](../) — projetos pessoais feitos por hobby.
