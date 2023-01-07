//
//  PhotoCapture.swift
//  HobKnob
//
//  Created by Natanael Jop on 25/11/2022.
//

import SwiftUI

enum SourceType {
    case photoLibrary
    case camera
}

struct PhotoCaptureView: View {
    
    @Binding var showImagePicker: Bool
    @Binding var image: Image?
    @Binding var originalImage: UIImage?
    var sourceType: SourceType
    
    var body: some View {
        ImagePicker(isShown: $showImagePicker, image: $image, originalImage: $originalImage, sourceType: sourceType)
    }
}

#if DEBUG
struct PhotoCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCaptureView(showImagePicker: .constant(false), image: .constant(Image("")), originalImage: .constant(UIImage()), sourceType: .photoLibrary)
    }
}
#endif
