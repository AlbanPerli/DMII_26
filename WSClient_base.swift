import Foundation

let url = URL(string: "ws://127.0.0.1:8080/ws")!
let socket = URLSession.shared.webSocketTask(with: url)

func receive() {
    socket.receive { result in
        switch result {
        case .success(.string(let text)):
            print("\(text)")
            receive()

        case .success(.data(let data)):
            print("\(data.count) octets reçus")
            receive()

        case .success:
            receive()

        case .failure(let error):
            print("❌ Réception : \(error)")
        }
    }
}

socket.resume()
print("🟢 Client démarré")

receive()

socket.send(.string("Bonjour serveur")) { error in
    if let error {
        print("❌ Envoi : \(error)")
    } else {
        print("📤 Bonjour serveur")
    }
}
