//
//  GuideVC.swift
//  TwiVideo
//
//  Created by Albus on 7/27/20.
//  Copyright © 2020 Albus. All rights reserved.
//

import UIKit

class GuideVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Close", style: .done, target: self, action: #selector(closeSelf))
    }
    
    @objc private func closeSelf() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
