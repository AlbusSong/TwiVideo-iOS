//
//  TwitterVideoVC.swift
//  TwiVideo
//
//  Created by Albus on 7/28/20.
//  Copyright © 2020 Albus. All rights reserved.
//

import UIKit
import SnapKit
import WebKit
import Alamofire

class TwitterVideoVC: BaseVC, WKNavigationDelegate {
    
    var urlContent: String!
    var headers: HTTPHeaders!
    var video_id: String!
    
    var final_result: String?
    
    let txtOfHint: UILabel = UILabel()
    let activityIndView: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Close", style: .done, target: self, action: #selector(closeSelf))
        
        initSubview()
        
        startAnalyze()
    }
    
    private func startAnalyze() {
        self.headers = [
            "User-Agent": "Mozilla/5.0 (Windows NT 6.3; Win64; x64; rv:76.0) Gecko/20100101 Firefox/76.0",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
            "accept-language": "es-419,es;q=0.9,es-ES;q=0.8,en;q=0.7,en-GB;q=0.6,en-US;q=0.5"]
//        config.httpAdditionalHeaders = headers
//        let session = URLSession.shared
        self.video_id = String(self.urlContent.split(separator: "/").last ?? "")
        print("ssssss: \(self.video_id)")
        weak var weakSelf = self
        AF.request("https://twitter.com/i/videos/tweet/" + self.video_id, method: .get, headers: self.headers).response  { responseData in
            let htmlString: String = String(data: responseData.data ?? Data(), encoding: .utf8) ?? ""
            print("htmlString: \(htmlString)")
            
            let regex = try! NSRegularExpression(pattern: "src=\"(.*js)", options: .caseInsensitive)
            let res = regex.matches(in: htmlString, options: .init(rawValue: 0), range: NSRange(location: 0, length: htmlString.count))
            print("res: \(res)")
            if (res.count == 0) {
                return
            }
            let checkRes = res.first!
            let startIndex = htmlString.index(htmlString.startIndex, offsetBy: (checkRes.range.location + 5))
            let endIndex = htmlString.index(htmlString.startIndex, offsetBy: (checkRes.range.location + checkRes.range.length))
            let bearer_token_file: String = String(htmlString[startIndex..<endIndex])
            print("bearer_token_file: \(bearer_token_file)")
            
            weakSelf?.fetchBearerTokenBy(bearer_token_file: bearer_token_file)
        }
        
//        var urlReq = URLRequest(url: URL(string: "https://twitter.com/i/videos/tweet/" + "d")!)
//        urlReq.httpMethod = "GET"
//        let task = session.dataTask(with: urlReq) { (data, response, error) in
//
//        }
//        task.resume()
    }
    
    private func fetchBearerTokenBy(bearer_token_file: String) {
        weak var weakSelf = self
        AF.request(bearer_token_file, method: .get, headers: self.headers).response { responseData in
            let jsString = String(data: responseData.data ?? Data(), encoding: .utf8) ?? ""
//            print("jsString: \(jsString)")
            
            let regex = try! NSRegularExpression(pattern: "Bearer [a-zA-Z0-9%-]+", options: .caseInsensitive)
            let res = regex.matches(in: jsString, options: .init(rawValue: 0), range: NSRange(location: 0, length: jsString.count))
            print("bearer res: \(res)")
            if (res.count == 0) {
                return
            }
            let checkRes = res.first!
//            let startIndex = jsString.index(jsString.startIndex, offsetBy: checkRes.range.location)
//            let endIndex = jsString.index(jsString.startIndex, offsetBy: (checkRes.range.location + checkRes.range.length))
//            let bearer_token: String = String(jsString[startIndex..<endIndex])
            let bearer_token: String = (jsString as NSString).substring(with: checkRes.range)
            print("bearer_token: \(bearer_token)")
            weakSelf?.headers["authorization"] = bearer_token
            
            weakSelf?.tryToActivate()
        }
    }
    
    private func tryToActivate() {
        weak var weakSelf = self
        AF.request("https://api.twitter.com/1.1/guest/activate.json", method: .post, headers: self.headers).responseJSON { response in
//            print("activate.json: \(response)")
            
            switch response.result {
            case .success(let json):
                print("json: \(json)")
                weakSelf?.headers["x-guest-token"] = (json as! [String: String])["guest_token"]
                weakSelf?.fetchVideoLink()
            case .failure(let error):
                print("json error: \(error)")
                GlobalTool.showSingleAlert(title: "Error", message: error.errorDescription, actionTitle: "Retry", at:self)
            }
        }
    }
    
    private func fetchVideoLink() {
        weak var weakSelf = self
        AF.request("https://api.twitter.com/1.1/statuses/show.json?id=" + self.video_id, method: .get, headers: self.headers).responseJSON { response in
            switch response.result {
            case .success(let j):
//                print("json video info: \(j)")
                let json = j as! [String: Any]
                let extended_entities = (json["extended_entities"] as! [String: Any])["media"] as! [Any]
                print("extended_entities: \(extended_entities)")
                if (extended_entities.count == 0) {
                    GlobalTool.showSingleAlert(title: "Error", message: "Unable to extract video from this link. Please make sure there exists video under this Tweet", actionTitle: "OK", at:self)
                    return
                }
                let video_infos = ((extended_entities.first as! [String: Any])["video_info"] as! [String: Any])["variants"] as! [Any]
                print("video_infos: \(video_infos)")
                if (video_infos.count == 0) {
                    GlobalTool.showSingleAlert(title: "Error", message: "Unable to extract video from this link. Please make sure there exists video under this Tweet", actionTitle: "OK", at:self)
                    return
                }
                
                // extract the highest resolution video
                var bitrate = Int64(0)
                for v in video_infos {
//                    let selfType = String(describing:type(of: v)).self
//                    print("selfType: \(selfType)")
                    let dict = v as! [String: Any]
//                    print("dict: \(dict)")
                    if (dict["bitrate"] == nil) {
                        continue
                    }
                    let b = dict["bitrate"] as! Int64
                    if (b > bitrate) {
                        bitrate = b
                        weakSelf?.final_result = dict["url"] as? String
                    }
                }
                print("currentThread: \(Thread.current)")
                weakSelf?.handleVideoLink()
            case .failure(let error):
                print("json error: \(error)")
                GlobalTool.showSingleAlert(title: "Error", message: error.errorDescription, actionTitle: "Retry", at:self)
            }
        }
    }
    
    private func handleVideoLink() {
        self.activityIndView.stopAnimating()
        self.activityIndView.removeFromSuperview()
        self.txtOfHint.removeFromSuperview()
    }
    
    private func initSubview() {
//        let webView = WKWebView()
//        webView.frame = self.view.bounds
//        webView.navigationDelegate = self
//        self.view.addSubview(webView)
//        webView.load(URLRequest(url: URL(string: self.urlContent)!))
//        webView.evaluateJavaScript("navigator.userAgent") { (result, e) in
//            print("userAgent: \(result)")
//        }
                
        self.txtOfHint.font = UIFont.systemFont(ofSize: 15)
        self.txtOfHint.textColor = UIColor.init(hex: "666666")
        self.txtOfHint.text = "Analyzing..."
        self.view.addSubview(self.txtOfHint)
        self.txtOfHint.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.height.equalTo(21)
        }
        
        self.activityIndView.style = .gray
        self.view.addSubview(self.activityIndView)
        self.activityIndView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.txtOfHint.snp_topMargin).offset(-15)
            make.centerX.equalToSuperview()
        }
        self.activityIndView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html, e) in
            print("html: \(html!)")
        }
    }
    
    @objc private func closeSelf() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
