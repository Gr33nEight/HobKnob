//
//  CommentsViewModel.swift
//  HobKnob
//
//  Created by Natanael Jop on 15/12/2022.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class CommentsViewModel: ObservableObject {
    let db = Firestore.firestore()
    @Published var comments = [Comment]()
    @Published var errorService: ErrorService = .nul
    
    func fetchComments(post: Post) {
        guard let postID = post.id else { return }
        
        let query = db
            .collection(Constants.Firebase.comments)
            .document(postID)
            .collection("all")
            .order(by: "date", descending: true)
        
        query.addSnapshotListener { snapshot, error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else{
                guard let changes = snapshot?.documentChanges.filter({$0.type == .added}) else { return }
                let comments = changes.compactMap({ try? $0.document.data(as: Comment.self) })
                self.comments.append(contentsOf: comments)
            }
        }
    }
    
    func writeComment(_ commentText: String, post: Post) {
        guard let postID = post.id else { return }
        guard let uid = UserViewModel.shared.currentSession?.uid else { return }
        let ref = db.collection(Constants.Firebase.comments).document(postID).collection("all").document()
        let lastCommentRef = db.collection(Constants.Firebase.comments).document(postID)
        
        
        let data: [String : Any] = [
            "date": Date(),
            "fromId": uid,
            "text": commentText
        ]
        
        lastCommentRef.setData(data)
        ref.setData(data)
    }
}

class CommentVM: ObservableObject {
    @Published var user: User?
    let comment: Comment
    
    init(comment: Comment) {
        self.comment = comment
        self.commentOwner()
    }
    
    var text: String {
        comment.text
    }

    var date: Date {
        comment.date
    }
    
    var userName: String {
        user?.name ?? ""
    }
    
    var userImage: String {
        user?.profileImage ?? ""
    }
    
    func commentOwner() {
        let uid = comment.fromId 
        Firestore.firestore().collection(Constants.Firebase.usersDB)
            .document(uid)
            .getDocument { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard let user = try? snapshot.data(as: User.self) else { return }
                self.user = user
        }
    }
}

class LastCommentVM: ObservableObject {
    let post: Post
    
    init(post: Post){
        self.post = post
    }
    
    func fetchLastComment(completion: @escaping (Comment?) -> Void ) {
        guard let postId = post.id else { return }
        Firestore.firestore().collection(Constants.Firebase.comments).document(postId).getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            if snapshot.exists {
                do {
                    let comment = try snapshot.data(as: Comment.self)
                    completion(comment)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// "Comments" -> postsIds -> all -> comments
// "Comments" -> postsIds -> lastOne -> comment
