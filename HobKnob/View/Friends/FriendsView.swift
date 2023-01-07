//
//  FriendsView.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI
import FirebaseFirestore

enum ShowFriendsOption: String, CaseIterable {
    case All = "All"
    case Pedning = "Pedning"
}

struct FriendsView: View {
    @State var pickedFriend: User?
    @State var searchText = ""
    @State var showFriends: ShowFriendsOption = .All
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var friendsVM: FriendsViewModel
    @EnvironmentObject var navBarVM: NavigationBarViewModel
    
    var areSentRequests: [String: Bool] {
        friendsVM.pendingFriendsIds.filter({$0.value})
    }
    var areReceivedRequests: [String: Bool] {
        friendsVM.pendingFriendsIds.filter({!$0.value})
    }
    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $showFriends) {
                    ForEach(ShowFriendsOption.allCases, id:\.self){ Text($0.rawValue) }
                }.pickerStyle(.segmented)
                switch showFriends {
                case .All:
                    AllFriendsView
                        .onAppear {
                            friendsVM.fetchFriends()
                        }
                case .Pedning:
                    PendingFriendsView
                        .onAppear {
                            friendsVM.fetchPendingFriends()
                        }
                }
                Spacer()
            }.padding()
            .navigationTitle("Friends")
        }.fullScreenCover(item: $pickedFriend) { friend in
            ProfileView(user: friend)
        }
    }
}

// MARK: UI

extension FriendsView {
    private var AllFriendsView: some View {
        VStack(spacing: 0){
            CustomSearchBar(placeholder: "Search..", text: $searchText)
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(filteredFriends) { friend in
                        Button(action: { pickedFriend = friend }) {
                            FriendCell(user: friend)
                        }
                    }
                    Banner()
                }.padding(.top, 10)
            }
        }
    }
    
    private func FriendCell(user: User) -> some View {
        HStack(spacing: 15) {
            CustomAsyncImage(url: user.profileImage, size: CGSize(width: 50, height: 50))
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(user.name)
                    .foregroundColor(.customBlue)
                    .font(.system(size: 15, weight: .semibold))
            }
            Spacer()
            HStack {
                NavigationLink(destination: {
                    ConversationView(user: user)
                }, label: {
                    Image(systemName: "envelope")
                        .padding(10)
                        .background(Circle().fill(Color.reversedLabel))
                })
            }
        }.padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.customBlue.opacity(0.2)))

    }
    
    private var PendingFriendsView: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading) {
                    if !areReceivedRequests.isEmpty {
                        Text("Requests Received")
                            .foregroundColor(.label)
                            .font(.title)
                            .bold()
                    }
                    ForEach(areReceivedRequests.sorted(by: {$0.key > $1.key}), id: \.key) { id, isSent in
                        PendingFriendCellView(friend: PendingFriendViewModel(id), isSent: false)
                    }
                }.padding(.top, 10)
                LazyVStack(alignment: .leading) {
                    if !areSentRequests.isEmpty {
                        Text("Requests Sent")
                            .foregroundColor(.label)
                            .font(.title)
                            .bold()
                    }
                    ForEach(areSentRequests.sorted(by: {$0.key > $1.key}), id: \.key) { id, isSent in
                        PendingFriendCellView(friend: PendingFriendViewModel(id), isSent: true)
                    }
                }.padding(.top, 10)

            }
        }
    }
}

class PendingFriendViewModel: ObservableObject {
    @Published var friend: User?
    var uid: String?

    init(_ uid: String?) {
        self.uid = uid
        fetchPendingFriend()
    }
    
    var name: String {
        friend?.name ?? ""
    }
    
    var image: String {
        friend?.profileImage ?? ""
    }
    
    func fetchPendingFriend() {
        guard let uid = uid else { return }
        Firestore.firestore().collection(Constants.Firebase.usersDB)
            .document(uid)
            .getDocument { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard let user = try? snapshot.data(as: User.self) else { return }
                self.friend = user
        }
    }
}

struct PendingFriendCellView: View {
    @ObservedObject var friend: PendingFriendViewModel
    @EnvironmentObject var friendsVM: FriendsViewModel
    let isSent: Bool
    var body: some View {
        HStack(spacing: 15) {
            CustomAsyncImage(url: friend.image, size: CGSize(width: 50, height: 50))
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(friend.name)
                    .foregroundColor(.customBlue)
                    .font(.system(size: 15, weight: .semibold))
            }
            Spacer()
            if let user = friend.friend {
                HStack {
                    if !isSent {
                        Button(action: { friendsVM.acceptInvitation(user) }) {
                            Image(systemName: "checkmark")
                                .padding(13)
                                .background(Circle().fill(Color.reversedLabel))
                        }.customButtonStyle()
                    }
                }
                Button(action: { friendsVM.declineInvitation(user) }) {
                    Image(systemName: "xmark")
                        .padding(13)
                        .background(Circle().fill(Color.reversedLabel))
                }.customButtonStyle()
            }
        }.padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.customBlue.opacity(0.2)))
            .onChange(of: friendsVM.pendingFriendsIds) { _ in
                friend.fetchPendingFriend()
            }
    }
}


// MARK: Functions


extension FriendsView {
    private var filteredFriends: [User] {
        let returnTestArray = friendsVM.friends.filter {
            ($0.name.lowercased().contains(searchText.lowercased()) ||
             $0.email.lowercased().contains(searchText.lowercased()))
            || searchText == ""}
        guard !returnTestArray.isEmpty else { return friendsVM.friends }
        return returnTestArray
    }
}


//struct FriendsView_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
