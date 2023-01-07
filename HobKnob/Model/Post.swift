//
//  Post.swift
//  HobKnob
//
//  Created by Natanael Jop on 21/11/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Post: Codable, Identifiable {
    @DocumentID var id: String?
    var ownerID: String
    var text: String
    var images: [String]?
    var video: String?
    var date: Date
}

struct Comment: Codable, Identifiable {
    @DocumentID var id: String?
    var fromId: String
    var text: String
    var date: Date
}

