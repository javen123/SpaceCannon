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
    var topScoreMenu = userDefaults.integerForKey(keyTopScore)
    
    override init() {
        
        super.init()
       
        titleMenu.position = CGPointMake(0, 140)
        self.addChild(titleMenu)
        scoreBoardMenu.position = CGPointMake(0, 70)
        self.addChild(scoreBoardMenu)
        playButtonMenu.position = CGPointMake(0, 0)
        playButtonMenu.name = "Play"
        self.addChild(playButtonMenu)
        
        scoreLabelMenu.fontSize = 30
        scoreLabelMenu.position = CGPointMake(-52, 50)
        scoreLabelMenu.text = "\(scoreMenu)"
        self.addChild(scoreLabelMenu)
        
        topScoreLabelMenu.fontSize = 30
        topScoreLabelMenu.position = CGPointMake(48, 50)
        topScoreLabelMenu.text = "\(topScoreMenu)"
        self.addChild(topScoreLabelMenu)
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMenuScore (score:Int) {
        self.scoreLabelMenu.text = "\(score)"
        
    }
    
    func setMenuTopScore (score:Int) {
        
        if score > topScoreMenu {
            
            self.topScoreLabelMenu.text = "\(score)"
            
            userDefaults.setInteger(score, forKey: keyTopScore)
            userDefaults.synchronize()
        }
        
        
    }
}
