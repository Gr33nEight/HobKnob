//
//  WelcomeScreen.swift
//  HobKnob
//
//  Created by Natanael Jop on 16/11/2022.
//

import SwiftUI



struct WelcomeScreen: View {
    @State var showLoginPage = false
    @State var email = ""
    @State var password = ""
    @ObservedObject var locationService: LocationService
    @ObservedObject var userVM: UserViewModel
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .background(Color.reversedLabel)
                        .clipShape(Circle())
                    Spacer()
                    Spacer()
                    NavigationLink(destination: { DetailsView(userVM: userVM, locationService: locationService) }) {
                        Text("Lets Begin")
                            .font(.system(size: 23, weight: .semibold))
                            .customButtonContentStyle()
                            .padding(.horizontal)
                    }.customButtonStyle()
                    Button(action: { showLoginPage = true }) {
                        Text("Sign On")
                            .font(.system(size: 23, weight: .semibold))
                            .customButtonContentStyle()
                            .padding()
                    }.customButtonStyle()
                }
            }.sheet(isPresented: $showLoginPage, content: {
                LoginContent
            })
            .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .customBackground()
        }
    }
}


extension WelcomeScreen {
    private var LoginContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sign On")
                .font(.title)
                .bold()
            ZStack(alignment: .leading){
                if userVM.email.isEmpty {
                    Text("Email")
                        .foregroundColor(Color(.systemGray6))
                }
                TextField("", text: $userVM.email)
                    .foregroundColor(.label)
            }.padding(.leading)
            .customButtonContentStyle()
            ZStack(alignment: .leading){
                if userVM.password.isEmpty {
                    Text("Password")
                        .foregroundColor(Color(.systemGray6))
                }
                SecureField("", text: $userVM.password)
                    .foregroundColor(.label)
            }.padding(.leading)
            .customButtonContentStyle()
            Button(action: {
                showLoginPage = false
                userVM.login()
            }) {
                Text("Next")
                    .font(.system(size: 23, weight: .semibold))
                    .customButtonContentStyle()
            }.customButtonStyle()
            Spacer()
        }.padding([.top, .horizontal])
            .ignoresSafeArea()
            .background(Color(.systemGray5))
            .presentationDetents([.fraction(0.45)])
    }
}

