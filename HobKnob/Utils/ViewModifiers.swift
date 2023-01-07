//
//  ViewModifiers.swift
//  HobKnob
//
//  Created by Natanael Jop on 30/11/2022.
//

import SwiftUI

struct CustomButtonContentStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                ZStack {
                    Color.customBlue.opacity(0.2)
                    RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2).fill(Color.label.opacity(0.3))
                }
            )
            .cornerRadius(20)
    }
}

struct ImgHelper: Identifiable {
    var id = UUID()
    var imgs: [String]
}

struct ImagePreview: ViewModifier {
    @Binding var images: ImgHelper?
    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $images, content: { imgs in
                ImagePreviewView(images: imgs.imgs)
            })
    }
}

struct CustomBackGround: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(colors: [Color.customBlue, Color.clear], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }
}

struct ErrorAlert: ViewModifier {
    @Binding var errorService: ErrorService
    func body(content: Content) -> some View {
        content
            .alert(errorService.message, isPresented: .constant(!errorService.message.isEmpty)) {
                Button("OK", role: .cancel) { errorService = .error(message: "") }
            }
    }
}

struct LoadingOverlay: ViewModifier {
    @Binding var show: Bool
    func body(content: Content) -> some View {
        content
            .blur(radius: show ? 3 : 0)
            .overlay(
                ZStack {
                    if show {
                        LoadingScreen()
                    }
                }
            )
    }
}

