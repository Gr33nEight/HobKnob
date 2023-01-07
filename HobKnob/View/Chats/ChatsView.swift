//
//  ChatsView.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI

struct ChatsView: View {
    @State var searchText = ""
    @State var showSearchButton = false
    @ObservedObject var conversationsVM = ConversationsViewModel()
    @EnvironmentObject var navBarVM: NavigationBarViewModel
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar
                if conversationsVM.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .padding(.bottom, 120)
                        Spacer()
                    }
                }else if conversationsVM.recentMessages.isEmpty {
                    VStack{
                        Spacer()
                        Text("You don't have any converstation.")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.customBlue)
                            .padding(.bottom, 90)
                            .padding(.horizontal, 30)
                        Spacer()
                    }
                }else{
                    MainContent
                }
            }.padding()
                .navigationTitle("Chats")
                .edgesIgnoringSafeArea(.bottom)
        }.onAppear {
            conversationsVM.fetchRecentMessages()
        }
    }
}

// MARK: UI

extension ChatsView {
    private var SearchBar: some View {
        HStack {
            CustomSearchBar(placeholder: "Search...", text: $searchText)
            ZStack {
                if showSearchButton {
                    Button(action: { searchText = "" }) {
                        Text("Clear")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.customBlue))
                    }.transition(.offset(x: 110))
                }
            }
        }.onChange(of: searchText.count) { newValue in
            withAnimation(.spring()){
                if newValue > 0 {
                    showSearchButton = true
                }else{
                    showSearchButton = false
                }
            }
        }
    }

    private var MainContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(conversationsVM.recentMessages) { mess in
                    ConversationCell(messVM: ConversationCellViewModel(mess))
                }
                Banner()
            }.padding(5)
                .padding(.top, 5)
        }
    }
}

// MARK: Functions

extension ChatsView {
    private var filteredMessages: [Message] {
        let returnTestArray = conversationsVM.recentMessages.filter {
            ($0.user!.name.lowercased().contains(searchText.lowercased()) ||
             $0.user!.email.lowercased().contains(searchText.lowercased()))
            || searchText == ""}
        guard !returnTestArray.isEmpty else { return conversationsVM.recentMessages }
        return returnTestArray
    }
}

