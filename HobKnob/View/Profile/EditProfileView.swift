//
//  EditProfileView.swift
//  HobKnob
//
//  Created by Natanael Jop on 21/11/2022.
//

import SwiftUI

// url -> img -> upload original -> zmineń w bazie
// url -> usuń url -> img -> upload original -> zamien w bazie


struct EditProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    @State private var uploading = false
    
    //MARK: Details
    
    @State var name = ""
    @State var age = ""
    @State var sex = ""
    
    //MARK: Images
    
    @State private var showImagePicker: Bool = false
    @State private var image: Image? = nil
    @State private var originalImage: UIImage? = nil
    @State private var showActionSheet: Bool = false
    @State private var sourceType: SourceType = .photoLibrary
    @State var pickedImage = 0

    
    @State var interests = [String]()
    @State private var imageWidth = 0.0
    
    // URLs
    @State var profileImage = ""
    @State var restImages = ["", "", "", "", "", ""]
    
    // local imgs
    @State private var tempOriginalImages: [UIImage?] = [nil, nil, nil, nil, nil, nil, nil]
    
    //ready to upload
    var originalImages: [UIImage] {
        tempOriginalImages.compactMap({$0})
    }
    
    @State var uploadedImages = [String]()
    @State var uploadedProfilImage = ""
    
    @EnvironmentObject var userVM: UserViewModel
    
    var profileImageNum: Int {
        if profileImage == "" {
            return 1
        }else{
            return 0
        }
    }
    
    var user: User {
        return userVM.currentUser!
    }
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ProfileImg
                Details
                Images
                Interests
            }
        }.onAppear {
            name = user.name
            age = user.age
            sex = user.sex
            profileImage = user.profileImage
            for i in restImages.indices {
                if i < user.restImages.count {
                    restImages[i] = user.restImages[i]
                }else{
                    restImages[i] = ""
                }
            }
            interests = user.interests
            UIScrollView.appearance().bounces = true
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
            if originalImage != nil {
                if let originalImage = originalImage {
                    tempOriginalImages[pickedImage] = originalImage
                }
                originalImage = nil
            }
            print(originalImages)
        }, content: {
            PhotoCaptureView(showImagePicker: $showImagePicker, image: $image, originalImage: $originalImage, sourceType: sourceType)
        })
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if profileImage != "" && restImages.filter({$0 != ""}).count == user.restImages.count && tempOriginalImages.filter({$0 != nil}).isEmpty {
                        let user = User(uid: user.uid, name: name, age: age, sex: sex, email: user.email, interests: interests, profileImage: user.profileImage, restImages: user.restImages, location: user.location, geohash: user.geohash, token: user.token)
                        userVM.updateUser(user) {
                            userVM.fetchUser()
                            dismiss()
                        }
                    } else {
                        if profileImage != "" {
                            uploadedProfilImage = profileImage
                        }
                        originalImages.forEach { img in
                            saveImage(image: img)
                        }
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.customBlue)
                        .padding(10)
                        .background(
                            ZStack {
                                BlurView(style: scheme == .light ? .extraLight : .dark)
                                Color.customBlue.opacity(0.2)
                            }.cornerRadius(20)
                        )
                }
                    .customButtonStyle()
            }
        })
        .onChange(of: uploading) { newValue in
            if !newValue && uploadedImages.count + profileImageNum == originalImages.count + restImages.filter({$0 != ""}).count {
                let user = User(uid: user.uid, name: name, age: age, sex: sex, email: user.email, interests: interests, profileImage: uploadedProfilImage, restImages: uploadedImages, location: user.location, geohash: user.geohash, token: user.token)
                if uploadedImages.count >= 1 && uploadedProfilImage != "" {
                    userVM.updateUser(user) {
                        userVM.fetchUser()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: UI

extension EditProfileView {
    private var Details: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .leading){
                if name.isEmpty {
                    Text("Name")
                        .foregroundColor(Color(.systemGray5))
                }
                TextField("", text: $name)
                    .foregroundColor(.label)
            }.padding(.leading)
                .customButtonContentStyle()
            ZStack(alignment: .leading){
                if age.isEmpty {
                    Text("Age")
                        .foregroundColor(Color(.systemGray5))
                }
                TextField("", text: $age)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.label)
            }.padding(.leading)
                .customButtonContentStyle()
            HStack{
                ZStack(alignment: .leading){
                    if sex.isEmpty {
                        Text("Sex")
                            .foregroundColor(Color(.systemGray5))
                            .padding(.leading, 10)
                    }
                    Picker("", selection: $sex) {
                        ForEach(Constants.sexes, id:\.self) { Text($0)}
                    }.labelsHidden()
                        .accentColor(sex.isEmpty ? Color.clear : Color.label)
                }.padding(.leading, 5)
                Spacer()
            }.customButtonContentStyle()
        }.padding()

    }
    private var ProfileImg: some View {
        Button {
            if profileImage == "" {
                if tempOriginalImages[0] != nil {
                    tempOriginalImages[0] = nil
                }else{
                    pickedImage = 0
                    showActionSheet = true
                }
            }else{
                profileImage = ""
            }
        } label: {
            ZStack{
                ZStack{
                    if profileImage == "" {
                        if let profileImg = tempOriginalImages[0] {
                            Image(uiImage: profileImg)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                        }else{
                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .frame(width: 150, height: 150)
                                .background(Circle().fill(Color.reversedLabel))
                        }
                    }else{
                        CustomAsyncImage(url: profileImage, size: CGSize(width: 150, height: 150))
                    }
                }
                .clipShape(Circle())
                Circle().stroke(lineWidth: 2)
                    .frame(width: 150, height: 150)
            }
        }.customButtonStyle()
    }
    
    private var Images: some View {
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 10) {
            ForEach(0...5, id:\.self) { i in
                Button(action: {
                    if restImages[i] == "" {
                        if tempOriginalImages[i+1] != nil {
                            tempOriginalImages[i+1] = nil
                        }else{
                            pickedImage = i+1
                            showActionSheet = true
                        }
                    }else{
                        restImages[i] = ""
                    }
                }) {
                    RectImage(image: restImages[i], uiImage: tempOriginalImages[i+1])
                }.customButtonStyle()
            }
        }.padding()
            .padding(.horizontal)
    }
    
    private func RectImage(image: String, uiImage: UIImage?) -> some View {
        ZStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 150)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 2)
            } else if image == "" {
                Image(systemName: "plus")
                    .foregroundColor(Color.reversedLabel)
                    .font(.title)
                    .bold()
                    .frame(width: 100, height: 150)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 20).fill(Color.customBlue).opacity(0.3)
                            RoundedRectangle(cornerRadius: 20).stroke().fill(Color.label)
                        }
                    )
                    .padding(.horizontal, 2)
                
            }else {
                CustomAsyncImage(url: image, size: CGSize(width: 100, height: 150))
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 2)
                
            }
        }
    }
    
    private var Interests: some View {
        VStack {
            TagView(alignment: .center, spacing: 10){
                ForEach(Constants.interests) { tag in
                    Button(action: {
                        if interests.contains(tag.name) {
                            interests = interests.filter({$0 != tag.name})
                        }else{
                            interests.append(tag.name)
                        }
                    }) {
                        Label(tag.name, systemImage: tag.image)
                            .foregroundColor(Color.label)
                            .padding(.horizontal, 12)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.vertical, 10)
                            .background(
                                ZStack {
                                    Color.customBlue.opacity(0.2)
                                    RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 4).fill(Color.customBlue)
                                }.opacity(1)
                            )
                            .overlay(Color.reversedLabel.opacity(interests.contains(tag.name) ? 0 : 0.8))
                            .cornerRadius(20)
                    }.customButtonStyle()
                }
            }
        }.padding(10)
            .padding(.bottom, CGFloat(Constants.interests.count/2) * 25.0)
            .padding(.bottom, 140)
    }
}


extension EditProfileView {
    private func saveImage(image: UIImage) {
        withAnimation{uploading = true}
            if let resizedImage = image.resized(width: 500) {
                if let data = resizedImage.pngData() {
                    userVM.uploadPhoto(data: data, type: "profile", completion: { url  in
                        if let url = url?.absoluteString {
                            if originalImages.first == image && profileImage == "" {
                                uploadedProfilImage = url
                            } else {
                                uploadedImages.append(url)
                            }
                            if uploadedImages.count + profileImageNum == originalImages.count {
                                uploadedImages.append(contentsOf: restImages.filter({$0 != ""}))
                                withAnimation{uploading = false}
                            }
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

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
