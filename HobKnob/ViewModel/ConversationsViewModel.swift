//
//  ConversationsViewModel.swift
//  HobKnob
//
//  Created by Natanael Jop on 05/12/2022.
//

import SwiftUI
import Firebase

class ConversationsViewModel: ObservableObject {
    @Published var recentMessages = [Message]()
    @Published var isLoading = false
    
    let db = Firestore.firestore()
    
    init() {
        fetchRecentMessages()
    }
    
    func fetchRecentMessages() {
        withAnimation{ self.isLoading = true }
        guard let uid = UserViewModel.shared.currentSession?.uid else { return }
        
        let query = db.collection(Constants.Firebase.messages).document(uid)
            .collection("recent-messages")
            .order(by: "date", descending: true)
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            self.recentMessages = documents.compactMap({ try? $0.data(as: Message.self) })
            withAnimation{ self.isLoading = false }
        }
    }
}
