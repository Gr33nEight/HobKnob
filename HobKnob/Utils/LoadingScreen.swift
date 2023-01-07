//
//  LoadingScreen.swift
//  HobKnob
//
//  Created by Natanael Jop on 26/11/2022.
//

import SwiftUI

struct LoadingScreen: View {
    @State var start = true
    @Environment(\.colorScheme) var scheme
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            Circle()
                .trim(from: 0.0, to: 0.8)
                .stroke(lineWidth: 10)
                .foregroundStyle(LinearGradient(colors: [Color.customBlue, Color.reversedLabel], startPoint: .bottom, endPoint: .top))
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(start ? 360 : 0))
                .animation(.linear(duration: 0.7).repeatForever(autoreverses: false))
                .padding(40)
                .background(BlurView(style: scheme == .dark ? .dark : .prominent).cornerRadius(20))
        }.ignoresSafeArea()
            .onAppear {
                withAnimation {
                    start.toggle()
                }
            }
    }
}

struct LoadingScrenn_Preview: PreviewProvider {
    static var previews: some View {
        LoadingScreen().preferredColorScheme(.light)
    }
}
