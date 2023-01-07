//
//  ConversationView.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI

struct ConversationView: View {
    @EnvironmentObject var friendsVM: FriendsViewModel
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var navBarVM: NavigationBarViewModel
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    private let user: User
    @ObservedObject var messageVM: MessageViewModel
    
    @State var isMyFriend = false
    
    init(user: User) {
        self.user = user
        self.messageVM = MessageViewModel(user: user)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar
            MainContent
            BottomPart
        }.onAppear {
            navBarVM.showBar = false
            friendsVM.fetchFriendWith(id: user.id, completion: { isMyFriend = $0 })
        }
        .onDisappear {
            navBarVM.showBar = true
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .errorAlert(errorService: $purchaseManager.errorService)
    }
}

//MARK: UI

extension ConversationView {
    private var TopBar: some View {
        HStack(spacing: 12) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
            }
            CustomAsyncImage(url: user.profileImage, size: CGSize(width: 35, height: 35))
                .clipShape(Circle())
            Text(user.name)
                .foregroundColor(.label)
                .font(.system(size: 16, weight: .semibold))
            Spacer()
        }.padding()
            .background(Color(.systemGray6))
    }
    
    private var MainContent: some View {
        ZStack {
            Color.customBlue.opacity(0.2)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 5){
                    if !messageVM.messages.isEmpty {
                        ForEach(messageVM.messages){ message in
                            MessageView(messVM: MessVM(message))
                        }
                    } else {
                        Text("Say hi to \(user.name), be polite and try not to abuse chat. Remeber you can be banned for imposing.")
//                        Text("Remeber as long as \(user.name) isn't your friend you will be able to send only one message, so consider what excatcly do you want to send to \(user.name).")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .font(.system(size: 13, weight: .light))
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                   
                }
                .padding(.vertical)
                .padding(.horizontal, 5)
                .rotationEffect(.degrees(180))
            }.rotationEffect(.degrees(180))
            
        }
    }

    private var BottomPart: some View {
        ZStack {
            if !isMyFriend {
                if let messages = SubTypeViewModel(purchaseManager: purchaseManager).preSelectedMessages {
                    VStack {
                        TagView(alignment: .center, spacing: 10){
                            ForEach(messages) { mess in
                                Button(action: {
                                    withAnimation {
                                        messageVM.sendMessage(mess)
                                        self.sendNotification(message: mess)
                                    }
                                }) {
                                    Text(mess)
                                        .foregroundColor(Color.label)
                                        .padding(.horizontal, 12)
                                        .font(.system(size: 14, weight: .semibold))
                                        .padding(.vertical, 10)
                                        .background(
                                            ZStack {
                                                Color.customBlue.opacity(0.2)
                                                RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 4).fill(Color.customBlue)
                                            }.opacity(1)
                                        )
                                        .cornerRadius(20)
                                }.customButtonStyle()
                            }
                        }.padding(.bottom, CGFloat(messages.count/2) * 35.0)
                            .padding(.vertical)
                    }.padding(10)
                        .clipped()
                        .fixedSize(horizontal: false, vertical: true)
                }else{
                    HStack{
                        TextField("Message", text: $messageText, axis: .vertical)
                            .padding(.horizontal, 8)
                            .padding(8)
                            .cornerRadius(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.reversedLabel)
                                    .frame(minHeight: 50)
                            )
                            .padding(3)
                        Button {
                            if isMyFriend {
                                sendMessage()
                            }else if messageVM.messages.count == 0 {
                                sendMessage()
                            }else{
                                purchaseManager.errorService = .error(message: "You can send only one message!")
                            }
                        } label: {
                            Image(systemName: "paperplane")
                        }.foregroundColor(.customBlue)
                            .font(.system(size: 20, weight: .bold))
                    }.padding(.horizontal, 8)
                        .padding([.top, .trailing], 8)
                        .padding(.vertical)
                        .background(Color(.systemGray6))
                }
            }else{
                HStack{
                    TextField("Message", text: $messageText, axis: .vertical)
                        .padding(.horizontal, 8)
                        .padding(8)
                        .cornerRadius(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.reversedLabel)
                                .frame(minHeight: 50)
                        )
                        .padding(3)
                    Button {
                        if isMyFriend {
                            sendMessage()
                        }else if messageVM.messages.count == 0 {
                            sendMessage()
                        }else{
                            purchaseManager.errorService = .error(message: "You can send only one message!")
                        }
                    } label: {
                        Image(systemName: "paperplane")
                    }.foregroundColor(.customBlue)
                        .font(.system(size: 20, weight: .bold))
                }.padding(.horizontal, 8)
                    .padding([.top, .trailing], 8)
                    .padding(.vertical)
                    .background(Color(.systemGray6))
            }
        }
    }
}

//MARK: Functions

extension ConversationView {
    private func sendMessage() {
        if !messageText.isEmpty {
            withAnimation {
                messageVM.sendMessage(messageText)
                self.sendNotification(message: messageText)
                messageText = ""
            }
        }
    }

    private func sendNotification(message: String) {
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else { return }
        
        let json: [String : Any] = [
            "to": user.token,
            "notification": [
                "title": "\(user.name)",
                "body": "\(message)"
            ],
            "data": [
                "user_name": "\(user.name)"
            ]
        ]
        let servKey = "AAAAPIJ2O8o:APA91bF7nApkwdMqtd2Jwn18X6zZPSl-bvhakl9Ebwb0othqyRzgZvOZ58PLFF_eVGG9Yb7QN_gAxkQhYmLRikwewSIE0xoDlHjm19TB_uGmNQnbbYVMdlRxkRMYPi1TC8iVL2J9T8vi"
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(servKey)", forHTTPHeaderField: "Authorization")
            
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) { _, _, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            print("suscess")
        }.resume()
    }
}

//struct TempPreview: PreviewProvider {
//    static var previews: some View {
//        ConversationView(user: Constants().placeholderUser).environmentObject(PurchaseManager()).environmentObject(NavigationBarViewModel())
//    }
//}
