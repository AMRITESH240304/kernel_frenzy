//
//  buttonView.swift
//  kernel_frenzy
//
//  Created by admin49 on 16/04/25.
//

import SwiftUI

struct NeumorphicCardView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("This is a Neumorphic Card")
                .font(.system(size: 25).bold())
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ")
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
        }
        .NeumorphicStyle()
    }
}

struct ContentViews: View {
    var body: some View {
        VStack {
            Spacer()
            NeumorphicCardView()
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.offWhite)
        .ignoresSafeArea()
    }
}

struct NeumorphicButton: ButtonStyle {
func makeBody(configuration:Self.Configuration) -> some View {
        configuration.label
    }
}
