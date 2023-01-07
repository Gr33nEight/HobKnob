//
//  PostCell.swift
//  HobKnob
//
//  Created by Natanael Jop on 10/11/2022.
//

import SwiftUI
import AVKit

enum PostType {
    case text(text: String)
    case image(images: [String], text: String)
    case video(video: String, text: String)
    
    var name: String {
        switch self {
        case .text:
            return "text"
        case .image:
            return "image"
        case .video:
            return "video"
        }
    }
    
    @ViewBuilder var content: some View {
        switch self {
        case .text(let text):
            Text(text)
                .foregroundColor(.label)
                .multilineTextAlignment(.leading)
        case .image(let images, let text):
            VStack(alignment: .leading){
                Text(text)
                    .foregroundColor(.label)
                    .multilineTextAlignment(.leading)
                if images.count == 1 {
                    CustomAsyncImage(url: images.first!, size: CGSize(width: screenW - 30, height: screenW))
                        .cornerRadius(15)
                }else{
                    CarouselView(cardArray: images.compactMap({Card(image: $0)}))
                }
            }
        case .video(let video, let text):
            VStack(alignment: .leading){
                Text(text)
                    .foregroundColor(.label)
                    .multilineTextAlignment(.leading)
                VideoPlayer(player: AVPlayer(url: URL(string: video)!))
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(10)
                    .clipped()
            }
        }
    }
}

struct PostCell: View {
    let type: PostType
    let user: User
    var post: Post
    @State var images: ImgHelper?
    var lastComment: CommentVM?
    var body: some View {
            VStack {
                HStack(alignment: .top, spacing: 5) {
                    VStack(alignment: .leading){
                        HStack(spacing: 0) {
                            Text(user.name)
                                .foregroundColor(.label)
                                .font(.system(size: 16, weight: .semibold))
                            Text(", \(user.age)")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        type.content
                            .onTapGesture {
                                if type.name == "image" && post.images != nil {
                                    images = ImgHelper(imgs: post.images!)
                                }
                            }
                        NavigationLink(destination: { CommentsView(post: post) }) {
                            if let lastComment = lastComment {
                                CommentCell(comment: lastComment)
                                    .foregroundColor(.label)
                                    .padding(.horizontal, 10)
                            }
                        }.padding(.bottom, 5)
                        Divider()
                        HStack{
                            Spacer()
                            NavigationLink(destination: { CommentsView(post: post) }) {
                                Image(systemName: "bubble.left")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                    .padding(5)
                                    .background(Color.clear)
                            }
                            Spacer()
                            LikeButton(likeVM: LikeVM(post: post, user: user))
                            Spacer()
    //                        Button(action: {}) {
    //                            Image(systemName: "square.and.arrow.up")
    //                                .foregroundColor(Color(.label).opacity(0.5))
    //                        }
    //                        Spacer()
                        }
                        
                    }
                }
            }.imagePreview(images: $images)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}

struct LikeButton: View {
    @ObservedObject var likeVM: LikeVM
    @State var disabled = false
    var body: some View {
        HStack {
            Button(action: {
                disabled = true
                likeVM.like {
                    disabled = false
                }
            }) {
                Image(systemName: likeVM.iLiked ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(likeVM.iLiked ? Color.red : Color(.label).opacity(0.5))
                    .padding(5)
                    .background(Color.clear)
            }.disabled(disabled)
            Text(likeVM.amount)
        }
    }
}

//
//struct PostCell_Preview: PreviewProvider {
//    static var previews: some View {
//        PostCell(type: .image(images: [Constants.img1, Constants.img2, Constants.img3, Constants.img4], text: "Works"), user: Constants().placeholderUser, comments: [Comment](), likes: [String]())
////            .padding()
////        CommentsView()
//    }
//}
