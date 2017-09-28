//
//  CCBall.swift
//  SpaceCannon
//
//  Created by Jim Aven on 2/19/15.
//  Copyright (c) 2015 Jim Aven. All rights reserved.
//

import UIKit
import SpriteKit

class CCBall:SKSpriteNode {
    
    var trail:SKEmitterNode!
    var bounces = 0
    
    
    func updateTrail () {
        
        if self.trail != nil {
            
            self.trail.position = self.position
        }
        
        
    }
    
    override func removeFromParent() {
        
        if self.trail != nil {
            
            self.trail.particleBirthRate = 0.0
            let effectDuration = Double(self.trail.particleLifetime + self.trail.particleLifetimeRange)
            
            let removeTrail = SKAction.sequence([SKAction.wait(forDuration: effectDuration), SKAction.removeFromParent()])
                self.run(removeTrail)
        }
        
        super.removeFromParent()
    }
    
    
    
    
    
    
    
}
