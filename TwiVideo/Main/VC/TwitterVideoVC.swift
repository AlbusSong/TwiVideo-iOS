//
//  TwitterVideoVC.swift
//  TwiVideo
//
//  Created by Albus on 7/28/20.
//  Copyright © 2020 Albus. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import AVKit
import Photos

class TwitterVideoVC: BaseVC {
    
    var urlContent: String!
    var userAgent: String!
    
    var headers: HTTPHeaders!
    var videoId: String!
    
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
            "User-Agent": self.userAgent,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
            "accept-language": "es-419,es;q=0.9,es-ES;q=0.8,en;q=0.7,en-GB;q=0.6,en-US;q=0.5"]
//        config.httpAdditionalHeaders = headers
//        let session = URLSession.shared
        self.videoId = String(self.urlContent.split(separator: "/").last ?? "")
        print("ssssss: \(self.videoId!)")
        weak var weakSelf = self
        AF.request("https://twitter.com/i/videos/tweet/" + self.videoId, method: .get, headers: self.headers).response  { responseData in
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
        AF.request("https://api.twitter.com/1.1/statuses/show.json?id=" + self.videoId, method: .get, headers: self.headers).responseJSON { response in
            switch response.result {
            case .success(let j):
                print("json video info: \(j)")
                let json = j as! [String: Any]
                guard let extended_entities = json["extended_entities"] as? [String: Any] else {
                    // if no 'extended_entities', we can try to fetch the video link throuth another api
                    weakSelf?.fetchVideoLink2()
                    return
                }
                guard let media = extended_entities["media"] as? [Any] else {
                    GlobalTool.showSingleAlert(title: "Error", message: "Unable to extract video from this link. Please make sure there exists video under this Tweet", actionTitle: "OK", at:self)
                    weakSelf?.hideHintUI()
                    return
                }
                print("media: \(media)")
                if (media.count == 0) {
                    GlobalTool.showSingleAlert(title: "Error", message: "Unable to extract video from this link. Please make sure there exists video under this Tweet", actionTitle: "OK", at:self)
                    weakSelf?.hideHintUI()
                    return
                }
                let video_infos = ((media.first as! [String: Any])["video_info"] as! [String: Any])["variants"] as! [Any]
                print("video_infos: \(video_infos)")
                if (video_infos.count == 0) {
                    GlobalTool.showSingleAlert(title: "Error", message: "Unable to extract video from this link. Please make sure there exists video under this Tweet", actionTitle: "OK", at:self)
                    weakSelf?.hideHintUI()
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
                if (self.final_result?.count == 0) {
                    GlobalTool.showSingleAlert(title: "Error", message: "Unable to extract video from this link. Please make sure there exists video under this Tweet", actionTitle: "OK", at:self)
                    weakSelf?.hideHintUI()
                    return
                }
                weakSelf?.handleVideoLink()
            case .failure(let error):
                print("json error: \(error)")
                GlobalTool.showSingleAlert(title: "Error", message: error.errorDescription, actionTitle: "Retry", at:self)
                weakSelf?.hideHintUI()
            }
        }
    }
    
    private func fetchVideoLink2() {
        var pureVideoId = self.videoId
        if (self.videoId.contains("?")) {
            pureVideoId = String(self.videoId.split(separator: "?").first ?? "")
        }
//        print("pureVideoId: \(pureVideoId!)")
        
        weak var weakSelf = self
        AF.request("https://api.twitter.com/1.1/videos/tweet/config/" + pureVideoId! + ".json", method: .get, headers: self.headers).responseJSON { response in
            switch response.result {
            case .success(let j):
                print("fetchVideoLink2: \(j)")
                let json = j as! [String: Any]
                guard let track = json["track"] as? [String:Any] else {
                    GlobalTool.showSingleAlert(title: "Error", message: "Unable to extract video from this link. Please make sure there exists video under this Tweet", actionTitle: "OK", at:self)
                    weakSelf?.hideHintUI()
                    return
                }
                
                guard (track["playbackUrl"] as? String) != nil else {
                    GlobalTool.showSingleAlert(title: "Error", message: "Unable to extract video from this link. Please make sure there exists video under this Tweet", actionTitle: "OK", at:self)
                    weakSelf?.hideHintUI()
                    return
                }
                
                let playbackUrl = track["playbackUrl"] as! String
                print("playbackUrl: \(playbackUrl)")
                weakSelf?.final_result = playbackUrl
                weakSelf?.handleM3u8VideoLink()
                
            case .failure(let error):
                print("json error: \(error)")
                GlobalTool.showSingleAlert(title: "Error", message: error.errorDescription, actionTitle: "Retry", at:self)
                weakSelf?.hideHintUI()
            }
        }
    }
    
    private func hideHintUI() {
        self.activityIndView.stopAnimating()
        self.activityIndView.removeFromSuperview()
        self.txtOfHint.removeFromSuperview()
    }
    
    private func handleM3u8VideoLink() {
        self.hideHintUI()
        
        let activityIndView2 = UIActivityIndicatorView(style: .gray)
        if (IS_DARK_MODE()) {
            activityIndView2.style = .white
        }
        activityIndView2.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: activityIndView2)
                
        self.startToPlayVideo()
        self.startToDownloadM3u8VideoDirectlyUsingFFMpeg()
    }
    
    private func handleVideoLink() {
        self.hideHintUI()
        
        let activityIndView2 = UIActivityIndicatorView(style: .gray)
        if (IS_DARK_MODE()) {
            activityIndView2.style = .white
        }
        activityIndView2.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: activityIndView2)
                
        self.startToPlayVideo()
        self.startToDownloadVideo()
    }
    
    private func startToDownloadM3u8VideoDirectlyUsingFFMpeg() {
        weak var weakSelf = self
        DispatchQueue.global().async {
            VideoHandlingTool.downloadM3u8Video(self.final_result!) { resultCode in
                print("downloadM3u8VideoresultCode: \(resultCode)")
                DispatchQueue.main.async {
                    if (resultCode == 0) {
                        // Success
                        weakSelf?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .done, target: weakSelf, action: #selector(weakSelf?.tryToSaveVideo))
                    } else {
                        GlobalTool.showSingleAlert(title: "Error", message: "Unable to extract video from this link. Please make sure there exists video under this Tweet", actionTitle: "OK", at:self)
                        weakSelf?.hideHintUI()
                    }
                }
            }
        }
    }
    
    private func startToDownloadVideo() {
        let destination: DownloadRequest.Destination = { temporaryURL, response in
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

            let url = directoryURL.appendingPathComponent("TwitterVideo.mp4") 

            return (url, [.removePreviousFile])
        }
        
        weak var weakSelf = self
        AF.download(self.final_result!, headers: self.headers, to: destination).downloadProgress { progress in
            print("progress: \(progress.fractionCompleted)")
        }.response { response in
            print("download response: \(response)")
                        
            weakSelf?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .done, target: weakSelf, action: #selector(weakSelf?.tryToSaveVideo))
        }
    }
    
    private func startToPlayVideo() {
        let player = AVPlayer(url: URL(string: self.final_result!)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.frame = self.view.bounds
        playerViewController.view.backgroundColor = UIColor.black
        self.addChild(playerViewController)
        self.view.addSubview(playerViewController.view)
    }
    
    private func initSubview() {
                
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
    
    @objc private func tryToSaveVideo() {
        PHPhotoLibrary.shared().performChanges({
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

            let videoUrl = directoryURL.appendingPathComponent("TwitterVideo.mp4")
            
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
        }) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    GlobalTool.showSingleAlert(title: "Success", message: "Saved to Photos", actionTitle: "OK", at:self)
                } else {
                    GlobalTool.showSingleAlert(title: "Error", message: "Failed to save to Photos. Please try again", actionTitle: "OK", at:self)
                }
            }
        }

    }
    
    @objc private func closeSelf() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Deprecated methods for handling m3u8 video link
    private func startToDownloadM3u8Video() {
        weak var weakSelf = self
        AF.request(self.final_result!, method: .get, headers: self.headers).response { response in
            let m3u8Content = String(data: response.data ?? Data(), encoding: .utf8)
            print("startToDownloadM3u8Video response:\n\(m3u8Content!)")
            let m3u8ContentOptions = m3u8Content?.split(separator: "\n")
            print("m3u8ContentOptions: \(m3u8ContentOptions!)")
            let m3u8VideoHost = (response.request?.url?.scheme ?? "") + "://" + (response.request?.url?.host ?? "")
            print("m3u8VideoHost: \(m3u8VideoHost)")

            weakSelf?.fetchM3u8VideoSlicesInfo(m3u8VideoHost: m3u8VideoHost, extention: String((m3u8ContentOptions?.last)!))
        }
    }
    
    private func fetchM3u8VideoSlicesInfo(m3u8VideoHost: String!, extention: String!) {
        weak var weakSelf = self
        AF.request(m3u8VideoHost + extention, method: .get, headers: self.headers).response { response in
            let m3u8Content = String(data: response.data ?? Data(), encoding: .utf8)
            print("fetchM3u8VideoSlicesInfo:\n\(m3u8Content!)")
            let m3u8ContentOptions = m3u8Content?.split(separator: "\n")
            print("fetchM3u8VideoSlicesInfo Options: \(m3u8ContentOptions!)")
            var videoSlices: [String] = []
            for i in 0..<m3u8ContentOptions!.count {
                let item = String(m3u8ContentOptions![i])
                if (item.hasPrefix("#EXTINF:") && m3u8ContentOptions!.count > (i + 1)) {
                    videoSlices.append(String(m3u8ContentOptions![i+1]))
                }
            }
            print("videoSlices: \(videoSlices)")
            
            weakSelf?.downloadVideoSlices(m3u8VideoHost, videoSlices)
        }
    }
    
    private func downloadVideoSlices(_ m3u8VideoHost: String!, _ videoSlices: [String]!) {

        let queue = DispatchQueue(label: "Concurrent queue", attributes: .concurrent)
        let group = DispatchGroup()
        
        let documentDirUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentDirUrl.appendingPathComponent("m3u8")
        print("directoryURL: \(directoryURL)")
        try? FileManager.default.removeItem(at: directoryURL)
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        
        for i in 0..<videoSlices!.count {
            queue.async {
                group.enter()
                
                let sliceString = videoSlices[i]
                let wholeSliceUrl = m3u8VideoHost + sliceString
                            
                let destination: DownloadRequest.Destination = { temporaryURL, response in
                    let url = directoryURL.appendingPathComponent(String(format: "%d.ts", i))
                    return (url, [.removePreviousFile])
                }
                            
                AF.download(wholeSliceUrl, headers: self.headers, to: destination).downloadProgress { progress in
                    print("progress: \(progress.fractionCompleted)")
                }.response { response in
                    print("download response: \(response)")
                    print("idiididid: \(i)")
                    group.leave()
                }
            }
        }
        
        group.notify(queue: queue) {
            print("finish all slices downloading")
            self.combineAllVideoSlices()
        }
    }
    
    private func combineAllVideoSlices() {
        VideoHandlingTool.combineVideoSlices()
    }
}
