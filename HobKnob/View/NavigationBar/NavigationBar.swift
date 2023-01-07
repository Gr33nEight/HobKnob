//
//  NavigationBar.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI

enum NavigationOption: CaseIterable {
    case home
    case friends
    case chats
    case settings
    case profile
    
    var icon: String {
        switch self {
        case .home :
            return "house.fill"
        case .friends:
            return "person.3.fill"
        case .chats:
            return "bubble.left.fill"
        case .settings:
            return "gear"
        case .profile:
            return "person.fill"
        }
    }
    
    @ViewBuilder func NavView(locationService: LocationService, user: User) -> some View {
        switch self {
        case .home :
            
            HomeView(locationService: locationService)
        case .friends:
            FriendsView()
        case .chats:
            ChatsView()
        case .settings:
            SettingsView()
        case .profile:
            ProfileView(user: user) //user: UserViewModel.shared.currentUser
        }
    }
}


struct NavigationBar: View {
    @StateObject var delegator = NavigationBarViewModel()
    @StateObject var friendsVM = FriendsViewModel()
    @State private var localPickedView: NavigationOption = .home
    @ObservedObject var locationService: LocationService
    @EnvironmentObject var userVM: UserViewModel
    @Namespace var anim
    var body: some View {
        ZStack(alignment: .bottom) {
            if let user = userVM.currentUser {
                delegator.pickedView.NavView(locationService: locationService, user: user)
                    .errorAlert(errorService: $userVM.errorService)
                    .errorAlert(errorService: $friendsVM.errorService)
                if delegator.showBar { NavBar}
            }else{
                ZStack {
                    Button(action: { userVM.signOut() }) {
                        Text("Log out")
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .loadingOverlay(show: .constant(true))
            }
        }
        .environmentObject(delegator)
            .environmentObject(locationService)
            .environmentObject(friendsVM)
    }
    private var NavBar: some View {
        HStack {
            ForEach(NavigationOption.allCases, id:\.self) { opt in
                ZStack {
                    Image(systemName: opt.icon)
                        .foregroundColor(opt == localPickedView ? Color.customBlue : Color(.systemGray2))
                }.frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .cornerRadius(15)
                    .background(
                        ZStack {
                            if opt == localPickedView {
                                Color.customBlue.opacity(0.2)
                                    .cornerRadius(15)
                                    .matchedGeometryEffect(id: "anim", in: anim)
                            }
                        }
                    )
                    .onTapGesture {
                        delegator.pickedView = opt
                    }
                
            }
        }.onChange(of: delegator.pickedView, perform: { newValue in
            withAnimation(.spring()) {
                localPickedView = newValue
            }
        })
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray6)).shadow(radius: 5, y: 3))
        .padding()
    }
}

//structć NavigationBar_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationBar(delegator: NavigationDelegator())
//    }
//}
