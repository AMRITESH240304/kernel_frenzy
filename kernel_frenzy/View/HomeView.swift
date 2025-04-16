import Charts
import SwiftUI

struct HomeView: View {
    @ObservedObject var webSocketManager: WebSocketManager
    @State private var showDocumentPicker = false
    @State private var selectedFile: URL?
    @State private var fileUrl = []
    @State private var cpuDataPoints: [(Date, Double)] = []
    @State private var memoryDataPoints: [(Date, Double)] = []

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("System Monitor")
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading)
                Spacer()
            }

            ScrollView {
                VStack {
                    Text(
                        "CPU Usage: \(webSocketManager.cpuUsage, specifier: "%.2f")%"
                    )
                    .font(.headline)
                    .padding(.top, 10)

                    Chart(cpuDataPoints, id: \.0) { (timestamp, value) in
                        LineMark(
                            x: .value("Time", timestamp),
                            y: .value("CPU Usage (%)", value)
                        )
                        .foregroundStyle(.red)
                    }
                    .frame(height: 150)
                    .padding()
                }

                VStack {
                    Text(
                        "Memory Usage: \(webSocketManager.memoryUsage, specifier: "%.2f")%"
                    )
                    .font(.headline)
                    .padding(.top, 10)

                    Chart(memoryDataPoints, id: \.0) { (timestamp, value) in
                        LineMark(
                            x: .value("Time", timestamp),
                            y: .value("Memory Usage (%)", value)
                        )
                        .foregroundStyle(.blue)
                    }
                    .frame(height: 150)
                    .padding()
                }

                VStack {
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 2)
                                .frame(width: 200, height: 150)

                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.largeTitle)
                                    .foregroundColor(.blue)

                                Text("Upload File for Training")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()

                    if let selectedFile = selectedFile {
                        Text("Selected File: \(selectedFile.lastPathComponent)")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }.sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker { url in
                        self.selectedFile = url
                        showDocumentPicker = false
                        Task{
                            do {
                                try await Post().uploadFile(selectedFile!)
                                // Notify AccountView of new file
                                NotificationCenter.default.post(name: .fileUploaded, object: nil)
                            } catch {
                                print("Error uploading file: \(error)")
                            }
                        }
                    }
                }

            }

            Spacer()
        }
        .onAppear {
            startDataLogging()
            webSocketManager.connectWebSocket()
        }
        .onDisappear {
            webSocketManager.disconnect()
        }
    }

    private func startDataLogging() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let now = Date()

            cpuDataPoints.append((now, webSocketManager.cpuUsage))
            memoryDataPoints.append((now, webSocketManager.memoryUsage))

            if cpuDataPoints.count > 50 && memoryDataPoints.count > 50 {
                cpuDataPoints.removeFirst()
                memoryDataPoints.removeFirst()
            }
        }
    }
}

extension Notification.Name {
    static let fileUploaded = Notification.Name("FileUploaded")
}
