//
//  ConversationCellViewModel.swift
//  HobKnob
//
//  Created by Natanael Jop on 06/12/2022.
//

import SwiftUI
import Firebase

class ConversationCellViewModel: ObservableObject {
    @Published var message: Message
    
    init(_ message: Message) {
        self.message = message
        fetchUser()
    }
    
    var chatPartnerId: String {
        return message.fromId == UserViewModel.shared.currentSession?.uid ? message.toId : message.fromId
    }
    
    func fetchUser() {
        let db = Firestore.firestore()
        db.collection(Constants.Firebase.usersDB)
            .document(chatPartnerId)
            .getDocument { snapshot, error in
                if let snapshot = snapshot {
                    guard let user = try? snapshot.data(as: User.self) else { return }
                    DispatchQueue.main.async {
                        self.message.user = user
                    }
                }
            }
    }
}


