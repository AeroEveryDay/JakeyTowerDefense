//
//  GameScene.swift
//  JakeyTowerDefense
//
//  Created by Jacob Wall on 9/16/15.
//  Copyright (c) 2015 Jacob Wall. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Circle   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    //creating objects
    
        let circle = SKShapeNode(circleOfRadius: 50)
        let shooter = SKShapeNode(circleOfRadius: 35)

   
    
    func addCircle(Name: String, size: CGFloat, x: CGFloat, y: CGFloat){
        let Name = SKShapeNode(circleOfRadius: size)
        
    }
    
    override func didMoveToView(view: SKView) {
        
    //setting object positions
        circle.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/1.2)
        self.addChild(circle)
        shooter.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/4)
        self.addChild(shooter)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
   

    //adding physics to circle
        //adds hitbox to circle
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 50 )
        circle.physicsBody?.dynamic = true
        circle.physicsBody?.categoryBitMask = PhysicsCategory.Circle
    //notifies when circle interacts with a projectile
        circle.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
    //sets collisions to not bounce off of each other
        circle.physicsBody?.collisionBitMask = PhysicsCategory.None
        
    //creating path for circle
        var path = CGPathCreateMutable()

            CGPathMoveToPoint(path, nil, 0, 0)
            CGPathAddLineToPoint(path, nil, 0, -100)
            CGPathAddLineToPoint(path, nil, -50, 50)

        var followLine = SKAction.followPath(path, asOffset: true, orientToPath: false, duration: 10.0)
    //telling circle to being to follow path
        circle.runAction(SKAction.sequence([followLine]))

    }
    
    func minus (first: CGPoint, second: CGPoint) -> CGPoint {
    return CGPointMake(first.x - second.x, first.y - second.y)
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
       // let touchCount = touches.count
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(self)

        let touchLocation = SKShapeNode(circleOfRadius: 25)
        touchLocation.position = CGPointMake(location.x, location.y)
        
        
        // 2 - Set up initial location of projectile
        let projectile = SKShapeNode(circleOfRadius: 10)
        projectile.strokeColor = SKColor.redColor()
        projectile.position = shooter.position
        
            //setting physics of projectile
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        
        // 3 - Determine offset of location to projectile
        let offset = minus(touch.locationInNode(self), second: projectile.position)
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
   
    func projectileDidCollide(projectile: SKShapeNode, object: SKShapeNode){
        println("Hit!")
       // projectile.removeFromParent()
        object.strokeColor = SKColor.redColor()
        
        var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            object.strokeColor = SKColor.whiteColor()
            println("white")
        })
    }

    func changeColor(object: SKShapeNode, color: SKColor, part: UIColor ){
       
    }
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstNode = contact.bodyA.node as! SKShapeNode
        let secondNode = contact.bodyB.node as! SKShapeNode
        
        if(contact.bodyA.categoryBitMask == PhysicsCategory.Circle) &&
            (contact.bodyB.categoryBitMask == PhysicsCategory.Projectile){
                projectileDidCollide(secondNode, object: firstNode )
                let contactPoint = contact.contactPoint
                
        }
    }

 
}
   
  /*  override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }*/

