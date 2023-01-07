//
//  CustomAnnotationMark.swift
//  HobKnob
//
//  Created by Natanael Jop on 19/11/2022.
//

import SwiftUI

struct CustomAnnotationMark: View {
    @Environment(\.colorScheme) var scheme
    let imageURL: String
    var body: some View {
        ZStack(alignment: .top){
            Color.customBlue
                .clipShape(CustomMarkShape())
            BlurView(style: .regular)
                .mask {
                    CustomMarkShape()
                }
            CustomAsyncImage(url: imageURL, size: CGSize(width: 50, height: 50))
                .clipShape(Circle())
                .padding(.top, 8)
//            Circle()
//                .stroke(lineWidth: 3)
//                .fill(Color.label)
        }.frame(width: 100, height: 100)
            .scaleEffect(0.7)
    }
}

struct CustomMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY - rect.height/6), control: CGPoint(x: rect.maxX + rect.width/10, y: rect.height/5))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX - rect.width/10, y: rect.height/5))
        
        return path
    }
}

struct CustomAnnotationMark_Previews: PreviewProvider {
    static var previews: some View {
        CustomAnnotationMark(imageURL: Constants.img1)
    }
}
