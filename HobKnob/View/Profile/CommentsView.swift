//
//  CommentsView.swift
//  HobKnob
//
//  Created by Natanael Jop on 15/12/2022.
//

import SwiftUI

struct CommentsView: View {
    @StateObject var commentsVM = CommentsViewModel()
    @EnvironmentObject var navBarVM: NavigationBarViewModel
    let post: Post
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ForEach(commentsVM.comments.sorted(by: {$0.date > $1.date})){ com in
                    CommentCell(comment: CommentVM(comment: com))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
            }
            Spacer()
            CommentBar(commentsVM: commentsVM, post: post)
        }.onAppear {
            navBarVM.showBar = false
            commentsVM.fetchComments(post: post)
        }
        .onDisappear {
            navBarVM.showBar = true
        }
        .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct CommentBar: View {
    @State var commentText = ""
    @ObservedObject var commentsVM: CommentsViewModel
    let post: Post
    var body: some View {
        VStack {
            Rectangle()
                .frame(height: 0.3)
            HStack {
                TextField("Say something...", text: $commentText, axis: .vertical)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Button {
                    commentsVM.writeComment(commentText, post: post)
                    commentText = ""
                } label: {
                    Text("SEND")
                        .bold()
                }
                
            }.padding(30)
        }
    }
}

struct CommentCell: View {
    @ObservedObject var comment: CommentVM
    var body: some View {
        HStack(spacing: 15){
            CustomAsyncImage(url: comment.userImage, size: CGSize(width: 40, height: 40))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 10){
                Text(comment.text)
                HStack(spacing: 30){
                    Text(comment.userName)
                    Text(computeDifference(from: comment.date, to: Date())).foregroundColor(.gray)
                    Spacer()
                }.font(.system(size: 12))
                    .foregroundColor(.label)
                    .fontWeight(.semibold)
            }
            Spacer()
        }
    }
    func computeDifference(from fromDate: Date, to toDate: Date) -> String {
        let delta = toDate - fromDate
        if delta.doubleFromTimeInterval().rounded() > 0  {
            return "\(Int(delta.doubleFromTimeInterval().rounded()))h"
        }else{
            return "\(Int((delta.doubleFromTimeInterval() * 60).rounded()))m"
        }
    }
}

extension TimeInterval{
    func doubleFromTimeInterval() -> Double {
        let time = CGFloat(self)
        let hours = (time / 3600)
        
        return hours
        
    }
}
extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
