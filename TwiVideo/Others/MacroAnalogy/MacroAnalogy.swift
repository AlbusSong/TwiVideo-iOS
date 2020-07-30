//
//  MacroAnalogy.swift
//  TwiVideo
//
//  Created by Albus on 7/30/20.
//  Copyright © 2020 Albus. All rights reserved.
//

import Foundation
import UIKit

func IS_DARK_MODE() -> Bool {
    if #available(iOS 12.0, *) {
        return (UIApplication.shared.keyWindow?.rootViewController?.traitCollection.userInterfaceStyle == .dark)
    } else {
        // Fallback on earlier versions
        return false
    }
}
