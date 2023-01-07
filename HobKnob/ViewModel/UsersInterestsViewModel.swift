//
//  UsersInterestsViewModel.swift
//  HobKnob
//
//  Created by Natanael Jop on 14/12/2022.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class UsersInterestsViewModel: ObservableObject {
    @Published var similarUsersIds = [String]()
    let db = Firestore.firestore()
        
    var interestsCount = 0
    var counter = 0
    
    func fetchSimilarUsersIds(interests: [String], completion: @escaping ([String]) -> Void , numOfInterestsInCommon: Int) {
        interestsCount = interests.count
        
        similarUsersIds = [String]()
        for intrest in interests {
            db
                .collection(Constants.Firebase.interests)
                .document(Constants.Firebase.allInterests)
                .collection(intrest)
                .getDocuments { snapshot, error in
                    guard let snapshot = snapshot else { return }
                    let users = snapshot.documents.compactMap({ $0.documentID })
                    self.similarUsersIds.append(contentsOf: users)
                    
                    self.counter += 1
                    self.allDone(completion: { completion($0) }, numOfInterestsInCommon: numOfInterestsInCommon)
                }
        }
    }
    
    func allDone(completion: @escaping ([String]) -> Void, numOfInterestsInCommon: Int) {
        if interestsCount == counter {
            let dic = Dictionary(grouping: self.similarUsersIds, by: {$0})
            self.similarUsersIds = dic.filter({$0.value.count >= numOfInterestsInCommon}).compactMap({$0.key})
            completion(self.similarUsersIds)
        }
    }
}
