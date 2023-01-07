//
//  User.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var uid: String
    var name: String
    var age: String
    var sex: String
    var email: String
    var interests: [String]
    var profileImage: String
    var restImages: [String]
    var location: GeoPoint
    var geohash: String
    var token: String
}
 
