//
//  ImagePreviewView.swift
//  HobKnob
//
//  Created by Natanael Jop on 30/11/2022.
//

import SwiftUI

struct ImagePreviewView: View {
    @Environment(\.dismiss) var dismiss
    let images: [String]
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            
            TabView {
                ForEach(images, id:\.self) { img in
                    CustomAsyncImage(url: img, size: CGSize(width: UIScreen.main.bounds.width, height: .infinity))
                        .scaledToFit()
                        .addPinchZoom()
                }
            }.ignoresSafeArea()
                .tabViewStyle(.page(indexDisplayMode: .automatic))
            
        }.overlay(
            Button(action: {dismiss()}) {
                Image(systemName: "xmark")
                    .padding()
                    .background(Color.clear)
            }.foregroundColor(.white)
                .font(.system(size: 18, weight: .semibold))
                .padding(.leading)
            , alignment: .topLeading
        )
    }
}
