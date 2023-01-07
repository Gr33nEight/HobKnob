//
//  SignUpView.swift
//  HobKnob
//
//  Created by Natanael Jop on 16/11/2022.
//

import SwiftUI
import Firebase

struct DetailsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var locationService: LocationService
    
    var body: some View {
        CustomAuthView(title: "Lets Get Started!", destination: {
            AddPictureView(userVM: userVM)
        }) {
            VStack(spacing: 20) {
                ZStack(alignment: .leading){
                    if userVM.name.isEmpty {
                        Text("Name")
                            .foregroundColor(Color(.systemGray5))
                    }
                    TextField("", text: $userVM.name)
                        .foregroundColor(.label)
                }.padding(.leading)
                    .customButtonContentStyle()
                ZStack(alignment: .leading){
                    if userVM.age.isEmpty {
                        Text("Age")
                            .foregroundColor(Color(.systemGray5))
                    }
                    TextField("", text: $userVM.age)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.label)
                }.padding(.leading)
                    .customButtonContentStyle()
                HStack{
                    ZStack(alignment: .leading){
                        if userVM.sex.isEmpty {
                            Text("Sex")
                                .foregroundColor(Color(.systemGray5))
                                .padding(.leading, 10)
                        }
                        Picker("", selection: $userVM.sex) {
                            ForEach(Constants.sexes, id:\.self) { Text($0)}
                        }.labelsHidden()
                            .accentColor(userVM.sex.isEmpty ? Color.clear : Color.label)
                    }.padding(.leading, 5)
                    Spacer()
                }.customButtonContentStyle()
                ZStack(alignment: .leading){
                    if userVM.email.isEmpty {
                        Text("Email")
                            .foregroundColor(Color(.systemGray5))
                    }
                    TextField("", text: $userVM.email)
                        .foregroundColor(.label)
                }.padding(.leading)
                .customButtonContentStyle()
                ZStack(alignment: .leading){
                    if userVM.password.isEmpty {
                        Text("Password")
                            .foregroundColor(Color(.systemGray5))
                    }
                    SecureField("", text: $userVM.password)
                        .foregroundColor(.label)
                }.padding(.leading)
                .customButtonContentStyle()
            }.padding()

        }.onAppear {
            DispatchQueue.main.async {
                let location = GeoPoint(latitude: self.locationService.location?.coordinate.latitude ?? 0.0, longitude: self.locationService.location?.coordinate.longitude ?? 0.0)
                self.userVM.location = location
            }
        }
    }
}
