//
//  HomeView.swift
//  HobKnob
//
//  Created by Natanael Jop on 16/11/2022.
//

import SwiftUI
import MapKit
import FirebaseFirestore


struct HomeView: View {
    @ObservedObject var usersInterestsVM = UsersInterestsViewModel()
    @ObservedObject var locationService: LocationService
    @EnvironmentObject var friendsVM: FriendsViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    
    var region: Binding<MKCoordinateRegion>? {
        guard let location = locationService.location else {
            return MKCoordinateRegion.goldenGateRegion().getBinding()
        }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        
        return region.getBinding()
    }
    
    @State var pickedUser: User?
    @State var friendsWithRandomLocationInRadius = [User]()
    
    private func filter() {
        friendsWithRandomLocationInRadius = []
        friendsWithRandomLocationInRadius = friendsVM.allUser.compactMap({ User(uid: $0.uid, name: $0.name, age: $0.age, sex: $0.sex, email: $0.email, interests: $0.interests, profileImage: $0.profileImage, restImages: $0.restImages, location: GeoPoint(latitude: locationService.generateRandomCoordinates(min: 100, max: UInt32(userVM.range*1000)).latitude, longitude: locationService.generateRandomCoordinates(min: 100, max: UInt32(userVM.range*1000)).longitude), geohash: $0.geohash, token: $0.token) })
    }
    
    var body: some View {
        if let region = region {
            Map(coordinateRegion: region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $userTrackingMode, annotationItems: friendsWithRandomLocationInRadius, annotationContent: { friend in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: friend.location.latitude, longitude: friend.location.longitude)) {
                    Button(action: { pickedUser = friend }) {
                        CustomAnnotationMark(imageURL: friend.profileImage)
                    }
                }
          }).overlay(
            Button(action: {
                if userTrackingMode == .follow {
                    userTrackingMode = .none
                }else{
                    userTrackingMode = .follow
                }
            }, label: {
                Image(systemName: "paperplane.circle.fill")
                    .foregroundColor(.customBlue)
                    .font(.largeTitle)
            }).padding(.top,50)
                .padding()
                .customButtonStyle()
            , alignment: .topTrailing
          )
                .ignoresSafeArea()
                .navigationBarBackButtonHidden(true)
                .fullScreenCover(item: $pickedUser) { user in
                    ProfileView(user: user)
                }
                .onAppear {
                    locationService.setUpTimer { coordinates in
                        userVM.updateLocation(coordinate: coordinates)
                    }
                }
                .onAppear {
                    guard let interests = userVM.currentUser?.interests else { print("doesn't work"); return }
                    print(interests, "DEBUG")
                    usersInterestsVM.fetchSimilarUsersIds(interests: interests, completion: { ids in
                        if !ids.isEmpty {
                            print(ids, "DEBUG")
                            friendsVM.fetchAllUsers(currentUser: userVM.currentUser, inRangeOfInKM: userVM.range, similarUsersIds: ids, limit: SubTypeViewModel(purchaseManager: purchaseManager).limit) {
                                filter()
                            }
                        }
                    }, numOfInterestsInCommon: userVM.numOfInterestsInCommon)
                }
        }
    }
}


extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}
