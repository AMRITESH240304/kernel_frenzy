import Foundation
import Combine

@MainActor
class WebSocketManager: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    @Published var uploadStatus: String = "Idle"
    @Published var uploadProgress: Double = 0.0
    @Published var trainingStatus: Double = 0.0
    
    private var urlSession: URLSession?
    private var webSocketTask: URLSessionWebSocketTask?

    init() {
        // Optionally call connectWebSocket here if needed
        // connectWebSocket()
    }
    
    func connectWebSocket() {
        guard let url = NetworkURL.localhostWS as URL? else { return }
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
            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let type = json["type"] as? String {
                switch type {
                case "metrics":
                    self.cpuUsage = json["cpu"] as? Double ?? 0.0
                    self.memoryUsage = json["memory"] as? Double ?? 0.0

                case "upload_status":
                    self.uploadProgress = json["message"] as? Double ?? 0.0
                    
                case "training_status":
                    self.trainingStatus = json["message"] as? Double ?? 0.0

                default:
                    print("⚠️ Unknown type received: \(type)")
                }
            }
        } catch {
            print("❌ Decoding error: \(error)")
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel()
        webSocketTask = nil
    }
}
