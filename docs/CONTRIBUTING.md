# Como adicionar um novo jogo

Padrão que eu sigo neste repo (pra não virar bagunça com o tempo):

1. **Uma pasta por jogo**, na raiz, com o nome do jogo em `PascalCase` sem espaços.
   Ex.: `CodigoSecreto/`, `SnakeTerminal/`, `PixelJump/`.

2. **Cada jogo é autocontido.** Nada de código compartilhado entre jogos por enquanto —
   duplicar é mais barato que acoplar em projeto de hobby.

3. **README próprio** dentro da pasta do jogo, contendo:
   - o que é o jogo / regras em 1 parágrafo
   - stack usada
   - como rodar (passo a passo, assumindo máquina limpa)
   - estrutura de pastas
   - o que ainda falta / ideias futuras

4. **Atualizar a tabela** de jogos no [README da raiz](../README.md).

5. **`.gitignore`**: o da raiz cobre macOS, Windows, Xcode, SPM e Node.
   Se o jogo usar outra stack, adicione um `.gitignore` dentro da pasta do jogo.

6. **Assets**: manter dentro da pasta do jogo. Se for asset pesado (áudio/vídeo),
   avaliar antes se vale versionar.

## Convenção de commits

Simples, sem cerimônia:

```
CodigoSecreto: adiciona pacote de palavras de filmes
Games: atualiza README com novo jogo
```

Prefixo = nome da pasta afetada (ou `Games` para coisas da raiz).
