//
//  IntersitialAd.swift
//  HobKnob
//
//  Created by Natanael Jop on 21/12/2022.
//

import SwiftUI
import GoogleMobileAds
import UIKit


final class Interstitial: NSObject, GADFullScreenContentDelegate, ObservableObject {
    private var interstitial: GADInterstitialAd?
    
    override init() {
        super.init()
        loadInterstitial()
    }
    
    func loadInterstitial(){
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3665295435747370/3337921302",
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
        }
        )
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.", error.localizedDescription)
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        self.loadInterstitial()
    }
    
    func showAd(){
        let root = UIApplication.shared.windows.first?.rootViewController
        interstitial?.present(fromRootViewController: root!)
    }
}
