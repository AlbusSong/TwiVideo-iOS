//
//  ColorExtra.swift
//  TwiVideo
//
//  Created by Albus on 7/27/20.
//  Copyright © 2020 Albus. All rights reserved.
//

import Foundation

import UIKit

extension UIColor {
    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    convenience init(hex: String, alpha: CGFloat) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue:UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        var a:CGFloat = 1.0
        if (alpha >= 0.0 && alpha <= 1.0) {
            a = alpha
        }
        self.init(red:CGFloat(r) / 0xff, green:CGFloat(g) / 0xff, blue:CGFloat(b) / 0xff, alpha:CGFloat(a))
    }
}
