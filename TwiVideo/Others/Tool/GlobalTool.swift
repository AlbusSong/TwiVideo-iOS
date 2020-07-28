//
//  GlobalTool.swift
//  TwiVideo
//
//  Created by Albus on 7/28/20.
//  Copyright © 2020 Albus. All rights reserved.
//

import UIKit

class GlobalTool: NSObject {
    
    
    static func showSingleAlert(title: String?, message: String?, actionTitle: String) {
        self.showSingleAlert(title: title, message: message, actionTitle: actionTitle, at: UIApplication.shared.keyWindow!.rootViewController!)
    }
    
    static func showSingleAlert(title: String?, message: String?, actionTitle: String, at vc: UIViewController) {
        let alertCtler = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alertCtler.addAction(okAction)
        vc.present(alertCtler, animated: true, completion: nil)
    }
}
