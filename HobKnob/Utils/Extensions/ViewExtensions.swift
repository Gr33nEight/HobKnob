//
//  ViewExtensions.swift
//  HobKnob
//
//  Created by Natanael Jop on 30/11/2022.
//

import Foundation
import SwiftUI

extension View {
    func customBackground() -> some View {
        modifier(CustomBackGround())
    }
    func customButtonContentStyle() -> some View {
        modifier(CustomButtonContentStyle())
    }
    func customButtonStyle() -> some View {
        buttonStyle(CustomButtonStyle())
    }
    func errorAlert(errorService: Binding<ErrorService>) -> some View {
        modifier(ErrorAlert(errorService: errorService))
    }
    func loadingOverlay(show: Binding<Bool>) -> some View {
        modifier(LoadingOverlay(show: show))
    }
    func imagePreview(images: Binding<ImgHelper?>) -> some View {
        modifier(ImagePreview(images: images))
    }
    func customCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
