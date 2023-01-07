//
//  UIImage.swift
//  HobKnob
//
//  Created by Natanael Jop on 30/11/2022.
//

import SwiftUI

extension UIImage {
    func resized(width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

