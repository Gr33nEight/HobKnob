//
//  MessageViewModel.swift
//  HobKnob
//
//  Created by Natanael Jop on 29/11/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class MessageViewModel: ObservableObject {
    let db = Firestore.firestore()
        
    @Published var messages = [Message]()
    @Published var errorService: ErrorService = .nul
    
    let user: User
    
    init(user: User){
        self.user = user
        fetchMessages()
    }
    
    func fetchMessages() {
        guard let currentUid = UserViewModel.shared.currentSession?.uid else { return }
        guard let chatPartnerId = user.id else { return }
        
        let query = db
            .collection(Constants.Firebase.messages)
            .document(currentUid)
            .collection(chatPartnerId)
            .order(by: "date", descending: false)
        
        query.addSnapshotListener { snapshot, error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else{
                guard let changes = snapshot?.documentChanges.filter({$0.type == .added}) else { return }
                var messages = changes.compactMap({ try? $0.document.data(as: Message.self) })
                
                for (index, message) in messages.enumerated() where message.fromId != currentUid {
                    messages[index].user = self.user
                }
                
                self.messages.append(contentsOf: messages)
            }
        }
    }
    
    func sendMessage(_ messageText: String) {
        guard let currentUid = UserViewModel.shared.currentSession?.uid else { return }
        guard let chatPartnerId = user.id else { return }
        
        let currentUserRef = db.collection(Constants.Firebase.messages).document(currentUid).collection(chatPartnerId).document()
        let chatPartnerRef = db.collection(Constants.Firebase.messages).document(chatPartnerId).collection(currentUid)
        
        let recentCurrentRef = db.collection(Constants.Firebase.messages).document(currentUid).collection("recent-messages").document(chatPartnerId)
        let recentPartnerRef = db.collection(Constants.Firebase.messages).document(chatPartnerId).collection("recent-messages").document(currentUid)
        
        
        let messageId = currentUserRef.documentID
        
        let data: [String : Any] = [
            "text": messageText,
            "fromId": currentUid,
            "toId": chatPartnerId,
            "date": Date()
        ]
        
        currentUserRef.setData(data)
        chatPartnerRef.document(messageId).setData(data)
        
        recentCurrentRef.setData(data)
        recentPartnerRef.setData(data)
    }
}

struct MessVM {
    let message: Message
    
    init(_ message: Message) {
        self.message = message
    }
    
    var currentUid: String {
        return UserViewModel.shared.currentSession?.uid ?? ""
    }
    
    var isFromCurrentUser: Bool {
        return message.fromId == currentUid
    }
    
    var currentUserProfileImageUrl: String {
        return UserViewModel.shared.currentUser?.profileImage ?? ""
    }
    
    var profileImageUrl: String {
        return message.user?.profileImage ?? Constants.img1
    }
}
