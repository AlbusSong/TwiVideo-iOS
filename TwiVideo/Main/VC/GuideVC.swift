//
//  GuideVC.swift
//  TwiVideo
//
//  Created by Albus on 7/27/20.
//  Copyright © 2020 Albus. All rights reserved.
//

import UIKit

class GuideVC: BaseVC {
    
    let scv: UIScrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Close", style: .done, target: self, action: #selector(closeSelf))
        
        self.initSubviews()
    }
    
    private func initSubviews() {
        self.scv.frame = self.view.bounds
        self.view.addSubview(self.scv)
        self.scv.backgroundColor = .white
        
        let txt1 = UILabel()
        txt1.backgroundColor = .white
        txt1.font = UIFont.systemFont(ofSize: 23)
        txt1.textColor = .init(hex: "333333")
        txt1.text = "1."
        self.scv.addSubview(txt1)
        txt1.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
        }
        
        let imgv1 = UIImageView()
        imgv1.clipsToBounds = true
        imgv1.contentMode = .scaleAspectFit
        imgv1.image = UIImage(named: "Guide_1.jpg")
        self.scv.addSubview(imgv1)
        imgv1.snp.makeConstraints { (make) in
            make.top.equalTo(txt1.snp_bottomMargin).offset(20)
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
            make.height.equalTo((SCREEN_WIDTH - 20 * 2) * (imgv1.image!.size.height / imgv1.image!.size.width))
        }
        
        let txt2 = UILabel()
        txt2.backgroundColor = .white
        txt2.font = UIFont.systemFont(ofSize: 23)
        txt2.textColor = .init(hex: "333333")
        txt2.text = "2."
        self.scv.addSubview(txt2)
        txt2.snp.makeConstraints { (make) in
            make.top.equalTo(imgv1.snp_bottomMargin).offset(30)
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
        }
        
        let imgv2 = UIImageView()
        imgv2.clipsToBounds = true
        imgv2.contentMode = .scaleAspectFit
        imgv2.image = UIImage(named: "Guide_2.jpg")
        self.scv.addSubview(imgv2)
        imgv2.snp.makeConstraints { (make) in
            make.top.equalTo(txt2.snp_bottomMargin).offset(20)
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
            make.height.equalTo((SCREEN_WIDTH - 20 * 2) * (imgv2.image!.size.height / imgv2.image!.size.width))
        }
        
        self.scv.layoutIfNeeded()
        
        self.scv.contentSize = CGSize(width: self.view.bounds.size.width, height: NAVIGATIONBAR_HEIGHT + imgv2.frame.origin.y + imgv2.frame.size.height + 20 + XBOTTOM_HEIGHT)
    }
    
    @objc private func closeSelf() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
