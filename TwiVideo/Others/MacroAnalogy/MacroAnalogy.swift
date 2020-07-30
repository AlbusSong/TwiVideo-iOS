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


// MARK: - UI

func get_is_iphonex() -> Bool {
    var result = false
    if #available(iOS 11.0, *) {
        guard let b = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else {
            return false
        }
        
        result = (b > 0)
    }
    return result
}

func get_navigationbar_height() -> CGFloat {
    return (IS_IPHONEX ? 88.0 : 64.0)
}

func get_tabbar_height() -> CGFloat {
    return (IS_IPHONEX ? 83.0 : 49.0)
}

func get_xbottom_height() -> CGFloat {
    return (IS_IPHONEX ? 34.0 : 0.0)
}

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let STATUSBAR_HEIGHT = UIApplication.shared.statusBarFrame.height
let IS_IPHONEX = get_is_iphonex()
let NAVIGATIONBAR_HEIGHT = get_navigationbar_height()
let TABBAR_HEIGHT = (IS_IPHONEX ? 83.0 : 49.0)
let XBOTTOM_HEIGHT = get_xbottom_height()
