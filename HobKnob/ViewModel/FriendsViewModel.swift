//
//  FriendsViewModel.swift
//  HobKnob
//
//  Created by Natanael Jop on 18/11/2022.
//

import SwiftUI
import Firebase
import FirebaseAuth
import GeoFire

class FriendsViewModel: ObservableObject {
    @Published var errorService: ErrorService = .nul
    
    @Published var allUser = [User]()
    @Published var pendingFriendsIds = [String : Bool]()
    @Published var friends: [User] = []
    @Published var queries = [Query]()
    
    static let shared = FriendsViewModel()
    
    /// 50 km
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    func fetchAllUsers(currentUser: User?, inRangeOfInKM radiusInKM: Double, similarUsersIds: [String], limit: Int, completion: @escaping () -> Void) {
    
        let radiusInM = radiusInKM * 1000
        
        guard let uid = UserViewModel.shared.currentSession?.uid else { return }
        guard let latitude = currentUser?.location.latitude else { return }
        guard let longitude = currentUser?.location.longitude else { return }
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let queryBounds = GFUtils.queryBounds(forLocation: location, withRadius: radiusInM)
        

        let tempQueries = queryBounds.map({ bound -> Query in
            return db.collection(Constants.Firebase.usersDB)
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
                .limit(to: limit)
        })
        
        for id in similarUsersIds {
            tempQueries.forEach { query in
                queries.append(
                    query
                        .whereField("uid", isEqualTo: id)
                )
            }
        }
        
        
        
        print(queries, "DEBUG")
        var matchingDocs = [QueryDocumentSnapshot]()
        var queriesFinished = 0
        var numOfDocs = 0
        
        func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
            guard let documents = snapshot?.documents else {
                print("Unable to fetch snapshot data DEBUG. \(String(describing: error))")
                return
            }
            numOfDocs = queries.count
            documents.forEach({
                let geoPoint = $0.data()["location"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
                let coordinates = CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                let centerPoint = CLLocation(latitude: location.latitude, longitude: location.longitude)
                
                let distance = GFUtils.distance(from: centerPoint, to: coordinates)
                if distance <= radiusInM {
                    if !matchingDocs.contains($0) {
                        matchingDocs.append($0)
                    }
                }
            })
            queriesFinished += 1
            allDone()
        }
        
        for query in queries {
            query
                .getDocuments(completion: getDocumentsCompletion)
        }
        
        func allDone() {
            if queriesFinished == numOfDocs {
                do {
                    let allUsers = try matchingDocs.compactMap({ try $0.data(as: User.self)})
                    self.allUser = []
                    self.allUser = allUsers.filter({$0.id != uid})
                    completion()
                } catch let error {
                    self.errorService = .error(message: error.localizedDescription)
                }
            }
        }
    }
    
    func fetchFriends() {
        self.friends = [User]()
        guard let uid = UserViewModel.shared.currentSession?.uid else { return }
        let ref = db
            .collection(Constants.Firebase.usersDB)
            .document(uid)
            .collection("friends")
        ref.getDocuments { snapshot, error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else if let snapshot = snapshot {
                do {
                    let friends = try snapshot.documents.compactMap({try $0.data(as: User.self)})
                    self.friends = friends
                } catch let error {
                    self.errorService = .error(message: error.localizedDescription)
                }
            }
        }
    }
    
    func fetchFriendWith(id: String?, completion: @escaping (Bool) -> Void) {
        guard let id = id else { completion(false); return }
        guard let uid = UserViewModel.shared.currentSession?.uid else { completion(false); return }
        let ref = db
            .collection(Constants.Firebase.usersDB)
            .document(uid)
            .collection("friends")
            .document(id)
            .getDocument { snapshot, error in
                guard let snapshot = snapshot else { return }
                if !snapshot.exists {
                    completion(false)
                }else {
                    completion(true)
                }
            }
    }
    
    func fetchPendingFriends() {
        self.pendingFriendsIds = [String : Bool]()
        guard let uid = UserViewModel.shared.currentSession?.uid else { return }
        let ref = db
            .collection(Constants.Firebase.usersDB)
            .document(uid)
            .collection("pending-friends")
        ref.getDocuments { snapshot, error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else if let snapshot = snapshot {
                snapshot.documents.forEach { doc in
                    let id = doc.documentID
                    let data = doc.data()
                    let isSent = data["sent"] as? Bool ?? false
                    self.pendingFriendsIds[id] = isSent
                }
            }
        }
    }

    func sendInvitation(to user: User) {
        guard let uid = UserViewModel.shared.currentSession?.uid else { return }
        let friendUid = user.uid
        
        let ref = db.collection(Constants.Firebase.usersDB)
        let currentUserRef = ref.document(uid).collection("pending-friends").document(friendUid)
        let friendRef = ref.document(friendUid).collection("pending-friends").document(uid)
        
        currentUserRef.setData(["sent" : true])
        friendRef.setData(["sent" : false])
    }
    

    func acceptInvitation(_ user: User) {
        guard let currentUserId = UserViewModel.shared.currentSession?.uid else { return }
        let friendId = user.uid
        
        let ref = db.collection(Constants.Firebase.usersDB)
        let currentUserRef = ref.document(currentUserId)
        let friendRef = ref.document(friendId)
        
        let currentUserPendingRef = currentUserRef.collection("pending-friends").document(friendId)
        let currentUserFriendsRef = currentUserRef.collection("friends").document(friendId)
        
        let friendPendingRef = friendRef.collection("pending-friends").document(currentUserId)
        let friendFriendsRef = friendRef.collection("friends").document(currentUserId)
        
        currentUserPendingRef.delete { error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else{
                self.fetchPendingFriends()
                do {
                    try currentUserFriendsRef.setData(from: user)
                } catch let error {
                    self.errorService = .error(message: error.localizedDescription)
                }
            }
        }
        friendPendingRef.delete { error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else{
                do {
                    guard let currentUser = UserViewModel.shared.currentUser else { return }
                    try friendFriendsRef.setData(from: currentUser)
                } catch let error {
                    self.errorService = .error(message: error.localizedDescription)
                }
            }
        }
    }
    
    func declineInvitation(_ user: User) {
        guard let currentUserId = UserViewModel.shared.currentSession?.uid else { return }
        let friendId = user.uid
        
        let ref = db.collection(Constants.Firebase.usersDB)
        let currentUserRef = ref.document(currentUserId)
        let friendRef = ref.document(friendId)
        
        let currentUserPendingRef = currentUserRef.collection("pending-friends").document(friendId)
        let friendPendingRef = friendRef.collection("pending-friends").document(currentUserId)
        
        currentUserPendingRef.delete { error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else{
                self.fetchPendingFriends()
            }
        }
        friendPendingRef.delete { error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else{
                self.fetchPendingFriends()
            }
        }
    }
    
    func deleteFriend(_ user: User) {
        guard let currentUserId = UserViewModel.shared.currentSession?.uid else { return }
        let friendId = user.uid
        
        let ref = db.collection(Constants.Firebase.usersDB)
        let currentUserRef = ref.document(currentUserId)
        let friendRef = ref.document(friendId)
        
        let currentUserPendingRef = currentUserRef.collection("friends").document(friendId)
        let friendPendingRef = friendRef.collection("friends").document(currentUserId)
        
        currentUserPendingRef.delete { error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else{
                self.fetchFriends()
            }
        }
        friendPendingRef.delete { error in
            if let error = error {
                self.errorService = .error(message: error.localizedDescription)
            }else{
                self.fetchFriends()
            }
        }
    }
    
    func checkIfUserIsWasInvited(_ user: User, exists: @escaping (FriendState) -> Void) {
        guard let currentUserId = UserViewModel.shared.currentSession?.uid else { return }
        let friendId = user.uid
        
        let ref = db.collection(Constants.Firebase.usersDB)
        let currentUserRef = ref.document(currentUserId)
        
        let currentUserPendingRef = currentUserRef.collection("pending-friends")
        let currentUserFriendsRef = currentUserRef.collection("friends")
                
        currentUserFriendsRef.document(friendId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            if snapshot.exists { exists(.alreadyFriends) } else {
                currentUserPendingRef.document(friendId).addSnapshotListener { snapshot, _ in
                    guard let snapshot = snapshot else { return }
                    if snapshot.exists {
                        let isSent = snapshot.data()?["sent"] as? Bool ?? false
                        exists(isSent ? .invited : .received)
                    }else{
                        exists(.nothing)
                    }
                }
            }
        }
        
        
    }
}

enum FriendState: CaseIterable {
    case invited
    case received
    case alreadyFriends
    case nothing
   
    @ViewBuilder func content(vm: FriendsViewModel, user: User, state: @escaping (FriendState) -> Void, scheme: ColorScheme) -> some View {
        switch self {
        case .invited:
            InvitedView(vm: vm, user: user, scheme: scheme)
        case .received:
            ReceivedView(vm: vm, user: user, state: state, scheme: scheme)
        case .alreadyFriends:
            AlreadyFriendsView(vm: vm,  user: user, state: state, scheme: scheme)
        case .nothing:
            NothingView(vm: vm,  user: user, scheme: scheme)
        }
    }
    
    private func InvitedView(vm: FriendsViewModel,  user: User, scheme: ColorScheme ) -> some View {
        Button(action: {
            vm.declineInvitation(user)
        }) {
            Text("Cancel")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.customBlue)
                .padding(10)
                .background(
                    ZStack {
                        BlurView(style: scheme == .light ? .extraLight : .dark)
                        Color.customBlue.opacity(0.2)
                    }.cornerRadius(20)
                )
        }.padding(.top)
            .padding(.horizontal, 10)
            .padding(7)
            .customButtonStyle()
    }
    private func ReceivedView(vm: FriendsViewModel,  user: User, state: @escaping (FriendState) -> Void, scheme: ColorScheme) -> some View {
        HStack {
            Button(action: {
                vm.acceptInvitation(user)
                vm.fetchFriends()
                vm.checkIfUserIsWasInvited(user, exists: {state($0)})
            }) {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(10)
                    .background(
                        ZStack {
                            BlurView(style: scheme == .light ? .extraLight : .dark)
                            Color.customBlue.opacity(0.2)
                        }.cornerRadius(20)
                    )
                    .clipShape(Circle())
            }.customButtonStyle()
            Button(action: { vm.declineInvitation(user) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(10)
                    .background(
                        ZStack {
                            BlurView(style: scheme == .light ? .extraLight : .dark)
                            Color.customBlue.opacity(0.2)
                        }.cornerRadius(20)
                    )
                    .clipShape(Circle())
            }.customButtonStyle()
        }.padding(.top)
            .padding(.horizontal, 10)
            .padding(7)
    }
    private func AlreadyFriendsView(vm: FriendsViewModel, user: User, state: @escaping (FriendState) -> Void, scheme: ColorScheme) -> some View {
        Button(action: {
            vm.deleteFriend(user)
            vm.fetchFriends()
            vm.checkIfUserIsWasInvited(user, exists: {state($0)})
        }) {
            Text("Delete Friend")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.customBlue)
                .padding(10)
                .background(
                    ZStack {
                        BlurView(style: scheme == .light ? .extraLight : .dark)
                        Color.customBlue.opacity(0.2)
                    }.cornerRadius(20)
                )
        }.padding(.top)
            .padding(.horizontal, 10)
            .padding(7)
            .customButtonStyle()
    }
    private func NothingView(vm: FriendsViewModel, user: User, scheme: ColorScheme) -> some View {
        Button(action: {
            vm.sendInvitation(to: user)
        }) {
            Text("Add Friend")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.customBlue)
                .padding(10)
                .background(
                    ZStack {
                        BlurView(style: scheme == .light ? .extraLight : .dark)
                        Color.customBlue.opacity(0.2)
                    }.cornerRadius(20)
                )
        }.padding(.top)
            .padding(.horizontal, 10)
            .padding(7)
            .customButtonStyle()
    }
}
