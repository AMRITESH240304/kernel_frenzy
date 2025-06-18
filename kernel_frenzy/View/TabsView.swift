//
//  HomeView.swift
//  kernel_frenzy
//
//  Created by admin49 on 08/02/25.
//

import SwiftUI

struct TabsView: View {
    @StateObject private var webSocketManager = WebSocketManager()
    var body: some View {
        TabView {
            HomeView(webSocketManager: webSocketManager)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            AccountView(webSocketManager:webSocketManager)
                .tabItem {
                    Label("File", systemImage: "filemenu.and.selection")
                }

            TestView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
                .badge("!")
        }
        .navigationBarBackButtonHidden()

    }
}

#Preview {
    TabsView()
}
