//
//  PostViewModel.swift
//  HobKnob
//
//  Created by Natanael Jop on 21/11/2022.
//

import SwiftUI
import Firebase
import FirebaseStorage

class PostViewModel: ObservableObject {
    @Published var errorService: ErrorService = .nul
    @Published var posts = [Post]()
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    let user: User
    
    init(user: User) {
        self.user = user
        fetchPosts()
    }
    
    func upload(post: Post, completion: @escaping () -> Void) {
        let ref = db.collection(Constants.Firebase.posts).document("live-posts").collection(post.ownerID).document()
        do {
            try ref.setData(from: post, completion: { error in
                if let error = error {
                    self.errorService = .error(message: error.localizedDescription)
                }else{
                    self.fetchPosts()
                    completion()
                }
            })
        } catch let error {
            self.errorService = .error(message: error.localizedDescription)
        }
    }
    
    func fetchPosts() {
        guard let uid = user.id else { return }
        let query = db
            .collection(Constants.Firebase.posts)
            .document("live-posts")
            .collection(uid)
            .order(by: "date", descending: true)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else if let snapshot = snapshot {
                do {
                    let posts = try snapshot.documents.compactMap({ try $0.data(as: Post.self)})
                    self.posts = posts
                    print(posts)
                } catch let error {
                    self.errorService = .error(message: error.localizedDescription)
                }
            }
        }
    }
    
    func uploadPhoto(data: Data, type: String, completion: @escaping (URL?) -> Void) {
        let imageName = UUID().uuidString
        let storageRef = storage.reference()
        let photoRef = storageRef.child("images/\(type)/\(imageName).png")
        
        photoRef.putData(data) { meta, error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            } else {
                photoRef.downloadURL { url, error in
                    if let error = error {
                        self.errorService = .error(message: error.localizedDescription)
                    } else if let url = url {
                        completion(url)
                    }
                }
            }
        }
    }
}


class LikeVM: ObservableObject {
    @Published var likes: [String]?
    let post: Post
    let user: User
    
    init(post: Post, user: User) {
        self.post = post
        self.user = user
        self.fetchLikes()
    }
    
    var amount: String {
        "\(likes?.count ?? 0)"
    }
    
    var iLiked: Bool {
        if let currentUid = UserViewModel.shared.currentSession?.uid {
            return likes?.contains(currentUid) ?? false
        }else{
            return false
        }
    }
    
    func fetchLikes() {
        guard let uid = user.id else { return }
        guard let postId = post.id else { return }
        
        let ref = Firestore.firestore()
            .collection(Constants.Firebase.posts)
            .document("live-posts")
            .collection(uid)
            .document(postId)
            .collection("likes")
            
        ref.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            self.likes = snapshot.documents.compactMap({$0.data()["uid"] as? String ?? ""})
        }
    }
    
    func like(completion: @escaping () -> Void) {
        guard let postId = post.id else { return }
        guard let currentUid = UserViewModel.shared.currentSession?.uid else { return }
        guard let uid = user.id else { return }
        
        let ref = Firestore.firestore()
            .collection(Constants.Firebase.posts)
            .document("live-posts")
            .collection(uid)
            .document(postId)
            .collection("likes")
            .document(currentUid)
        
        if self.iLiked {
            ref.delete(completion: { _ in completion() })
        }else{
            ref.setData(["uid" : currentUid]) { _ in completion() }
        }
    }
}
