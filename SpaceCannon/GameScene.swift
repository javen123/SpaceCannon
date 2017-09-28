//
//  GameScene.swift
//  SpaceCannon
//
//  Created by Jim Aven on 2/13/15.
//  Copyright (c) 2015 Jim Aven. All rights reserved.
//

import SpriteKit
import Foundation
import AVFoundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



let userDefaults = UserDefaults.standard
let keyTopScore = "TopScore"
let notificationKey = "iAdKey"


class GameScene: SKScene, SKPhysicsContactDelegate {
    
   
    // MARK: Constants
    
    let cannon = SKSpriteNode(imageNamed: "Cannon")
    let mainLayer = SKNode()
    let shootSpeed:CGFloat = 1000
    let kHaloLowAngle:CGFloat = 200.0 * CGFloat(M_PI) / 180.0
    let kHaloHighAngle:CGFloat = 340.0 * CGFloat(M_PI) / 180.0
    let kHaloSpeed:CGFloat = 100.0
    let kHaloCategory:UInt32            = 0x1 << 0
    let kBallCategory:UInt32            = 0x1 << 1
    let kEdgeCategory:UInt32            = 0x1 << 2
    let kShieldCategory:UInt32          = 0x1 << 3
    let kLifeBarCategory:UInt32         = 0x1 << 4
    let kShieldUpCategory:UInt32        = 0x1 << 5
    let kMultiShotBallCategory:UInt32   = 0x1 << 6
    
    let lifeBar = SKSpriteNode(imageNamed: "BlueBar")
    let pointLabel = SKLabelNode(fontNamed: "DIN Alternate")
    let scoreLabel = SKLabelNode(fontNamed: "DIN Alternate")
    let ammoDisplay = SKSpriteNode(imageNamed: "Ammo5")
    
    let laserBlastSound = SKAction.playSoundFileNamed("laserBlast.caf", waitForCompletion: false)
    let lifebarBlastSound = SKAction.playSoundFileNamed("lifeBarBlast.caf", waitForCompletion: false)
    let haloBlastSound = SKAction.playSoundFileNamed("haloBlast.caf", waitForCompletion: false)
    let bounceSound = SKAction.playSoundFileNamed("bounce.caf", waitForCompletion: false)
    let shieldUpSound = SKAction.playSoundFileNamed("shieldReplace.caf", waitForCompletion: false)
    let haloExplosion = SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false)
    let pauseBtn = SKSpriteNode(imageNamed: "PauseButton")
    let resumeBtn = SKSpriteNode(imageNamed: "ResumeButton")
    
    let menu = MenuVC()
    
    var pointValue = 1
    var didShoot:Bool?
    var ammo = 0
    var score = 0
    var isGameOver = false
    var haloCount = 0
    var shieldPool = [SKSpriteNode]()
    var killCount = 0
    var multiMode = false
    var gamePaused = false
    var gameCount = 0
    
    
   override func didMove(to view: SKView) {
    
        self.size = view.bounds.size

        // turn off gravity
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
            
        //add background
        
        let background = SKSpriteNode(imageNamed: "StarField")
        background.position = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        background.size = CGSize(width: self.size.width, height: self.size.height)
        background.blendMode = SKBlendMode.replace
        addChild(background)
        
        
        // add layer
        
        addChild(mainLayer)

        // add edges

        let leftEdge = SKNode()
        leftEdge.physicsBody = SKPhysicsBody(edgeFrom:CGPoint.zero, to: CGPoint(x: 0.0, y: self.size.height + 100))
        leftEdge.position = CGPoint.zero
        leftEdge.physicsBody?.categoryBitMask = kEdgeCategory
        addChild(leftEdge)

        let rightEdge = SKNode()
        rightEdge.physicsBody = SKPhysicsBody(edgeFrom:CGPoint.zero, to: CGPoint(x: 0.0, y: self.size.height + 100))
        rightEdge.position = CGPoint(x: self.size.width, y: 0.0)
        rightEdge.physicsBody?.categoryBitMask = kEdgeCategory
        addChild(rightEdge)


        // add cannon
        
        cannon.position = CGPoint(x: self.size.width/2, y: 0.0)
        self.addChild(cannon)
        
        // Cannon rotation action
        
        let rotateCannon = SKAction.sequence([
                           SKAction.rotate(byAngle: 3.14, duration: 2),
                           SKAction.rotate(byAngle: -3.14, duration: 2)])

        cannon.run(SKAction.repeatForever(rotateCannon))

        // Create Spawn Halo's

        let haloSpawn = SKAction.sequence([
                        SKAction.wait(forDuration: 2, withRange: 1),
                        SKAction.run(spawnHalo)])

        self.run(SKAction.repeatForever(haloSpawn), withKey:"SpawnHaloSequence")
    
        let spawnShieldDisplay = SKAction.sequence([SKAction.wait(forDuration: 15, withRange: 4),
                                                    SKAction.run(spawnShieldPowerUp)])
        self.run(SKAction.repeatForever(spawnShieldDisplay))
    
        if isGameOver == false {
            let multiBallPower = SKAction.sequence([SKAction.wait(forDuration: 4),
                                     SKAction.run(spawnMultiShotPowerUp)])
        
            self.run(SKAction.repeatForever(multiBallPower))
        }
        
    
    
        // Setup Ammo display
    
        ammoDisplay.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        ammoDisplay.position = cannon.position
        self.addChild(ammoDisplay)
    
    // set up shield display
    
    for i in 0 ..< 6 {
        let shield = SKSpriteNode(imageNamed: "Block")
        shield.name = "Shield"
        shield.position = CGPoint(x: 35 + (50 * i), y: 90)
        shield.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 42, height: 9))
        shield.physicsBody?.categoryBitMask = kShieldCategory
        shield.physicsBody?.collisionBitMask = 0
    }
        

        let incrementAmmo = SKAction.sequence([SKAction.wait(forDuration: 1.5),
                                               SKAction.run({
                                                
                                                if self.multiMode == false {
                                                    self.ammo = self.ammo + 1
                                                }})])

        self.run(SKAction.repeatForever(incrementAmmo))
        
        // set up score display
    
        pauseBtn.position = CGPoint(x: self.size.width - 30, y: 20)
        self.addChild(pauseBtn)
        pauseBtn.isHidden = true
    
    
        resumeBtn.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        self.addChild(resumeBtn)
        resumeBtn.isHidden = true
    
        scoreLabel.position = CGPoint(x: 15, y: 10)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.fontSize = 15
        self.addChild(scoreLabel)
        scoreLabel.isHidden = true
    
        pointLabel.position = CGPoint(x: 15, y: 30)
        pointLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        pointLabel.fontSize = 15
        self.addChild(pointLabel)
        pointLabel.isHidden = true
        
        // set up menu
    
        menu.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(menu)
        isGameOver = true
        
    
        // load top score
    
        menu.topScoreMenu = userDefaults.integer(forKey: keyTopScore)
    
    
    }
    // MARK: helper funcs
    
    func adjustScore (_ aScore:Int) {
        
        scoreLabel.text = "Score: \(aScore)"
        
    }
    
    func adjustPointValue (_ aScore:Int) {
        pointValue = aScore
        pointLabel.text = "Points: x\(aScore)"
    }
    
    func setAmmo () {
        
        if ammo >= 0 && ammo <= 5 {
            let ammoTextureName = "Ammo\(ammo)"
            ammoDisplay.texture = SKTexture(imageNamed: ammoTextureName)
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody:SKPhysicsBody!
        var secondBody:SKPhysicsBody!
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == kHaloCategory && secondBody.categoryBitMask == kBallCategory {
            
            score += self.pointValue
            if let firstPosition = firstBody.node?.position {
                
                addExplosion(firstPosition, fileName: "HaloExplosion")
                self.run(haloBlastSound)
                killCount = killCount + 1
                
                if let _:Bool = firstBody.node?.userData?.value(forKey: "Multiplier") as? Bool {
                    
                    self.pointValue += 1
                }
                else if let _:Bool = firstBody.node?.userData?.value(forKey: "Bomb") as? Bool {
                    
                    mainLayer.enumerateChildNodes(withName: "Halo", using: { (node, stop) -> Void in
                        self.addExplosion(node.position, fileName: "HaloExplosion")
                        self.run(self.haloExplosion)
                        node.removeFromParent()
                    })
                }
            }
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
            haloCount -= 1
        }
        
        if firstBody.categoryBitMask == kHaloCategory && secondBody.categoryBitMask == kShieldCategory {
            
            if let firstPosition = firstBody.node?.position {
                run(haloBlastSound)
                addExplosion(firstPosition, fileName:"HaloExplosion")
                
                if let _ = firstBody.node?.userData?.value(forKey: "Bomb") as? Bool {
                    mainLayer.enumerateChildNodes(withName: "Shield", using: {
                        node, stop in
                        
                        self.addExplosion(node.position, fileName: "HaloExplosion")
                        self.run(self.haloExplosion)
                        node.removeFromParent()
                    })
                } else {
                    firstBody.node?.removeFromParent()
                    shieldPool.append((secondBody.node) as! SKSpriteNode)
                    secondBody.node?.removeFromParent()
                    haloCount -= 1
                }
            }
        }
        
        if firstBody.categoryBitMask == kHaloCategory && secondBody.categoryBitMask == kLifeBarCategory {
            
            if let firstPosition = firstBody.node?.position {
                addExplosion(firstPosition, fileName:"LifeBarExplosion")
                self.run(lifebarBlastSound)
                
                firstBody.node!.removeFromParent()
                secondBody.node!.removeFromParent()
                gameOver()
            } else {
                gameOver()
            }
        }
        
        if firstBody.categoryBitMask == kHaloCategory && secondBody.categoryBitMask == kEdgeCategory {
            
            firstBody.velocity = (CGVector(dx: firstBody.velocity.dx * -1.0, dy: firstBody.velocity.dy))
            
            if isGameOver == false {
                self.run(bounceSound)
            }

        }
        
        if firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kEdgeCategory {
            
            if let body = firstBody.node as? CCBall {
                body.bounces += 1
                if body.bounces > 3 {
                    firstBody.node?.removeFromParent()
                    self.pointValue = 1
                }
            }
            if isGameOver == false {
                self.run(bounceSound)
            }
            
        }
        
        if firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kShieldUpCategory {
            //Hit shield power up
            
            let i = UInt32(shieldPool.count)
            let randomIndex:Int = Int(arc4random_uniform(i))
            if shieldPool.count > 0 {
                let randomShield = shieldPool[randomIndex]
                mainLayer.addChild(randomShield)
                self.run(shieldUpSound)
                shieldPool.remove(at: randomIndex)
            }
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kMultiShotBallCategory {
            
            multiMode = true
            self.run(shieldUpSound)
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
            ammo = 5
            setMultiMode()
            
        }
    }
    // MARK: Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            if isGameOver == false && self.gamePaused == false {
                didShoot = true
                if pauseBtn.contains(touch.location(in: pauseBtn.parent!)) {

                }
            } 
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            if isGameOver == true {
                let location:CGPoint = touch.location(in: menu)
                let node:SKNode = menu.atPoint(location)
                if node.name == "Play" {
                    self.newGame()
                }
            }
            if isGameOver == false {
                if gamePaused == true {
                    if resumeBtn.contains(touch.location(in: resumeBtn.parent!)) {
                        gamesPaused(false)
                    }
                }
                else if pauseBtn.contains(touch.location(in: pauseBtn.parent!)) {
                    gamesPaused(true)
                    print("Pause touched")
                }
            }
        }
    }
    

    
 
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        setAmmo()
        adjustScore(score)
        adjustPointValue(pointValue)
    }


    // MARK: Shooter

    
    fileprivate func radiansToVector (_ radians:CGFloat) -> CGVector {
        
        let vector = CGVector(dx: cos(radians), dy: sin(radians))
        
        return vector
    }

    func shoot () {
        
        self.run(laserBlastSound)
        self.ammo = self.ammo - 1
        let ball = CCBall(imageNamed: "Ball")
        ball.name = "Ball"
        let rotationVector = radiansToVector(cannon.zRotation)
        ball.position = CGPoint(x: cannon.position.x + (cannon.size.width * 0.5 * rotationVector.dx), y: cannon.position.y + (cannon.size.width * 0.5 * rotationVector.dy))
        mainLayer.addChild(ball)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 6.0)
        ball.physicsBody?.velocity = CGVector(dx: rotationVector.dx * shootSpeed, dy: rotationVector.dy * shootSpeed)
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.friction = 0
        ball.physicsBody?.categoryBitMask = kBallCategory
        ball.physicsBody?.collisionBitMask = kEdgeCategory
        ball.physicsBody?.contactTestBitMask = kEdgeCategory | kShieldUpCategory | kMultiShotBallCategory | kMultiShotBallCategory
        
        // create trail
        let ballTrailPath:String = Bundle.main.path(forResource: "BallTrail", ofType: "sks")!
        let ballTrail:SKEmitterNode = NSKeyedUnarchiver.unarchiveObject(withFile: ballTrailPath) as! SKEmitterNode
        ballTrail.targetNode = mainLayer
        mainLayer.addChild(ballTrail)
        ball.trail = ballTrail
    }
    
    
    override func didSimulatePhysics() {
        
        if let shot = didShoot {
            if shot == true {
                if self.ammo > 0 {
                    shoot()
                    
                    if self.multiMode == true {
                        
                        var i = 1.0
                        while i <= 5.0 {
                            i += 1.0
                            let time = i * 0.1
                            let cannonAction = SKAction.sequence([SKAction.wait(forDuration: time),
                                SKAction.run({ () -> Void in
                                    self.shoot()
                                })])
                            self.run(SKAction.repeat(cannonAction, count: 1))
                        }
                        self.multiMode = false
                        self.ammo = 5
                        self.setMultiMode()
                    }
                }
            }
                        didShoot? = false
        }
        
        mainLayer.enumerateChildNodes(withName: "Ball", using: { (node, stop) -> Void in
            
            if node.responds(to: #selector(CCBall.updateTrail)) {
                (node as! CCBall).updateTrail()
            }
            
            if (!self.frame.contains(node.position)){
                node.removeFromParent()
                self.pointValue = 1
            }
        })
        
        mainLayer.enumerateChildNodes(withName: "ShieldUp", using: { (node, stop) -> Void in
            
            if node.position.x + node.frame.size.width < 0 {
                node.removeFromParent()
            }
            
        })
        mainLayer.enumerateChildNodes(withName: "MultiUp", using: { (node, stop) -> Void in
            
            if node.position.x - node.frame.size.width < self.size.width {
                node.removeFromParent()
            }
            
        })
        mainLayer.enumerateChildNodes(withName: "Halo", using: { (node, stop) -> Void in
            
            if node.position.y + node.frame.size.height < 0 {
                node.removeFromParent()
            }

        })
        
    }
    
    fileprivate func randomInRange(_ low:CGFloat, high:CGFloat) -> CGFloat {
        
        let ranValue:CGFloat = CGFloat(arc4random_uniform(UINT32_MAX)) / CGFloat(UINT32_MAX)
        
        return ranValue * (high - low) + low
    }
    
    //MARK: Halo Targets
    
    
    func spawnHalo () {
        
        // increase spawn speed
        
        let spawnHaloAction = self.action(forKey: "SpawnHaloSequence")
        if spawnHaloAction?.speed  < 3.0 {
            spawnHaloAction?.speed += 0.01
        }
        
        let halo = SKSpriteNode(imageNamed: "Halo")
        halo.name = "Halo"
        halo.position =  CGPoint(x: randomInRange(halo.size.width * 0.5, high: self.size.width - (halo.size.width * 0.5)), y: self.size.height + halo.size.height * 0.5)
        halo.physicsBody = SKPhysicsBody(circleOfRadius: 28.0)
        let direction = radiansToVector(randomInRange(kHaloLowAngle, high: kHaloHighAngle))
        halo.physicsBody?.velocity = CGVector(dx: direction.dx * kHaloSpeed, dy: direction.dy * kHaloSpeed)
        halo.physicsBody?.restitution = 1
        halo.physicsBody?.linearDamping = 0
        halo.physicsBody?.friction = 0
        halo.physicsBody?.categoryBitMask = kHaloCategory
        halo.physicsBody?.collisionBitMask = 0
        halo.physicsBody?.contactTestBitMask = kBallCategory | kShieldCategory | kLifeBarCategory | kEdgeCategory
        
        
        if isGameOver == false {
            
            for node in mainLayer.children {
                
                    let aNode:SKNode = node 
                    
                    if aNode.name == "Halo" {
                    
                        haloCount += 1
                    }
            }
            
            if haloCount >= 10 && haloCount <= 40 {
                //create halo bomb
               
                halo.texture = SKTexture(imageNamed: "HaloBomb")
                halo.userData = ["Bomb" : true]
                halo.physicsBody?.velocity = CGVector(dx: direction.dx * (kHaloSpeed + 40), dy: direction.dy * (kHaloSpeed + 40))
                haloCount = 0
                print("Bomb's away")
            }
            else if (isGameOver == false && arc4random_uniform(6) == 0) {
                // random point multiplier

                halo.texture = SKTexture(imageNamed: "HaloX")
                halo.userData = ["Multiplier": true]
            }

        }
                
        mainLayer.addChild(halo)
    }
    
    func spawnMultiShotPowerUp () {
       
        if killCount % 10 == 0 | 1 | 2 {
           
            let multiShot = SKSpriteNode(imageNamed: "MultiShotPowerUp")
            multiShot.name = "MultiUp"
            multiShot.position = CGPoint(x: -multiShot.size.width, y: randomInRange(150, high: self.size.height - 100))
            multiShot.physicsBody = SKPhysicsBody(circleOfRadius: 12)
            multiShot.physicsBody?.categoryBitMask = kMultiShotBallCategory
            multiShot.physicsBody?.collisionBitMask = 0
            multiShot.physicsBody?.velocity = CGVector(dx: 100, dy: randomInRange(-40, high: 40))
            multiShot.physicsBody?.angularVelocity = CGFloat(M_1_PI)
            multiShot.physicsBody?.linearDamping = 0.0
            multiShot.physicsBody?.angularDamping = 0.0
            self.addChild(multiShot)
            print("should be multishot")
            killCount = 0
            
        }
    }
    
    func setMultiMode () {
        
        if multiMode == true {
            
            cannon.texture = SKTexture(imageNamed: "GreenCannon")
        }
        
        else {
            cannon.texture = SKTexture(imageNamed: "Cannon")
        }
        
    }

    func spawnShieldPowerUp () {
        
        
        if shieldPool.count > 0 {
            
            let shieldUp = SKSpriteNode(imageNamed: "Block")
            shieldUp.name = "ShieldUp"
            shieldUp.position = CGPoint(x: self.size.width + shieldUp.size.width, y: randomInRange(150, high: self.size.height - 100))
            shieldUp.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 42, height: 9))
            shieldUp.physicsBody?.categoryBitMask = kShieldUpCategory
            shieldUp.physicsBody?.collisionBitMask = 0
            shieldUp.physicsBody?.velocity = CGVector(dx: -100, dy: randomInRange(-40, high: 40))
            shieldUp.physicsBody?.angularVelocity = CGFloat(M_1_PI)
            shieldUp.physicsBody?.linearDamping = 0.0
            shieldUp.physicsBody?.angularDamping = 0.0
            
            mainLayer.addChild(shieldUp)
        }
        
    }
    
    
    fileprivate func addExplosion (_ position:CGPoint, fileName:String) {
        
        let explosionPath:String = Bundle.main.path(forResource: fileName, ofType: "sks")!
        let explosion:SKEmitterNode = NSKeyedUnarchiver.unarchiveObject(withFile: explosionPath) as! SKEmitterNode
        explosion.position = position
        explosion.particleTexture = SKTexture(imageNamed: "Halo@2x.png")
        
        mainLayer.addChild(explosion)
        
        _ = SKAction.sequence([SKAction.wait(forDuration: 1.5),
                                                 SKAction.removeFromParent()])
    }
    // MARK: New / GameOver / Pause
    
    func gamesPaused (_ gp:Bool) {
        
        if !isGameOver {
            gamePaused = gp
            pauseBtn.isHidden = gp
            resumeBtn.isHidden = !gp
            self.isPaused = gamePaused
            
            if gp == true {
                audioPlayer.pause()
            }
            else {
                audioPlayer.play()
            }
        }
    }
    
    fileprivate func gameOver () {
        
        // iAd notification
        
        if gameCount == 2 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationKey), object: self)
            gameCount = 0
        }
        
        mainLayer.enumerateChildNodes(withName: "Halo", using: { (node, stop) -> Void in
            
            self.addExplosion(node.position, fileName: "HaloExplosion")
            node.removeFromParent()
        })
        
        mainLayer.enumerateChildNodes(withName: "Ball", using: { (node, stop) -> Void in
            node.removeFromParent()
        })
        mainLayer.enumerateChildNodes(withName: "Shield", using: { (node, stop) -> Void in
            
            self.shieldPool.append(node as! SKSpriteNode)
            node.removeFromParent()
        })
        
        mainLayer.enumerateChildNodes(withName: "ShieldUp", using: { (node, stop) -> Void in
            node.removeFromParent()
        
        })
        
        mainLayer.enumerateChildNodes(withName: "MultiUp", using: { (node, stop) -> Void in
            
           node.removeFromParent()
        })


        
        let delay = Int64(1.5 * Double(NSEC_PER_SEC))
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
        }
        menu.isHidden = false
        menu.setMenuScore(self.score)
        menu.setMenuTopScore(self.score)
        scoreLabel.isHidden = true
        pointLabel.isHidden = true
        isGameOver = true
        shieldPool.removeAll(keepingCapacity: true)
        pauseBtn.isHidden = true
        audioPlayer.stop()
    }
    
    func newGame () {
        
        mainLayer.removeAllChildren()
        
        //Life Bar
        
        lifeBar.position = CGPoint(x: self.size.width * 0.5, y: 70)
        lifeBar.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -lifeBar.size.width * 0.5, y: 0), to: CGPoint(x: lifeBar.size.width * 0.5, y: 0))
        lifeBar.physicsBody?.categoryBitMask = kLifeBarCategory
        mainLayer.addChild(lifeBar)
       
        //shield set up
        
        let shieldStart = Int(lifeBar.frame.minX + 30)
        
        for i in 0 ..< 6 {
            let shield = SKSpriteNode(imageNamed: "Block")
            shield.name = "Shield"
            shield.position = CGPoint(x: shieldStart + (50 * i), y: 90)
            shield.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 42, height: 9))
            shield.physicsBody?.categoryBitMask = kShieldCategory
            shield.physicsBody?.collisionBitMask = 0
            shieldPool.append(shield)
        }

        
        while shieldPool.count > 0 {
            mainLayer.addChild(shieldPool[0])
            shieldPool.remove(at: 0)
            
        }
        
        // initial setup
        
        self.action(forKey: "HaloSpawnSequence")?.speed = 1
        ammo = 5
        score = 0
        pointValue = 1
        scoreLabel.isHidden = false
        pointLabel.isHidden = false
        isGameOver = false
        menu.isHidden = true
        haloCount = 0
        killCount = 0
        multiMode = false
        gamePaused = false
        pauseBtn.isHidden = false
        
        // loading the backgound sound
        
        let url:URL = Bundle.main.url(forResource: "synthOminousLoop", withExtension: "caf")!
        var err:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            err = error
            
        }
        audioPlayer.numberOfLoops = -1
        audioPlayer.volume = 0.1
        
        audioPlayer.play()
        gameCount += 1
      }
    
    
}
