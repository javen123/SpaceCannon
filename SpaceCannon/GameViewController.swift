//
//  GameViewController.swift
//  SpaceCannon
//
//  Created by Jim Aven on 2/13/15.
//  Copyright (c) 2015 Jim Aven. All rights reserved.
//

import UIKit
import SpriteKit
import iAd


class GameViewController: UIViewController, ADInterstitialAdDelegate{
    
    var interAd:ADInterstitialAd!
    var interAdView:UIView!
    var closeButton = UIButton(type: UIButtonType.system)
    
    
    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
           // Configure the view.
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = true
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Present the scene.
        skView.presentScene(scene)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showAds), name: NSNotification.Name(rawValue: notificationKey), object: nil)
        
    }
    
    
    // MARK: IAd funcs
    
    func close (_ sender:UIButton) {
        closeButton.removeFromSuperview()
        interAdView.removeFromSuperview()
    }
    
    func showAds () {
        
        interAd = ADInterstitialAd()
        interAd.delegate = self
        print("iad loading")
    }
    
    func interstitialAdWillLoad(_ interstitialAd: ADInterstitialAd!) {
        
    }
    func interstitialAdDidLoad(_ interstitialAd: ADInterstitialAd!) {
        
        
        closeButton.frame = CGRect(x: 20, y: 20, width: 20, height: 20)
        closeButton.layer.cornerRadius = 10
        closeButton.setTitle("X", for: UIControlState())
        closeButton.setTitleColor(UIColor.black, for: UIControlState())
        closeButton.backgroundColor = UIColor.white
        closeButton.layer.borderColor = UIColor.black.cgColor
        closeButton.layer.borderWidth = 1
        closeButton.addTarget(self, action: #selector(GameViewController.close(_:)), for: UIControlEvents.touchDown)
        
        interAdView = UIView()
        interAdView.frame = self.view.bounds
        self.view.addSubview(interAdView)
        
        interAd.present(in: interAdView)
        interAdView.addSubview(closeButton)
        print("iAd did load")
        
    }
    
    func interstitialAdDidUnload(_ interstitialAd: ADInterstitialAd!) {
        
        print("iad did unload")
        interAd = nil
        
    }
    
    func interstitialAd(_ interstitialAd: ADInterstitialAd!, didFailWithError error: Error!) {
        
        print("Failed to receive: \(error.localizedDescription)")
        audioPlayer.play()
        self.closeButton.removeFromSuperview()
        self.interAdView.removeFromSuperview()
        
    }
    
}




