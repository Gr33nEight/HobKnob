//
//  InterestsView.swift
//  HobKnob
//
//  Created by Natanael Jop on 16/11/2022.
//

import SwiftUI

enum ErrorService {
    case error(message: String)
    case nul
    
    var message: String {
        switch self {
        case .error(let message):
            return message
        case .nul:
            return ""
        }
    }
}

struct InterestsView: View {
    @AppStorage("isFirstTime") private var isFirstTime = true
    @Environment(\.colorScheme) var scheme
    @ObservedObject var userVM: UserViewModel
    var body: some View {
        CustomAuthView(title: "Interests or likes", destination: {} , content: {
            VStack {
                TagView(alignment: .center, spacing: 10){
                    ForEach(Constants.interests) { tag in
                        // MARK: New Toggle API
                        Button(action: {
                            if userVM.interests.contains(tag.name) {
                                userVM.interests = userVM.interests.filter({$0 != tag.name})
                            }else{
                                userVM.interests.append(tag.name)
                            }
                        }) {
                            Label(tag.name, systemImage: tag.image)
                                .foregroundColor(userVM.interests.contains(tag.name) ? Color.customBlue : Color(.black).opacity(0.6))
                                .padding(.horizontal)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.vertical, 10)
                                .background(
                                    ZStack {
                                        BlurView(style: scheme == .light ? .extraLight : .dark)
                                        RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 4).fill(userVM.interests.contains(tag.name) ? Color.reversedLabel : .clear)
                                    }.opacity(userVM.interests.contains(tag.name) ? 1 : 0.5)
                                )
                                .cornerRadius(20)
                        }.customButtonStyle()
                    }
                }.padding(.top, 50)
            }.padding(10)
        }, action: {
            userVM.signIn()
        }).errorAlert(errorService: $userVM.errorService)
    }
}
