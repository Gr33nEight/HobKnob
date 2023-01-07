//
//  Constants.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI
import MapKit
import Firebase

struct Constants {
    static let unknownError = "Some error has occured!\nPlease try again later."
    static let profileImgUrl = "https://scontent.fktw3-1.fna.fbcdn.net/v/t1.6435-9/117341654_1182579222128105_4177708421452578862_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=fc5GT0APxBYAX-yQGVd&_nc_ht=scontent.fktw3-1.fna&oh=00_AfBmcnp07tpQG7I8UUanYsr5v38DG0-QlBCdM5eBIkuyQA&oe=639DAE6D"
    static let img1 = "https://picsum.photos/id/237/200"
    static let img2 = "https://picsum.photos/id/236/200"
    static let img3 = "https://picsum.photos/id/235/200"
    static let img4 = "https://picsum.photos/id/234/200"
    static let sexes = ["male", "female", "other"]
    static var interests: [Tag] = [
        Tag(name: "painting", image: "paintbrush.pointed.fill"),
        Tag(name: "IT", image: "desktopcomputer"),
        Tag(name: "goegraphy", image: "globe.americas.fill"),
        Tag(name: "traveling", image: "airplane.departure"),
        Tag(name: "DIY", image: "wrench.and.screwdriver.fill"),
        Tag(name: "cycling", image: "bicycle"),
        Tag(name: "singing", image: "music.mic"),
        Tag(name: "music", image: "music.note"),
        Tag(name: "sport", image: "sportscourt.fill"),
        Tag(name: "soccer", image: "soccerball"),
        Tag(name: "nature", image: "camera.macro"),
        Tag(name: "animals", image: "lizard.fill"),
        Tag(name: "basketball", image: "basketball"),
        Tag(name: "video games", image: "gamecontroller.fill")
    ]
    let placeholderUser = User(uid: "", name: "Test User", age: "23", sex: "female", email: "test.user@gmail.com", interests: ["soccer", "IT", "traveling", "animals"], profileImage: Constants.img1, restImages: [Constants.img4, Constants.img2], location: GeoPoint(latitude: MKCoordinateRegion.goldenGateRegion().center.latitude, longitude: MKCoordinateRegion.goldenGateRegion().center.longitude), geohash: "", token: "")

    enum Firebase {
        static let usersDB = "users"
        static let conversationDB = "conversations"
        static let messages = "messages"
        static let posts = "posts"
        static let interests = "interests"
        static let allInterests = "all"
        static let comments = "comments"
    }
    
}


//TODO: Repair adding/deleting images from onboard view ✅
//TODO: Allow not friends to send only one message ❓MAYBE LATER❓
//TODO: Allow user to upload more than one image ✅
//TODO: Manage writing comments ✅
//TODO: Manage liking ✅
//TODO: Edit Account ✅

/// Final Tasks
//TODO: Reset all values on sign out
//TODO: Create: Something went wrong view
//TODO: Create: No Interent Conncection View

