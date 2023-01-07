//
//  Main.swift
//  HobKnob
//
//  Created by Natanael Jop on 16/11/2022.
//

import SwiftUI

struct MainView: View {
    @StateObject var locationService = LocationService()
    @StateObject var userVM = UserViewModel()
    var body: some View {
        if !userVM.isLoggedIn {
            WelcomeScreen(locationService: locationService, userVM: userVM)
                .errorAlert(errorService: $userVM.errorService)
        }else{
            NavigationBar(locationService: locationService)
                .environmentObject(userVM)
                .environmentObject(locationService)
        }
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
