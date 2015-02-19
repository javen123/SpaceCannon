//
//  GameScene.swift
//  SpaceCannon
//
//  Created by Jim Aven on 2/13/15.
//  Copyright (c) 2015 Jim Aven. All rights reserved.
//

import SpriteKit

let userDefaults = NSUserDefaults.standardUserDefaults()
let keyTopScore = "TopScore"


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: Constants
    
    let cannon = SKSpriteNode(imageNamed: "Cannon")
    let mainLayer = SKNode()
    let shootSpeed:CGFloat = 1000
    let kHaloLowAngle:CGFloat = 200.0 * CGFloat(M_PI) / 180.0
    let kHaloHighAngle:CGFloat = 340.0 * CGFloat(M_PI) / 180.0
    let kHaloSpeed:CGFloat = 100.0
    let kHaloCategory:UInt32 = 0x1 << 0
    let kBallCategory:UInt32 = 0x1 << 1
    let kEdgeCategory:UInt32 = 0x1 << 2
    let kShieldCategory:UInt32 = 0x1 << 3
    let kLifeBarCategory:UInt32 = 0x1 << 4
    
    let scoreLabel = SKLabelNode(fontNamed: "DIN Alternate")
    let ammoDisplay = SKSpriteNode(imageNamed: "Ammo5")
    
    let laserBlastSound = SKAction.playSoundFileNamed("laserBlast.caf", waitForCompletion: false)
    let lifebarBlastSound = SKAction.playSoundFileNamed("lifeBarBlast.caf", waitForCompletion: false)
    let haloBlastSound = SKAction.playSoundFileNamed("haloBlast.caf", waitForCompletion: false)
    let bounceSound = SKAction.playSoundFileNamed("bounce.caf", waitForCompletion: false)
    
    let menu = MenuVC()
    
    
    var didShoot:Bool!
    var ammo = 5
    var score:Int!
    var isGameOver:Bool!
    
    
    
   override func didMoveToView(view: SKView) {
    
    
        self.size = view.bounds.size

        // turn off gravity
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
            
        //add background
        
        let background = SKSpriteNode(imageNamed: "Starfield")
        background.position = CGPointMake(view.bounds.width/2, view.bounds.height/2)
        background.size = CGSize(width: self.size.width, height: self.size.height)
        background.blendMode = SKBlendMode.Replace
        addChild(background)
        
        // add layer
        
        addChild(mainLayer)

        // add edges

        let leftEdge = SKNode()
        leftEdge.physicsBody = SKPhysicsBody(edgeFromPoint:CGPointZero, toPoint: CGPointMake(0.0, self.size.height + 100))
        leftEdge.position = CGPointZero
        leftEdge.physicsBody?.categoryBitMask = kEdgeCategory
        addChild(leftEdge)

        let rightEdge = SKNode()
        rightEdge.physicsBody = SKPhysicsBody(edgeFromPoint:CGPointZero, toPoint: CGPointMake(0.0, self.size.height + 100))
        rightEdge.position = CGPointMake(self.size.width, 0.0)
        rightEdge.physicsBody?.categoryBitMask = kEdgeCategory
        addChild(rightEdge)


        // add cannon
        
        cannon.position = CGPointMake(self.size.width/2, 0.0)
        self.addChild(cannon)
        
        // Cannon rotation action
        
        let rotateCannon = SKAction.sequence([
                           SKAction.rotateByAngle(3.14, duration: 2),
                           SKAction.rotateByAngle(-3.14, duration: 2)])

        cannon.runAction(SKAction.repeatActionForever(rotateCannon))

        // Create Spawn Halo's

        let haloSpawn = SKAction.sequence([
                        SKAction.waitForDuration(2, withRange: 1),
                        SKAction.runBlock(spawnHalo)])

        self.runAction(SKAction.repeatActionForever(haloSpawn), withKey:"SpawnHaloSequence")


        // Setup Ammo display
       
        ammoDisplay.anchorPoint = CGPointMake(0.5, 0.0)
        ammoDisplay.position = cannon.position
        self.addChild(ammoDisplay)
        

        let incrementAmmo = SKAction.sequence([SKAction.waitForDuration(1.5),
                                               SKAction.runBlock({self.ammo = self.ammo + 1
                                                                  })])

        self.runAction(SKAction.repeatActionForever(incrementAmmo))
        
        // set up score label
        
        scoreLabel.position = CGPointMake(15, 10)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.fontSize = 15
        score = 0
        self.addChild(scoreLabel)
        
        // set up menu
    
        menu.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(menu)
        isGameOver = true
        
    
        // load top score
    
        menu.topScoreMenu = userDefaults.integerForKey(keyTopScore)
    
    }
    
    func setScore (aScore:Int) {
        
        scoreLabel.text = "Score: \(aScore)"
        
    }
    
    func setAmmo () {
        
        if ammo >= 0 && ammo <= 5 {
            let ammoTextureName = "Ammo\(ammo)"
            ammoDisplay.texture = SKTexture(imageNamed: ammoTextureName)
        }
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
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
            
            score = score + 1
            let firstPosition = firstBody.node?.position
            addExplosion(firstPosition!, fileName: "HaloExplosion")
            self.runAction(haloBlastSound)
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == kHaloCategory && secondBody.categoryBitMask == kShieldCategory {
            
            let firstPosition = firstBody.node?.position
            runAction(haloBlastSound)
            addExplosion(firstPosition!, fileName:"HaloExplosion")
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == kHaloCategory && secondBody.categoryBitMask == kLifeBarCategory {
            
            let firstPosition = firstBody.node?.position
            addExplosion(firstPosition!, fileName:"LifeBarExplosion")
            self.runAction(lifebarBlastSound)
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
            gameOver()
            
        }
        
        if firstBody.categoryBitMask == kHaloCategory && secondBody.categoryBitMask == kEdgeCategory {
            
            self.runAction(bounceSound)

        }
        
        if firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kEdgeCategory {
            
            self.runAction(bounceSound)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch in touches {
            if isGameOver == false {
                didShoot = true
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            if isGameOver == true {
                var location:CGPoint = touch.locationInNode(menu)
                var node:SKNode = menu.nodeAtPoint(location)
                if node.name == "Play" {
                    self.newGame()
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        setAmmo()
        setScore(score)
    }


    // MARK: Shooter

    
    private func radiansToVector (var radians:CGFloat) -> CGVector {
        
        var vector = CGVector(dx: cos(radians), dy: sin(radians))
        
        return vector
    }

    func shoot () {
        
        if self.ammo > 0 {
            self.runAction(laserBlastSound)
            self.ammo = self.ammo - 1
            let ball = SKSpriteNode(imageNamed: "Ball")
            ball.name = "Ball"
            var rotationVector = radiansToVector(cannon.zRotation)
            ball.position = CGPointMake(cannon.position.x + (cannon.size.width * 0.5 * rotationVector.dx), cannon.position.y + (cannon.size.width * 0.5 * rotationVector.dy))
            mainLayer.addChild(ball)
            
            ball.physicsBody = SKPhysicsBody(circleOfRadius: 6.0)
            ball.physicsBody?.velocity = CGVector(dx: rotationVector.dx * shootSpeed, dy: rotationVector.dy * shootSpeed)
            ball.physicsBody?.restitution = 1
            ball.physicsBody?.linearDamping = 0
            ball.physicsBody?.friction = 0
            ball.physicsBody?.categoryBitMask = kBallCategory
            ball.physicsBody?.collisionBitMask = kEdgeCategory
            ball.physicsBody?.contactTestBitMask = kEdgeCategory

        }
        
    }
    
    override func didSimulatePhysics() {
        
        if didShoot? == true {
            shoot()
            didShoot? = false
        }
        
        mainLayer.enumerateChildNodesWithName("Ball", usingBlock: { (node, stop) -> Void in
            if (!CGRectContainsPoint(self.frame, node.position)){
                node.removeFromParent()
            }
        })
    }
    
    private func randomInRange(low:CGFloat, high:CGFloat) -> CGFloat {
        
        var ranValue:CGFloat = CGFloat(arc4random_uniform(UINT32_MAX)) / CGFloat(UINT32_MAX)
        
        return ranValue * (high - low) + low
    }
    
    //MARK: Halo Targets
    
    
    func spawnHalo () {
        
        // increase spawn speed
        
        let spawnHaloAction = self.actionForKey("SpawnHaloSequence")
        if spawnHaloAction?.speed  < 1.5 {
            spawnHaloAction?.speed += 0.05
        }
        
        let halo = SKSpriteNode(imageNamed: "Halo")
        halo.name = "Halo"
        halo.position =  CGPointMake(randomInRange(halo.size.width * 0.5, high: self.size.width - (halo.size.width * 0.5)), self.size.height + halo.size.height * 0.5)
        halo.physicsBody = SKPhysicsBody(circleOfRadius: 16.0)
        var direction = radiansToVector(randomInRange(kHaloLowAngle, high: kHaloHighAngle))
        halo.physicsBody?.velocity = CGVectorMake(direction.dx * kHaloSpeed, direction.dy * kHaloSpeed)
        halo.physicsBody?.restitution = 1
        halo.physicsBody?.linearDamping = 0
        halo.physicsBody?.friction = 0
        halo.physicsBody?.categoryBitMask = kHaloCategory
        halo.physicsBody?.collisionBitMask = kEdgeCategory
        halo.physicsBody?.contactTestBitMask = kBallCategory | kShieldCategory | kLifeBarCategory | kEdgeCategory
        mainLayer.addChild(halo)
    }
    
    
    private func addExplosion (position:CGPoint, fileName:String) {
        
        let explosionPath:String = NSBundle.mainBundle().pathForResource(fileName, ofType: "sks")!
        let explosion:SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(explosionPath) as SKEmitterNode
        explosion.position = position
        explosion.particleTexture = SKTexture(imageNamed: "Halo@2x.png")
        
        mainLayer.addChild(explosion)
        
        let removeExplosion = SKAction.sequence([SKAction.waitForDuration(1.5),
                                                 SKAction.removeFromParent()])
    }
    
    private func gameOver () {
        
        mainLayer.enumerateChildNodesWithName("Halo", usingBlock: { (node, stop) -> Void in
            node.removeFromParent()
        })
        
        mainLayer.enumerateChildNodesWithName("Ball", usingBlock: { (node, stop) -> Void in
            node.removeFromParent()
        })
        mainLayer.enumerateChildNodesWithName("Shield", usingBlock: { (node, stop) -> Void in
            node.removeFromParent()
        })
        
        let delay = Int64(1.5 * Double(NSEC_PER_SEC))
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
        }
        menu.hidden = false
        menu.setMenuScore(self.score)
        menu.setMenuTopScore(self.score)
        
        isGameOver = true
    }
    
    func newGame () {
        
        mainLayer.removeAllChildren()

        // set up shields
        
        for var i = 0; i < 6; i++ {
            let shield = SKSpriteNode(imageNamed: "Block")
            shield.name = "Shield"
            shield.position = CGPoint(x: 35 + (50 * i), y: 90)
            mainLayer.addChild(shield)
            shield.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(42, 9))
            shield.physicsBody?.categoryBitMask = kShieldCategory
            shield.physicsBody?.collisionBitMask = 0
            
        }
        
        //Life Bar
        let lifeBar = SKSpriteNode(imageNamed: "BlueBar")
        lifeBar.position = CGPointMake(self.size.width * 0.5, 70)
        lifeBar.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-lifeBar.size.width * 0.5, 0), toPoint: CGPointMake(lifeBar.size.width * 0.5, 0))
        lifeBar.physicsBody?.categoryBitMask = kLifeBarCategory
        mainLayer.addChild(lifeBar)
        
        
        // initial setup
        
        self.actionForKey("HaloSpawnSequence")?.speed = 1
        ammo = 5
        score = 0

        isGameOver = false
        menu.hidden = true
    }
}
