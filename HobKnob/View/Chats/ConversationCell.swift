//
//  ConversationCell.swift
//  HobKnob
//
//  Created by Natanael Jop on 05/12/2022.
//

import SwiftUI

struct ConversationCell: View {
    @ObservedObject var messVM: ConversationCellViewModel
    var body: some View {
        if let user = messVM.message.user {
            NavigationLink {
                ConversationView(user: user)
            } label: {
                HStack(spacing: 15) {
                    CustomAsyncImage(url: messVM.message.user?.profileImage ?? "", size: CGSize(width: 50, height: 50))
                        .clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text(messVM.message.user?.name ?? "")
                            .foregroundColor(.customBlue)
                            .font(.system(size: 15, weight: .semibold))
                        Text(messVM.message.text)
                            .lineLimit(1)
                            .font(.system(size: 13))
                            .foregroundColor(Color(.systemGray))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        
                        if returnFullDate(messVM.message.date) {
                            Text(messVM.message.date.formatted(date: .numeric, time: .omitted))
                        }
                        Text(messVM.message.date.formatted(date: .omitted, time: .shortened))
                        
                    }.font(.system(size: 8))
                        .padding(5)
                        .padding(.horizontal, 5)
                        .foregroundColor(.label)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray5)))
                }.padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.customBlue.opacity(0.2)))
            }.isDetailLink(false)

        }
    }
    private func returnFullDate(_ date: Date) -> Bool {
        if date.formatted(date: .numeric, time: .omitted) == Date().formatted(date: .numeric, time: .omitted) {
            return false
        } else {
            return true
        }
    }
}
