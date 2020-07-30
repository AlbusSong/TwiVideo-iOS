//
//  MainVC.swift
//  TwiVideo
//
//  Created by Albus on 7/27/20.
//  Copyright © 2020 Albus. All rights reserved.
//

import UIKit
import SnapKit
import WebKit

class MainVC: BaseVC, UITextViewDelegate {
    
    var content : String = ""
    
    let txvOfContent = UITextView()
    
    var webViewForUserAgent: WKWebView?
    var userAgent: String! = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(backgroundViewClicked)))
        
        self.initSubviews()
        
        self.getUserAgent()
    }
    
    private func getUserAgent() {
        self.webViewForUserAgent = WKWebView()
        self.webViewForUserAgent?.evaluateJavaScript("navigator.userAgent") { (result, error) in
            if let unwrappedUserAgent = result as? String {
                print("userAgent: \(unwrappedUserAgent)")
                self.userAgent = unwrappedUserAgent
            } else {
                print("Failed to get userAgent")
            }
        }
    }
    
    func initSubviews() {
        let imgvOfLogo = UIImageView()
        imgvOfLogo.clipsToBounds = true
        imgvOfLogo.contentMode = .scaleAspectFit
        imgvOfLogo.layer.cornerRadius = 5
        imgvOfLogo.image = UIImage(named: "Main-Logo")
        self.view.addSubview(imgvOfLogo)
        let topMarginOfImgvLogo = IS_IPHONEX ? 120 : 80
        imgvOfLogo.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(topMarginOfImgvLogo)
            make.width.height.equalTo(30)
        }
        
        let txtOfTitle = UILabel()
        txtOfTitle.font = .systemFont(ofSize: 22)
        txtOfTitle.textColor = .black
        txtOfTitle.textAlignment = .center
        txtOfTitle.text = "Download Video On Twitter"
        self.view.addSubview(txtOfTitle)
        txtOfTitle.snp.makeConstraints { make in
            make.top.equalTo(imgvOfLogo.snp_bottomMargin).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        
        let txtOfSubTitle = UILabel()
        txtOfSubTitle.font = .systemFont(ofSize: 15)
        txtOfSubTitle.textColor = .lightGray
        txtOfSubTitle.textAlignment = .center
        txtOfSubTitle.text = "Copy the tweet link and paste it below"
        self.view.addSubview(txtOfSubTitle)
        txtOfSubTitle.snp.makeConstraints { (make) in
            make.top.equalTo(txtOfTitle.snp_bottomMargin).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        let txtOfGuide = UILabel()
        txtOfGuide.font = .systemFont(ofSize: 15)
        txtOfGuide.textColor = UIColor.init(hex: "4ba0eb")
        txtOfGuide.textAlignment = .center
        txtOfGuide.isUserInteractionEnabled = true
        txtOfGuide.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.txtOfGuideClicked)))
        self.view.addSubview(txtOfGuide)
        txtOfGuide.snp.makeConstraints { (make) in
            make.top.equalTo(txtOfSubTitle.snp_bottomMargin).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(21)
        }
        txtOfGuide.attributedText = NSAttributedString(string: "Guide", attributes: [NSAttributedString.Key.underlineStyle : 1])
        
        
        self.txvOfContent.backgroundColor = UIColor.init(white: 0.95, alpha: 1.0)
        self.txvOfContent.font = .systemFont(ofSize: 15)
        self.txvOfContent.layer.borderColor = UIColor.init(white: 0.8, alpha: 1.0).cgColor
        self.txvOfContent.layer.borderWidth = 1
        self.txvOfContent.clipsToBounds = true
        self.txvOfContent.layer.cornerRadius = 3
        self.txvOfContent.delegate = self
        self.txvOfContent.textColor = UIColor.init(white: 0.1, alpha: 1.0)
        self.view.addSubview(self.txvOfContent)
        self.txvOfContent.snp.makeConstraints { (make) in
            make.top.equalTo(txtOfGuide.snp_bottomMargin).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(150)
        }
        
        let btnClear = UIButton.init(type: .system)
        btnClear.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btnClear.tintColor = UIColor.init(hex: "4ba0eb")
        btnClear.setTitle("Clear", for: .normal)
        btnClear.addTarget(self, action: #selector(btnClearClicked), for: .touchUpInside)
        self.view.addSubview(btnClear)
        btnClear.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.txvOfContent.snp_bottomMargin).offset(3)
            make.right.equalToSuperview().offset(-22)
            make.height.equalTo(21)
            make.width.equalTo(50)
        }
        
        let btnAnalyze = UIButton(type: .system)
        btnAnalyze.tintColor = UIColor.init(hex: "4ba0eb")
        btnAnalyze.clipsToBounds = true
        btnAnalyze.layer.cornerRadius = 5
        btnAnalyze.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btnAnalyze.setTitle("Start Analysis", for: .normal)
        btnAnalyze.backgroundColor = .init(white: 0.9, alpha: 1.0)
        btnAnalyze.addTarget(self, action: #selector(tryToAnalyze), for: .touchUpInside)
        self.view.addSubview(btnAnalyze)
        btnAnalyze.snp.makeConstraints { (make) in
            make.top.equalTo(self.txvOfContent.snp_bottomMargin).offset(50)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("textView: \(textView.text!)")
        
        self.content = textView.text
    }
    
    @objc private func txtOfGuideClicked() {
        let gVC = GuideVC()
        let nav = BaseNavController(rootViewController: gVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc private func backgroundViewClicked() {
        self.view.endEditing(true)
    }
    
    @objc private func btnClearClicked() {
        self.content = ""
        self.txvOfContent.text = ""
    }
    
    @objc private func tryToAnalyze() {
        print("tryToAnalyze")
        
//        VideoHandlingTool.combineVideoSlices()
//        return
        
//        https://twitter.com/henglixiaoge/status/1287816567187595265?s=21
//        self.content = "https://twitter.com/Varneyco/status/1288480987337363457?s=20"
        
        if (self.content.count == 0) {
            GlobalTool.showSingleAlert(title: "No Content Input", message: "Please input a Twitter link", actionTitle: "Okay", at: self)
            return
        }
        
        if ((self.content.hasPrefix("https://twitter.com/") || self.content.hasPrefix("http://twitter.com/")) == false) {
            GlobalTool.showSingleAlert(title: "Invalid Twitter Link", message: "Please input a valid Twitter link", actionTitle: "Okay", at: self)
            return
        }
        
        // https://twitter.com/GuoXiaoTian2018/status/1288120414628020226?s=20
        let twitterVideoVC = TwitterVideoVC()
        twitterVideoVC.urlContent = self.content
        twitterVideoVC.userAgent = self.userAgent
        let nav = BaseNavController(rootViewController: twitterVideoVC)
        self.present(nav, animated: true, completion: nil)
    }                
}
