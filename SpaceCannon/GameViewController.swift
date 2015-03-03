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
    var closeButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
    
    
    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
           // Configure the view.
        let skView = view as SKView
        skView.multipleTouchEnabled = true
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Present the scene.
        skView.presentScene(scene)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAds", name: notificationKey, object: nil)
        
    }
    
    
    // MARK: IAd funcs
    
    func close (sender:UIButton) {
        closeButton.removeFromSuperview()
        interAdView.removeFromSuperview()
    }
    
    func showAds () {
        
        interAd = ADInterstitialAd()
        interAd.delegate = self
        println("iad loading")
    }
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
        
    }
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        
        
        closeButton.frame = CGRectMake(20, 20, 20, 20)
        closeButton.layer.cornerRadius = 10
        closeButton.setTitle("X", forState: .Normal)
        closeButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        closeButton.backgroundColor = UIColor.whiteColor()
        closeButton.layer.borderColor = UIColor.blackColor().CGColor
        closeButton.layer.borderWidth = 1
        closeButton.addTarget(self, action: "close:", forControlEvents: UIControlEvents.TouchDown)
        
        interAdView = UIView()
        interAdView.frame = self.view.bounds
        self.view.addSubview(interAdView)
        
        interAd.presentInView(interAdView)
        interAdView.addSubview(closeButton)
        println("iAd did load")
        
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        
        println("iad did unload")
        interAd = nil
        
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        
        println("Failed to receive: \(error.localizedDescription)")
        audioPlayer.play()
        self.closeButton.removeFromSuperview()
        self.interAdView.removeFromSuperview()
        
    }
    
}




