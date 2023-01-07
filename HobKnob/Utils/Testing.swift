//
//  TestingSendingNotifications.swift
//  HobKnob
//
//  Created by Natanael Jop on 20/12/2022.
//

import SwiftUI
import Foundation
import StoreKit


//struct TestingSendingNotifications: View {
//    @State var deviceToken = ""
//    var body: some View {
//        Button(action: { sendNotification() }) {
//            Text("Send Notification")
//        }.buttonStyle(.borderedProminent)
//    }
//    func sendNotification() {
//        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else { return }
//
//        let json: [String : Any] = [
//            "to": deviceToken,
//            "notification": [
//                "title": "test",
//                "body": "test"
//            ],
//            "data": [
//                "user_name": "Natanel"
//            ]
//        ]
//        let servKey = "AAAAPIJ2O8o:APA91bF7nApkwdMqtd2Jwn18X6zZPSl-bvhakl9Ebwb0othqyRzgZvOZ58PLFF_eVGG9Yb7QN_gAxkQhYmLRikwewSIE0xoDlHjm19TB_uGmNQnbbYVMdlRxkRMYPi1TC8iVL2J9T8vi"
//        var request = URLRequest(url: url)
//
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("key=\(servKey)", forHTTPHeaderField: "Authorization")
//
//        let session = URLSession(configuration: .default)
//
//        session.dataTask(with: request) { _, _, err in
//            if let err = err {
//                print(err.localizedDescription)
//                return
//            }
//
//            print("suscess")
//            DispatchQueue.main.async { [self] in
//                // clear all variables
//            }
//        }.resume()
//    }
//}
//
//struct TestingSendingNotifications_Previews: PreviewProvider {
//    static var previews: some View {
//        TestingSendingNotifications()
//    }
//}
