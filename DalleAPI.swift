import Foundation
class DalleAPI {
    static let apiKey = "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"
    static let endpoint = "https://api.openai.com/v1/images/generations"

    static func generateImage(from description: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["prompt": description, "n": 1, "size": "1024x1024"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        print("Sending request to DALL-E API with body: \(body)")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making request: \(error)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            print("Data received: \(String(data: data, encoding: .utf8) ?? "No Data")")

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let data = json["data"] as? [[String: Any]],
               let urlString = data.first?["url"] as? String,
               let url = URL(string: urlString) {
                print("Image URL received: \(url)")
                completion(url)
            } else {
                print("Failed to parse JSON response")
                completion(nil)
            }
        }

        task.resume()
    }
}
