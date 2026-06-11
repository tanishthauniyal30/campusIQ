import Foundation

class GeminiService {
    // 🔑 PASTE YOUR GEMINI API KEY HERE
    static let apiKey = "YOUR_GEMINI_API_KEY_HERE"
    static let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

    static func ask(_ prompt: String) async throws -> String {
        guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let candidates = json?["candidates"] as? [[String: Any]]
        let content = candidates?.first?["content"] as? [String: Any]
        let parts = content?["parts"] as? [[String: Any]]
        let text = parts?.first?["text"] as? String
        return text ?? "No response received."
    }
}
