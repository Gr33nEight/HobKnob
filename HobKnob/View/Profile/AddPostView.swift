//
//  AddPostView.swift
//  HobKnob
//
//  Created by Natanael Jop on 08/12/2022.
//

import SwiftUI

struct AddPostView: View {
    
    @AppStorage("darkMode") private var darkMode = false
    
    @State private var content = ""
    @State private var showImagePicker: Bool = false
    @State private var image: Image? = nil
    @State private var originalImage: UIImage? = nil
    @State private var showActionSheet: Bool = false
    @State private var sourceType: SourceType = .photoLibrary
    @State private var pickedImage = 0
    @State private var uploading = false
    @State private var images = [String]()
    
    @ObservedObject var postViewModel: PostViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .foregroundColor(.label)
                }.customButtonStyle()
                Spacer()
                Button(action: {
                    guard let uid = UserViewModel.shared.currentSession?.uid else { return }
                    postViewModel.upload(post: Post(ownerID: uid, text: content, images: images, date: Date())) {
                        dismiss()
                    }
                }) {
                    Text("Post")
                        .foregroundColor(.customBlue)
                        .padding(10)
                        .padding(.horizontal, 10)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 25).fill(Color.customBlue.opacity(0.2))
                                RoundedRectangle(cornerRadius: 25).stroke()
                            }
                        )
                }.customButtonStyle()
            }.padding()
                .overlay(
                    Divider()
                    , alignment: .bottom
                )
            ScrollView(showsIndicators: false) {
                HStack(alignment: .top, spacing: 15) {
                    CustomAsyncImage(url: UserViewModel.shared.currentUser?.profileImage ?? Constants.img1, size: CGSize(width: 50, height: 50))
                        .clipShape(Circle())

                        TextField("What's happening?", text: $content, axis: .vertical)
                }.padding(15)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(images, id:\.self) { img in
                            postImage(img) {
                                images = images.filter({$0 != img})
                            }
                        }
                    }.padding(.horizontal)
                        .frame(maxHeight: UIScreen.main.bounds.width/2)
                        .padding(.leading, 60)
                }
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    if images.count < 4 {
                        showActionSheet = true
                    }
                }) {
                    Image(systemName: "photo.circle.fill")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(.customBlue)
                }.customButtonStyle()
            }.padding()
        }.loadingOverlay(show: $uploading)
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
            if let originalImage = originalImage {
                saveImage(image: originalImage)
            }
            originalImage = nil
        }, content: {
            PhotoCaptureView(showImagePicker: $showImagePicker, image: $image, originalImage: $originalImage, sourceType: sourceType)
        })
    }
    @ViewBuilder
    private func postImage(_ url: String, xmark action: @escaping () -> Void) -> some View {
        ZStack {
            if let url = URL(string: url) {
                CacheAsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color(.systemGray6)
                            ProgressView()
                        }.frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                             .clipped()
                    case .failure:
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .scaledToFill()
                                     .clipped()
                            } else{
                                ZStack{
                                    Color(.systemGray6)
                                    ProgressView()
                                }.frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                            }
                        }
                    @unknown default:
                        ZStack{
                            Color(.systemGray6)
                            ProgressView()
                        }.frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                    }
                }
            }else{
                ZStack{
                    Color(.systemGray6)
                    ProgressView()
                }.frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
            }

        }.cornerRadius(15)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                Button(action: { action() }, label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Circle().fill(Color.white))
                }).padding()
                , alignment: .topTrailing
            )
    }
}

extension AddPostView {
    private func saveImage(image: UIImage?) {
        withAnimation{uploading = true}
        if let image = image {
            if let resizedImage = image.resized(width: 700) {
                if let data = resizedImage.pngData() {
                    postViewModel.uploadPhoto(data: data, type: "post", completion: { url  in
                        if let url = url?.absoluteString {
                            images.append(url)
                            withAnimation{uploading = false}
                        } else {
                            postViewModel.errorService = .error(message: Constants.unknownError)
                        }
                    })
                }else {
                    postViewModel.errorService = .error(message: Constants.unknownError)
                }
            }else {
                postViewModel.errorService = .error(message: Constants.unknownError)
            }
        }else {
            postViewModel.errorService = .error(message: Constants.unknownError)
        }
    }
}
//
//struct AddPostView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddPostView()
//    }
//}
