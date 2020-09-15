//
//  AdMobTool.swift
//  TwiVideo
//
//  Created by Albus on 9/15/20.
//  Copyright © 2020 Albus. All rights reserved.
//

import Foundation
import GoogleMobileAds

class AdMobTool: NSObject, GADInterstitialDelegate {
    static let `default` = AdMobTool()
    
    var interstitial: GADInterstitial!
    var videoSavedTimes: Int!
    
    private override init() {
        super.init()
        interstitial = self.createAndLoadInterstitial()
        
        videoSavedTimes = UserDefaults.standard.integer(forKey: "videoSavedTimes")
        
        print("videoSavedTimes: \(videoSavedTimes)")
    }
    
    private func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: ADMOB_UNIT_ID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = self.createAndLoadInterstitial()
    }
    
    public func storeVideoSavedTimes() {
        UserDefaults.standard.set(videoSavedTimes, forKey: "videoSavedTimes")
        UserDefaults.standard.synchronize()
    }
}
