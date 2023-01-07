//
//  UserViewModel.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI
import FirebaseCore
import MapKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestoreSwift
import GeoFire

class UserViewModel: ObservableObject {
    @AppStorage("token") var token = ""
    @AppStorage("numOfInterestsInCommon") var numOfInterestsInCommon: Int = 3
    @AppStorage("range") var range: Double = 100
    @Published var isLoading = false
    @Published var errorService: ErrorService = .nul
    
    @Published var currentUser: User?
    @Published var currentSession: FirebaseAuth.User?
    
    static let shared = UserViewModel()
    
    var isLoggedIn: Bool {
        currentSession != nil
    }
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    let storage = Storage.storage()
    
    @Published var name = ""
    @Published var age = ""
    @Published var sex = ""
    @Published var email = ""
    @Published var password = ""
    @Published var interests = [String]()
    @Published var profileImage = ""
    @Published var restImages = [String]()
    @Published var location = GeoPoint(latitude: 0.0, longitude: 0.0)
    @Published var imagesUrl = [String]()
    @Published var images: [Image?] = [nil, nil, nil, nil, nil, nil, nil]
    
    init() {
        currentSession = auth.currentUser
        self.fetchUser()
    }
}

//MARK: - Interests
extension UserViewModel {
    func addUserIdToProperInteres(uid: String?, completion: @escaping () -> Void) {
        guard let uid = uid else { print("dupa"); return }
        if let userInterests = self.currentUser?.interests {
            for interest in userInterests {
                db
                    .collection(Constants.Firebase.interests)
                    .document(Constants.Firebase.allInterests)
                    .collection(interest)
                    .document(uid)
                    .setData(["uid" : uid]) { error in
                        if let error = error {
                            self.errorService = .error(message: error.localizedDescription)
                        }else{
                            completion()
                        }
                    }
            }
        }else {
            for interest in interests {
                db
                    .collection(Constants.Firebase.interests)
                    .document(Constants.Firebase.allInterests)
                    .collection(interest)
                    .document(uid)
                    .setData(["uid" : uid]) { error in
                        if let error = error {
                            self.errorService = .error(message: error.localizedDescription)
                        }else{
                            completion()
                        }
                    }
            }
        }
    }
    
    func clearAllInterests(completion: @escaping () -> Void) {
        guard let uid = self.currentSession?.uid else { return }
        guard let userInterests = self.currentUser?.interests else { return }
        var num = 0
        for interest in userInterests {
            db
                .collection(Constants.Firebase.interests)
                .document(Constants.Firebase.allInterests)
                .collection(interest)
                .document(uid)
                .delete { _ in
                    num += 1
                    if num == userInterests.count {
                        completion()
                    }
                }
        }
    }
}

//MARK: - Updating

extension UserViewModel {
    func updateLocation(coordinate: CLLocationCoordinate2D?) {
        guard let location = coordinate else {
            self.errorService = .error(message: "Location is empty")
            return
        }
        
        let hash = GFUtils.geoHash(forLocation: location)
                
        guard let id = currentUser?.id else { return }
        if let coordinate = coordinate {
            let location = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            db.collection(Constants.Firebase.usersDB)
                .document(id)
                .updateData(["location" : location, "geohash" : hash]) { error in
                    if let error = error {
                        self.errorService = .error(message: error.localizedDescription)
                    }
                }
        }
    }
}

//MARK: - Log In
extension UserViewModel {
    func login() {
        auth.signIn(withEmail: self.email, password: self.password) { auth, error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else{
                self.currentSession = auth?.user
                self.fetchUser()
            }
        }
    }
    
}

//MARK: - Register In
extension UserViewModel {
    func signIn() {
        var currentUser = User(uid: "", name: name, age: age, sex: sex, email: email, interests: interests, profileImage: profileImage, restImages: restImages, location: location, geohash: "", token: token)
        if self.isFilled(user: currentUser) {
            auth.createUser(withEmail: self.email, password: self.password) { user, error in
                if let error = error {
                    self.errorService = .error(message: error.localizedDescription)
                    self.currentSession = nil
                }else if let user = user {
                    currentUser.uid = user.user.uid
                    self.addUser(user: currentUser) { error in
                        if let error = error {
                            self.errorService = .error(message: error.localizedDescription)
                        } else {
                            self.addUserIdToProperInteres(uid: user.user.uid) {
                                self.currentSession = user.user
                                self.fetchUser()
                            }
                        }
                    }
                }else {
                    self.errorService = .error(message: Constants.unknownError)
                }
            }
        }
    }
    
    func addUser(user: User, completion: @escaping (Error?) -> Void){
        do  {
            guard let currentUser = auth.currentUser else { return }
            let _ = try db.collection(Constants.Firebase.usersDB)
                .document(currentUser.uid)
                .setData(from: user, completion: { error in
                    completion(error)
                })
        } catch let error {
            completion(error)
        }
    }
}

//MARK: - Uplaoding Images
extension UserViewModel {
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

//MARK: - Fetching
extension UserViewModel {
    func fetchUser() {
        self.isLoading = true
        guard let uid = currentSession?.uid else {
            self.isLoading = false
            return
        }
        db.collection(Constants.Firebase.usersDB)
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    self.errorService = .error(message: error.localizedDescription)
                } else if let snapshot = snapshot {
                    guard let user = try? snapshot.data(as: User.self) else { return }
                    DispatchQueue.main.async {
                        self.currentUser = user
                    }
                }
            }
        self.isLoading = false
    }
}


//MARK: - Update User Info

extension UserViewModel {
    func updateUser(_ user: User, completion: @escaping () -> Void) {
        let ref = db.collection(Constants.Firebase.usersDB).document(user.uid)
        
        do {
            try ref.setData(from: user) { error in
                if let error = error {
                    self.errorService = .error(message: error.localizedDescription)
                } else {
                    self.clearAllInterests {
                        self.addUserIdToProperInteres(uid: self.currentSession?.uid) {
                            completion()
                        }
                    }
                }
            }
        } catch let error {
            self.errorService = .error(message: error.localizedDescription)
        }
    }
}

//MARK: - Helper functions
extension UserViewModel {
    
    func signOut() {
        self.currentSession = nil
        do {
            currentUser = nil
            try auth.signOut()
        } catch let error {
            errorService = .error(message: error.localizedDescription)
        }
    }
    
    private func isFilled(user: User) -> Bool{
        var isFilledUp = false
        if user.name == "" {
            errorService = .error(message: "You have to fill up your name.")
        } else if user.age == "" {
            errorService = .error(message: "You have to fill up your age.")
        } else if user.sex == "" {
            errorService = .error(message: "You have to fill up your sex.")
        } else if user.interests.count < 3 {
            errorService = .error(message: "You have to pick at least 3 interest.")
        } else if user.profileImage == "" {
            errorService = .error(message: "You have to pick your profile image")
        } else if user.restImages.count < 1 {
            errorService = .error(message: "You have to pick at least one non-profile photo")
        } else {
            isFilledUp = true
        }
        return isFilledUp
    }
}
