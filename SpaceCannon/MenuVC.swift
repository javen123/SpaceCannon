//
//  MenuVC.swift
//  SpaceCannon
//
//  Created by Jim Aven on 2/18/15.
//  Copyright (c) 2015 Jim Aven. All rights reserved.
//

import UIKit
import SpriteKit

class MenuVC:SKNode {
    
    
    let titleMenu = SKSpriteNode(imageNamed: "Title")
    let scoreBoardMenu = SKSpriteNode(imageNamed: "ScoreBoard")
    let playButtonMenu = SKSpriteNode(imageNamed: "PlayButton")
    var scoreLabelMenu = SKLabelNode(fontNamed: "DIN Alternate")
    var topScoreLabelMenu = SKLabelNode(fontNamed: "DIN Alternate")
    var scoreMenu = 0
    var topScoreMenu = userDefaults.integer(forKey: keyTopScore)
    
    override init() {
        
        super.init()
       
        titleMenu.position = CGPoint(x: 0, y: 140)
        self.addChild(titleMenu)
        scoreBoardMenu.position = CGPoint(x: 0, y: 70)
        self.addChild(scoreBoardMenu)
        playButtonMenu.position = CGPoint(x: 0, y: 0)
        playButtonMenu.name = "Play"
        self.addChild(playButtonMenu)
        
        scoreLabelMenu.fontSize = 30
        scoreLabelMenu.position = CGPoint(x: -52, y: 50)
        scoreLabelMenu.text = "\(scoreMenu)"
        self.addChild(scoreLabelMenu)
        
        topScoreLabelMenu.fontSize = 30
        topScoreLabelMenu.position = CGPoint(x: 48, y: 50)
        topScoreLabelMenu.text = "\(topScoreMenu)"
        self.addChild(topScoreLabelMenu)
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMenuScore (_ score:Int) {
        self.scoreLabelMenu.text = "\(score)"
        
    }
    
    func setMenuTopScore (_ score:Int) {
        
        if score > topScoreMenu {
            
            self.topScoreLabelMenu.text = "\(score)"
            
            userDefaults.set(score, forKey: keyTopScore)
            userDefaults.synchronize()
        }
        
        
    }
}
