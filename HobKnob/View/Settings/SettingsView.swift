//
//  SettingsView.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("darkMode") private var darkMode = false
    @EnvironmentObject var userVM: UserViewModel
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Dark Mode", isOn: $darkMode)
                    .tint(Color.customBlue)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                    .foregroundColor(.customBlue)
                HStack {
                    Text("Number of interests in common:")
                    Spacer(minLength: 0)
                    Picker("", selection: $userVM.numOfInterestsInCommon) {
                        ForEach(1...9, id:\.self) { Text("\($0)") }
                    }.labelsHidden()
                }
                .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                VStack {
                    HStack {
                        Text("Range:")
                        Text("\(userVM.range, specifier: "%.0f") km")
                    }
                    Slider(value: $userVM.range, in: 0...200, step: 20).labelsHidden()
                }.padding(20)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                Button {
                    userVM.signOut()
                } label: {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .tint(Color.customBlue)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                }
                Spacer()
            }.navigationTitle("Settings")
                .padding(.horizontal)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(UserViewModel())
    }
}
