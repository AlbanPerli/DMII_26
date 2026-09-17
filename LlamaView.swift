//
//  LlamaView.swift
//  FirstApp
//
//  Created by Al on 17/09/2026.
//

import SwiftUI


struct Command: Codable {
    let action: String
    let element: String
    let col: Int
    let line: Int
    // Création depuis une String JSON
    init(jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "InvalidString", code: 1)
        }
        self = try JSONDecoder().decode(Command.self, from: data)
    }

    // Conversion de l'objet en String JSON
    func toJSONString() throws -> String {
        let data = try JSONEncoder().encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "EncodingError", code: 2)
        }
        return string
    }

}


struct LlamaView: View {

    @StateObject private var llama = LlamaClient(
        baseURL: "http://192.168.4.96:8080"
    )

    @State private var prompt = ""

    var body: some View {

        VStack(spacing: 20) {

            TextField(
                "Pose une question...",
                text: $prompt
            )
            .textFieldStyle(.roundedBorder)

            Button("Envoyer") {

                let currentPrompt = prompt
                prompt = ""

                Task {
                    await llama.send(
                        prompt: currentPrompt,
                        systemPrompt:"""
                        Tu réponds sous la forme d'un JSON.
                        Exemple: {"action":add|remove, "element":"elementId", "color":color|None, "size":"x,y,width,height"|None}
                        Si on te parle de grille, tu réponds:
                        {"action":'add'|'remove', "element":"elementId","col":nbCol,"line":nbLine}
                        """)
                }
            }
            .disabled(llama.isLoading)

            if llama.isLoading {
                ProgressView("Llama réfléchit...")
            }

            ScrollView {
                Text(llama.response)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }

            if let error = llama.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .onChange(of: llama.response) { _ in
            print("La réponse a été mise à jour")
            print(llama.response)
            do {
                let command = try Command(jsonString: llama.response)
                print(command.action)   // add
                print(command.element)  // grid
                print(command.col)      // 6
                print(command.line)     // 6
                let result = try command.toJSONString()
                print(result)
            } catch {
                print("Erreur: \(error)")
            }
        }
    }
}

#Preview {
    LlamaView()
}
