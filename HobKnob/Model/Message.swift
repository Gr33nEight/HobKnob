//
//  Message.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId: String
    let toId: String
    let text: String
    var date: Date
    
    var user: User?
}
