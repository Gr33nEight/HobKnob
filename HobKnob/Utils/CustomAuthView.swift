//
//  CustomAuthView.swift
//  HobKnob
//
//  Created by Natanael Jop on 16/11/2022.
//

import SwiftUI

struct CustomAuthView<Content: View, Destination: View>: View {
    let title: String
    @ViewBuilder var destination: Destination
    @ViewBuilder var content: Content

    var onTapGesture: (() -> Void)?
    var action: (() -> Void)?
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            HStack{
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.reversedLabel)
                        .font(.system(size: 20, weight: .semibold))
                }
                Spacer()
            }.padding(.horizontal)
            Text(title)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .padding(.top)
                .multilineTextAlignment(.center)
            content
            Spacer()
            if let action = action {
                Button(action: { action() }) {
                    Text("Sign In")
                        .font(.system(size: 25, weight: .semibold))
                        .customButtonContentStyle()
                        .padding()
                }.customButtonStyle()
            }else {
                NavigationLink(destination: { destination }) {
                    Text("Next")
                        .font(.system(size: 25, weight: .semibold))
                        .customButtonContentStyle()
                        .padding()
                }.customButtonStyle()
                    .simultaneousGesture(TapGesture().onEnded({ _ in
                        if let onTapGesture = onTapGesture {
                            onTapGesture()
                        }
                    }))
            }
        }.customBackground()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}
