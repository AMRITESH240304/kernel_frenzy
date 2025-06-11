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
                    GlassChartCard(
                        title: "CPU Usage",
                        dataPoints: cpuDataPoints,
                        gradientColors: [.red, .orange]
                    )
                    .opacity(isChartVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: isChartVisible)

                    GlassChartCard(
                        title: "Memory Usage",
                        dataPoints: memoryDataPoints,
                        gradientColors: [.blue, .cyan]
                    )
                    .opacity(isChartVisible ? 1 : 0)
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
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            .ultraThinMaterial,
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
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
                        // Handle file selection
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

#Preview{
    HomeView(webSocketManager: WebSocketManager())
}
