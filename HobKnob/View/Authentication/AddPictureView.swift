//
//  AddPictureView.swift
//  HobKnob
//
//  Created by Natanael Jop on 16/11/2022.
//

import SwiftUI

struct AddPictureView: View {
    
    @State private var showImagePicker: Bool = false
    @State private var image: Image? = nil
    @State private var originalImage: UIImage? = nil
    @State private var showActionSheet: Bool = false
    @State private var sourceType: SourceType = .photoLibrary
    @State private var pickedImage = 0
    @State private var uploading = false
    @State private var tempOriginalImages: [UIImage?] = [nil, nil, nil, nil, nil, nil, nil]
    
    var originalImages: [UIImage] {
        tempOriginalImages.compactMap({$0})
    }
    
    @ObservedObject var userVM: UserViewModel
    
    var body: some View {
        CustomAuthView(title: "Add a Picture", destination: {
            SubscriptionsView(userVM: userVM)
        }, content: {
            VStack {
                Spacer()
                Button(action: {
                    if userVM.images[0] != nil {
                        userVM.images[0] = nil
                        userVM.profileImage = ""
                    } else {
                        showActionSheet = true
                        pickedImage = 0
                    }
                }) {
                    if userVM.images[0] == nil {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .frame(width: 150, height: 150)
                            .background(Circle().fill(Color.reversedLabel))
                    }else{
                        if let image = userVM.images[0] {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipped()
                                .clipShape(Circle())
                        }
                    }
                }
                Spacer()
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 10) {
                    ForEach(1...6, id:\.self) { i in
                        Button(action: {
                            if userVM.images[i] != nil {
                                userVM.images[i] = nil
                                tempOriginalImages[i] = nil
                            } else {
                                pickedImage = i
                                showActionSheet = true
                            }
                        }) {
                            RectImage(image: userVM.images[i])
                        }.customButtonStyle()
                    }
                }.padding()
                    .padding(.horizontal)
            }
        }, onTapGesture: {
            originalImages.forEach { img in
                saveImage(image: img)
            }
        }) .loadingOverlay(show: $uploading)
        .actionSheet(isPresented: $showActionSheet, content: {
            ActionSheet(title: Text("Select"), message: nil, buttons: [
                .default(Text("Photo Library")) {
                    showImagePicker = true
                    sourceType = .photoLibrary
                },
                .default(Text("Camera")) {
                    showImagePicker = true
                    sourceType = .camera
                },
                .cancel()
            ])
        })
        .sheet(isPresented: $showImagePicker, onDismiss: {
            if originalImage != nil {
                userVM.images[pickedImage] = image
                if let originalImage = originalImage {
                    tempOriginalImages[pickedImage] = originalImage
                }
                originalImage = nil
            }
        }, content: {
            PhotoCaptureView(showImagePicker: $showImagePicker, image: $image, originalImage: $originalImage, sourceType: sourceType)
        })
    }
}


extension AddPictureView {
    private func RectImage(image: Image?) -> some View {
        ZStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 150)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 2)
            }else{
                Image(systemName: "plus")
                    .foregroundColor(Color.customBlue)
                    .font(.title)
                    .bold()
                    .frame(width: 100, height: 150)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.reversedLabel))
                    .padding(.horizontal, 2)
            }
        }
    }
}


//MARK: - Functions

extension AddPictureView {
    private func saveImage(image: UIImage) {
        withAnimation{uploading = true}
            if let resizedImage = image.resized(width: 500) {
                if let data = resizedImage.pngData() {
                    userVM.uploadPhoto(data: data, type: "profile", completion: { url  in
                        if let url = url?.absoluteString {
                            if originalImages.first == image {
                                userVM.profileImage = url
                            } else {
                                userVM.restImages.append(url)
                            }
                            withAnimation{uploading = false}
                        } else {
                            userVM.errorService = .error(message: Constants.unknownError)
                        }
                    })
                }else {
                    userVM.errorService = .error(message: Constants.unknownError)
                }
            }else {
                userVM.errorService = .error(message: Constants.unknownError)
            }
    }
}

//struct AddPictureView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddPictureView()
//    }
//}
