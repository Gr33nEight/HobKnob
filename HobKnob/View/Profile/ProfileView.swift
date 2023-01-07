//
//  ProfileView.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import Firebase

import SwiftUI
import MapKit

struct ProfileView: View {
    @EnvironmentObject var navBarVM: NavigationBarViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var friendsVM: FriendsViewModel
    @Environment(\.colorScheme) var scheme
    @Environment(\.dismiss) var dismiss
    
    var user: User
    
    var isCurrentUser: Bool {
        if let id = userVM.currentUser?.id {
            return id == user.id
        }else{
            return false
        }
    }
    
    @StateObject var postVM: PostViewModel
    @State private var currentImg = ""
    @State var offset: CGFloat = 0
    @State var startOffset: CGFloat = 0
    @State var imageOffset: CGFloat = 0
    @State var goToEditProfileView = false
    @State var pickedImages: ImgHelper?
    @State private var showAddPostView = false
    @State private var friendState: FriendState = .nothing
    
    init(user: User) {
        self.user = user
        _postVM = StateObject(wrappedValue: PostViewModel(user: user))
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0){
                        ZStack(alignment: .bottom){
                            RestImages
                            ZStack(alignment: .bottom) {
                                ZStack(alignment: .bottom){
                                    BlurView(style: scheme == .light ? .prominent : .dark)
                                        .opacity(getOpacity())
                                        .zIndex(0)
                                    ActionButtons
                                        .zIndex(2)
                                }.zIndex(1)
                                    .offset(getButtonsOffset())
                                ProfileImage.zIndex(1)
                            }.offset(y: 75)
                            
                        }.zIndex(1)
                        VStack{
                            Info
                            Interests
                            LazyVStack {
                                ForEach(postVM.posts) { post in
                                    FormattedPost(lastCommentVM: LastCommentVM(post: post), post: post, user: user)
                                }.padding()
                            }
                        }.padding(.top)
                        .padding(.top, 85)
                        .padding(.bottom, 150)
                    }.overlay (
                        GeometryReader { proxy -> Color in
                            let minY = proxy.frame(in: .global).minY
                            
                            DispatchQueue.main.async {
                                if startOffset == 0 {
                                    startOffset = minY
                                }
                                offset = startOffset - minY
                            }
                            
                            return Color.clear
                        }.frame(width: 0, height: 0)
                        , alignment: .top
                    )
                }.edgesIgnoringSafeArea(.top)
                
            }.frame(maxHeight: .infinity, alignment: .top)
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .navigationTitle("")
        }.imagePreview(images: $pickedImages)
            .onAppear {
                UIScrollView.appearance().bounces = false
            }
            .onDisappear {
                UIScrollView.appearance().bounces = true
            }
            .fullScreenCover(isPresented: $showAddPostView) {
                AddPostView(postViewModel: postVM)
            }
            .errorAlert(errorService: $postVM.errorService)
    }
}

// MARK: UI

extension ProfileView {
    private var RestImages: some View {
        ScrollView(.horizontal, showsIndicators: false){
            ZStack {
                if (user.restImages.count) == 1 {
                    CustomAsyncImage(url: user.restImages.first ?? "", size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.75))
                }else if (user.restImages.count) > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        TabView(selection: $currentImg) {
                            ForEach(user.restImages, id: \.self) { img in
                                CustomAsyncImage(url: img, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.75))
                            }
                        }.tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.75)
                    }
                } else{
                    Text("error")
                }
            }.onTapGesture {
                previewImg(imgs: user.restImages)
            }
        }.edgesIgnoringSafeArea(.top)
            .overlay(
                ZStack {
                    if !isCurrentUser {
                        Button(action: { dismiss() }, label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.label)
                                .padding(10)
                                .background(Circle().fill(Color.reversedLabel))
                        }).customButtonStyle()
                    }
                }.padding()
                    .padding(.top, 50)
                , alignment: .topLeading
            )
    }
    private var ProfileImage: some View {
        ZStack{
            CustomAsyncImage(url: user.profileImage, size: CGSize(width: 150, height: 150))
                .clipShape(Circle())
            Circle().stroke(lineWidth: 2)
                .frame(width: 150, height: 150)
        }.onTapGesture {
            previewImg(imgs: [user.profileImage])
        }
        .overlay(
            GeometryReader{ reader -> Color in
                let width = reader.frame(in: .global).maxX
                
                DispatchQueue.main.async {
                    if imageOffset == 0 {
                        imageOffset = width
                    }
                }
                return Color.clear
            }.frame(width: 0, height: 0)
        )
        .scaleEffect(getImageScale())
        .offset(getImageOffset())
    }
    private var Interests: some View {
        TagView(alignment: .center, spacing: 10){
            ForEach(user.interests, id: \.self) { tag in
                Label(tag, systemImage: returnImage(fromTag: tag))
                    .foregroundColor(Color.label)
                    .padding(.horizontal, 12)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            Color.customBlue.opacity(0.2)
                            RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 4).fill(Color.customBlue)
                        }.opacity(1)
                    )
                    .cornerRadius(20)
            }
        }.padding(.top)
        .padding(.bottom, CGFloat(user.interests.count/2) * 25.0)
    }
    
    private var Info: some View {
        VStack {
            Text(user.name)
                .font(.system(size: 25, weight: .semibold))
            HStack(spacing: 0) {
                Text(user.age)
                Text(", ")
                Text(user.sex)
            }.foregroundColor(Color(.label).opacity(0.6))
        }
    }
    
    private var ActionButtons: some View {
        HStack {
            if isCurrentUser {
                Button(action: {
                    showAddPostView = true
                }) {
                    Text("Add Post")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.customBlue)
                        .padding(10)
                        .background(
                            ZStack {
                                BlurView(style: scheme == .light ? .extraLight : .dark)
                                Color.customBlue.opacity(0.2)
                            }.cornerRadius(20)
                        )
                }.padding(.top)
                    .padding(.horizontal, 10)
                    .padding(7)
                    .customButtonStyle()
            }else{
                NavigationLink(destination: { ConversationView(user: user)}) {
                    Text("Send Message")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.customBlue)
                        .padding(10)
                        .background(
                            ZStack {
                                BlurView(style: scheme == .light ? .extraLight : .dark)
                                Color.customBlue.opacity(0.2)
                            }.cornerRadius(20)
                        )
                }.padding(.top)
                    .padding(.horizontal, 10)
                    .padding(7)
                    .customButtonStyle()
            }
            
            Spacer()
            if isCurrentUser {
                Button(action: { goToEditProfileView = true }) {
                    Text("Edit Profile")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.customBlue)
                        .padding(10)
                        .background(
                            ZStack {
                                BlurView(style: scheme == .light ? .extraLight : .dark)
                                Color.customBlue.opacity(0.2)
                            }.cornerRadius(20)
                        )
                }.padding(.top)
                    .padding(.horizontal, 10)
                    .padding(7)
                    .customButtonStyle()
                    .overlay {
                        NavigationLink(isActive: $goToEditProfileView, destination: {EditProfileView()}, label: {EmptyView()})
                    }
            }else{
                friendState.content(vm: friendsVM, user: user, state: { friendState = $0 }, scheme: scheme)
            }
        }.onAppear {
            friendsVM.checkIfUserIsWasInvited(user) { state in
                friendState = state
            }
        }
        .onChange(of: friendsVM.friends.count) { _ in
            friendsVM.fetchFriends()
        }
    }
    @ViewBuilder
    private func returnRightPost() -> some View {
        
    }
}

struct FormattedPost: View {
    @ObservedObject var lastCommentVM: LastCommentVM
    let post: Post
    let user: User
    @State var comment: CommentVM? = nil
    var body: some View {
        ZStack {
            if let video = post.video {
                PostCell(type: .video(video: video, text: post.text), user: user, post: post, lastComment: comment)
            } else if post.images != nil && !(post.images ?? [String]()).isEmpty {
                PostCell(type: .image(images: post.images!, text: post.text), user: user, post: post, lastComment: comment)
            } else {
                PostCell(type: .text(text: post.text), user: user, post: post, lastComment: comment)
            }
        }.onAppear {
            lastCommentVM.fetchLastComment { comment in
                if let comment = comment {
                    self.comment = CommentVM(comment: comment)
                }
            }
        }
    }
}

// MARK: Functions

let screenHeight = UIScreen.main.bounds.height
extension ProfileView {
    private func returnImage(fromTag tag: String) -> String {
        return Constants.interests.first(where: {$0.name == tag})?.image ?? "questionmark"
    }
    private func getImageOffset() -> CGSize {
        var size: CGSize = .zero
        
        size.height = offset > 0 ? offset <= screenHeight/3.7 ? offset * 0.2 : offset - screenHeight/4.6 : 0
        return size
    }
    
    private func getImageScale() -> CGFloat {
        var scale: CGFloat = 1
        scale = offset >= -100 ? offset <= screenHeight/3.7 ? (-offset*1.5 + screenHeight)/850 : 0.59 : 1
        return scale
    }
    
    private func getButtonsOffset() -> CGSize {
        var size: CGSize = .zero
        size.height = offset > 0 ? offset <= screenHeight/3.32 ? -offset * 0.01 : offset - screenHeight/3.3 : 0
        return size
    }
    
    private func getOpacity() -> CGFloat {
        var opacity: CGFloat = 0
        opacity = offset <= screenHeight/10 ? 0 : (offset*offset)/screenHeight/100
        return opacity
    }
    
    private func previewImg(imgs: [String]) {
        pickedImages = ImgHelper(imgs: imgs)
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(user: User(name: "Tester Kowalski", age: "25", sex: "male", email: "test.user@gmail.com", interests: ["basketball", "sport", "music" , "IT", "traveling", "animals"], profileImage: Constants.profileImgUrl, restImages: [Constants.img2, Constants.img4, Constants.img2], location: GeoPoint(latitude: MKCoordinateRegion.goldenGateRegion().center.latitude, longitude: MKCoordinateRegion.goldenGateRegion().center.longitude))).environmentObject(UserViewModel()).environmentObject(NavigationBarViewModel())
//    }
//}
