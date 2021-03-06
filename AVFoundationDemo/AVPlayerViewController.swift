//
//  AVPlayerViewController.swift
//  AVFoundationDemo
//
//  Created by Mjwon on 2017/10/16.
//  Copyright © 2017年 Nemo. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerViewController: UIViewController {

    var player:AVPlayer?
    var currentPlayerLayer:AVPlayerLayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        self.videoPlayBGView.backgroundColor = UIColor.lightGray

        guard let url = URL.init(string: "https://dev-us-east-1-cubi-platform-storage.s3.amazonaws.com/us-east-1/public/5A9m3q1K3Nxd/us-east-1%3A85e5f5d0-82ac-4bb0-83d9-443e95661a83/4rpkGlGNzRoZ/LIVE/master.m3u8") else {
            assertionFailure("url is not valid！")
            return
        }
        let playerItem = AVPlayerItem.init(url: url)
        player = AVPlayer.init(playerItem:playerItem)
        currentPlayerLayer = AVPlayerLayer.init(player: player)
        currentPlayerLayer?.frame = XCGRect(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*0.6)
        currentPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        
        player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (time) in
            debugPrint("---addObserver---\(time)")
            
        })
        
        //监听播放器的状态
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        //监听播放器的缓冲进度
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        
        //监听播放器的播放缓冲区是否为空
        playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        /**
        for layer in videoPlayBGView.subviews {
            layer.layer.removeFromSuperlayer()
        }
        self.videoPlayBGView.layer.addSublayer(currentPlayerLayer!)
        */
        
        self.videoPlayBGView.layer.insertSublayer(currentPlayerLayer!, at: 0)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let playerItem = object as? AVPlayerItem
        
        debugPrint("---observeValue---\(String(describing: playerItem?.status))")
        
        debugPrint("---keyPath---\(String(describing: keyPath)))")
        
        if keyPath == "status" {
            let status:AVPlayerItem.Status = (playerItem?.status)!
            
            switch status {
            case .readyToPlay:
                debugPrint("======== 准备播放")
                
                self.player?.play()
                
            case .failed:
                debugPrint("======== 播放失败")
                
            case .unknown:
                debugPrint("======== 播放unknown")
                
            }
        }else if keyPath == "loadedTimeRanges"{
            let duration = playerItem?.duration
            let totalDuration = CMTimeGetSeconds(duration!)
            
            debugPrint("============== 缓冲进度 - \(totalDuration)")

            
        }else if keyPath == "playbackBufferEmpty"{
            
            
            debugPrint("======== playbackBufferEmpty")
        }else{
            debugPrint("======== playbackFail")
        }
        
        
    }
    
    lazy var videoPlayBGView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.width*0.6))
        
        self.view.addSubview(view)
        
        return view
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        currentPlayerLayer?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        currentPlayerLayer?.removeObserver(self, forKeyPath: "status")
        currentPlayerLayer?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
