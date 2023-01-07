//
//  SubTypeViewModel.swift
//  HobKnob
//
//  Created by Natanael Jop on 21/12/2022.
//

import SwiftUI

struct SubTypeViewModel {
    @ObservedObject var purchaseManager: PurchaseManager
    
    var limit: Int {
        if purchaseManager.hasFree {
            return 5
        }else if purchaseManager.hasSilver {
            return 10
        }else if purchaseManager.hasGold {
            return 100
        }else{
            return 100
        }
    }
    
    var preSelectedMessages: [String]? {
        if purchaseManager.hasFree {
            return ["Hello", "Do you want to meet?"]
        }else if purchaseManager.hasSilver {
            return ["Hello", "Do you want to meet?"]
        }else if purchaseManager.hasGold {
            return nil
        }else{
            return nil
        }
    }
    
    @ViewBuilder var banner: some View {
        if !purchaseManager.hasGold {
            BannerAd()
                .frame(width: UIScreen.main.bounds.width - 45, height: 50)
        }
    }
}
