import SwiftUI

/// Ajustes da sessão: pacote de palavras, nova rodada e regras.
struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showsResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Pacote de palavras", selection: $viewModel.selectedPackID) {
                        ForEach(viewModel.availablePacks) { pack in
                            Text("\(pack.emoji)  \(pack.name)  ·  \(pack.words.count)")
                                .tag(pack.id)
                        }
                    }
                } header: {
                    Text("Banco de palavras")
                } footer: {
                    Text("A troca de pacote vale a partir da próxima rodada. Novos pacotes podem ser adicionados editando o arquivo words.json do projeto.")
                }

                Section("Partida") {
                    Button("Nova rodada (mantém o placar)") {
                        viewModel.startNextRound()
                        dismiss()
                    }
                    Button("Zerar tudo", role: .destructive) {
                        showsResetConfirmation = true
                    }
                }

                Section("Como se joga") {
                    rule("O time que começa tem \(GameRules.startingTeamCards) cartas; o outro, \(GameRules.secondTeamCards).")
                    rule("São \(GameRules.neutralCards) cartas neutras e \(GameRules.assassinCards) bomba.")
                    rule("O mestre-espião dá uma palavra + um número. O time pode arriscar até o número da dica + 1 palpite.")
                    rule("Errar para carta neutra ou do adversário encerra o turno. Tocar na bomba entrega a rodada ao adversário.")
                    rule("Quem revelar todos os seus agentes primeiro ganha o ponto.")
                }

                Section {
                    LabeledContent("Versão", value: Bundle.main.appVersion)
                } footer: {
                    Text("Projeto pessoal, feito por hobby. Código aberto no GitHub.")
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .confirmationDialog(
                "Zerar placar e começar uma partida nova?",
                isPresented: $showsResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Zerar tudo", role: .destructive) {
                    viewModel.resetEverything()
                    dismiss()
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }

    private func rule(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 5))
                .foregroundStyle(.secondary)
                .padding(.top, 7)
            Text(text)
                .font(.system(size: 14))
        }
    }
}

extension Bundle {
    var appVersion: String {
        let short = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }
}
