//
//  MessageView.swift
//  HobKnob
//
//  Created by Natanael Jop on 05/12/2022.
//

import SwiftUI

struct MessageView: View {
    let messVM: MessVM
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if messVM.isFromCurrentUser { Spacer() } else {
                CustomAsyncImage(url: messVM.profileImageUrl, size: CGSize(width: 20, height: 20))
                    .clipShape(Circle())
            }
            Text(messVM.message.text)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(12)
                .background {
                    Rectangle()
                        .fill(messVM.isFromCurrentUser ? Color.customBlue : Color(.systemGray4))
                        .customCornerRadius(20, corners: messVM.isFromCurrentUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                }
                .frame(maxWidth: UIScreen.main.bounds.width/1.3, alignment: messVM.isFromCurrentUser ? .trailing : .leading)
                .padding(.bottom, messVM.isFromCurrentUser ? 0 : 10)
                .padding(.horizontal, messVM.isFromCurrentUser ? 10 : 0)
            if !messVM.isFromCurrentUser { Spacer() }
        }
    }
}


