import Foundation

struct Message {

    var emetteur: String
    var message: String
    var receiver: String

    func fromJSON(json: String) -> Message? {
        
        guard let data = json.data(using: .utf8) else {
            return nil
        }

        guard let dict = try? JSONSerialization.jsonObject(
            with: data,
            options: []
        ) as? [String: String] else {
            return nil
        }

        guard let emetteur = dict["emetteur"],
              let message = dict["message"],
              let receiver = dict["receiver"] else {
            return nil
        }

        return Message(
            emetteur: emetteur,
            message: message,
            receiver: receiver
        )
    }

    func toString() -> String {
        
        var dict: [String: String] = [:]
        
        dict["emetteur"] = emetteur
        dict["message"] = message
        dict["receiver"] = receiver

        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: dict,
                options: []
            )

            return String(data: jsonData, encoding: .utf8) ?? ""

        } catch {
            print("Erreur JSON : \(error)")
            return ""
        }
    }
}

