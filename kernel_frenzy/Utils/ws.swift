import Foundation
import Combine

@MainActor
class WebSocketManager: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    
    private var urlSession: URLSession?
    private var webSocketTask: URLSessionWebSocketTask?

    init() {
        // Optionally call connectWebSocket here if needed
        // connectWebSocket()
    }
    
    func connectWebSocket() {
        guard let url = NetworkURL.ws as URL? else { return }
        urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveData()
    }
    
    func receiveData() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let message):
                    switch message {
                    case .string(let text):
                        self.parseAndUpdateGraph(from: text)
                    default:
                        break
                    }
                case .failure(let error):
                    print("❌ WebSocket error: \(error.localizedDescription)")
                }
                
                self.receiveData()
            }
        }
    }
    
    func parseAndUpdateGraph(from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        
        do {
            let decodedData = try JSONDecoder().decode([String: Double].self, from: jsonData)
            self.cpuUsage = decodedData["cpu"] ?? 0.0
            self.memoryUsage = decodedData["memory"] ?? 0.0
        } catch {
            print("❌ Decoding error: \(error)")
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel()
        webSocketTask = nil
    }
}
