//
//  BaseNavController.swift
//  TwiVideo
//
//  Created by Albus on 7/27/20.
//  Copyright © 2020 Albus. All rights reserved.
//

import UIKit

class BaseNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationBar.tintColor = UIColor.init(hex: "4ba0eb")
        
        self.view.backgroundColor = .white
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
