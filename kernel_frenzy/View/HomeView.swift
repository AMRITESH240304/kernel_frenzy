import Charts
import SwiftUI

struct HomeView: View {
    @ObservedObject var webSocketManager: WebSocketManager
    @State private var showDocumentPicker = false
    @State private var selectedFile: URL?
    @State private var fileUrl = []
    @State private var cpuDataPoints: [(Date, Double)] = []
    @State private var memoryDataPoints: [(Date, Double)] = []
    @State private var isChartVisible: Bool = false 

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
                    Text("CPU Usage: \(webSocketManager.cpuUsage, specifier: "%.2f")%")
                        .font(.headline)
                        .padding(.top, 10)

                    Chart(cpuDataPoints, id: \.0) { (timestamp, value) in
                        LineMark(
                            x: .value("Time", timestamp),
                            y: .value("CPU Usage (%)", value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .interpolationMethod(.catmullRom) // Smooth curve
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .shadow(radius: 2)
                    }
                    .frame(height: 150)
                    .padding()
                    .opacity(isChartVisible ? 1 : 0) // Initial fade-in
                    .animation(.easeInOut(duration: 0.5), value: isChartVisible)
                }

                VStack {
                    Text("Memory Usage: \(webSocketManager.memoryUsage, specifier: "%.2f")%")
                        .font(.headline)
                        .padding(.top, 10)

                    Chart(memoryDataPoints, id: \.0) { (timestamp, value) in
                        LineMark(
                            x: .value("Time", timestamp),
                            y: .value("Memory Usage (%)", value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .interpolationMethod(.catmullRom) // Smooth curve
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .shadow(radius: 2)
                    }
                    .frame(height: 150)
                    .padding()
                    .opacity(isChartVisible ? 1 : 0) // Initial fade-in
                    .animation(.easeInOut(duration: 0.5), value: isChartVisible)
                }

                VStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showDocumentPicker = true
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                            Text("Upload")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                        .scaleEffect(showDocumentPicker ? 0.96 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showDocumentPicker)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()

                    if let selectedFile = selectedFile {
                        Text("Selected File: \(selectedFile.lastPathComponent)")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker { url in
                        self.selectedFile = url
                        showDocumentPicker = false
                        Task {
                            do {
                                try await Post().uploadFile(selectedFile!)
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
            isChartVisible = true // Trigger chart fade-in
            startDataLogging()
            webSocketManager.connectWebSocket()
        }
        .onDisappear {
            webSocketManager.disconnect()
        }
    }

    private func startDataLogging() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
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
}

extension Notification.Name {
    static let fileUploaded = Notification.Name("FileUploaded")
}
