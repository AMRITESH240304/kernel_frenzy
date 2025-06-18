import SwiftUI

struct AccountView: View {
    @State private var searchText = ""
    @State private var files: [FileItem] = []
    @State private var isLoading = false
    @ObservedObject var webSocketManager: WebSocketManager
    
    private let cacheKey = "CachedFiles"
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Training Status & Queue")
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading)
                Spacer()
            }
            
            TextField("Search...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if isLoading {
                ProgressView("Loading files...")
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(files) { file in
                            FileCardView(
                                file: file,
                                webSocketManager: webSocketManager,
                                deleteAction: {
                                    Task {
                                        do {
                                            try await Post().deleteFile(file.name)
                                            if let index = files.firstIndex(where: { $0.id == file.id }) {
                                                files.remove(at: index)
                                                // Update cache after deletion
                                                await CacheManager.shared.cacheFiles(files, forKey: cacheKey)
                                            }
                                        } catch {
                                            print("Error deleting file: \(error)")
                                        }
                                    }
                                }
                            )
                        }
                    }.padding()
                }
            }
            
            Spacer()
        }
        .task {
            await loadFiles()
        }
        .onReceive(NotificationCenter.default.publisher(for: .fileUploaded)) { _ in
                    Task {
                        // Clear cache and reload files
                        await CacheManager.shared.clearCache(forKey: cacheKey)
                        await loadFiles()
                    }
                }
    }
    
    private func loadFiles() async {
        isLoading = true
        
        // Check cache first
        if let cachedFiles = await CacheManager.shared.getCachedFiles(forKey: cacheKey) {
            files = cachedFiles
            isLoading = false
            return
        }
        
        do {
            let fetchedFiles = try await Post().getallFile()
            files = fetchedFiles
            // Store in cache
            print("Network call for files")
            await CacheManager.shared.cacheFiles(files, forKey: cacheKey)
        } catch {
            print("Error fetching files: \(error)")
        }
        isLoading = false
    }
}

struct FileCardView: View {
    let file: FileItem
    @ObservedObject var webSocketManager: WebSocketManager
    let deleteAction: () -> Void
    
    @State private var isTraining = false
    @State private var trainingProgress: Double = 0.0
    @State private var isTrained = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(file.name)
                    .font(.headline)
                Text("Size: \(file.metadata.size) bytes")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if isTrained {
                    Text("Trained")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                } else if isTraining {
                    ProgressView(value: webSocketManager.trainingStatus, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.vertical, 5)
                    
                    Button(action: {
                        isTraining = false
                    }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        Task{
                            isTraining = true
                            webSocketManager.connectWebSocket()
                            try await Post().startTraining(file.name)
                        }
                    }) {
                        Text("Start Training")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .onChange(of: webSocketManager.trainingStatus) { newValue in
                        if newValue >= 1.0 {
                            isTraining = false
                            isTrained = true
                            webSocketManager.disconnect()
                        }
                    }
                }
                
            }
            Spacer()
            Button(action: deleteAction) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private func startTraining() {
        isTraining = true
//        trainingProgress = 0.0
//        
//        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
//            if trainingProgress < 1.0 {
//                trainingProgress += 0.02
//            } else {
//                timer.invalidate()
//                isTraining = false
//                isTrained = true
//            }
//        }
    }
}
