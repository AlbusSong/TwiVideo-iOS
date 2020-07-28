//
//  TwitterVideoVC.swift
//  TwiVideo
//
//  Created by Albus on 7/28/20.
//  Copyright © 2020 Albus. All rights reserved.
//

import UIKit

class TwitterVideoVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Close", style: .done, target: self, action: #selector(closeSelf))
    }
    
    @objc private func closeSelf() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
