//
//  GameScene.swift
//  JakeyTowerDefense
//
//  Created by Jacob Wall on 9/16/15.
//  Copyright (c) 2015 Jacob Wall. All rights reserved.
//

import SpriteKit

/*struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Circle   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}*/

enum ColliderType:UInt32{
    case Tower = 1
    case Enemy = 2
    case Projectile = 3
    case Wall = 4
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

func DistanceBetweenPoints(first: CGPoint, second: CGPoint) -> CGFloat{
    return (sqrt((((second.x - first.x)*(second.x - first.x))+((second.y - first.y)*(second.y - first.y)))))
}

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

let level: Float = 1

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    

    
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        
        addTower("Jakey", speed: 10, range: 100, x: frame.width/2, y: 200)
        addTower("Carl Steepenz", speed: 10, range: 100, x: frame.width/2, y: 600)
        addEnemy("The Juicer", speed: 5, hp: 100, x: 0, y: 0)
        
        
    }//didMoveToView
    
    func shoot(shooter: SKNode, target: SKNode) {
        
        // 3 - Determine offset of location to projectile
        let offset = minus(target.position, second: shooter.position)
        
        // 5 - OK to add now - you've double checked position
        
        addProjectile(20, x: shooter.position.x, y: shooter.position.y)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + shooter.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        shooter.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func addProjectile(damage: Float, x: CGFloat, y: CGFloat){
        let projectileNode = SKShapeNode(circleOfRadius: 10)
        var projectile = Projectile(damage: damage, size: 10, x: x, y: y, color: SKColor.redColor())
        
        projectileNode.fillColor = projectile.color
        
        projectileNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        projectileNode.physicsBody!.affectedByGravity = false
        projectileNode.physicsBody?.categoryBitMask = ColliderType.Projectile.rawValue
        projectileNode.physicsBody?.collisionBitMask = ColliderType.Enemy.rawValue
        projectileNode.physicsBody?.collisionBitMask = ColliderType.Wall.rawValue
        
        projectileNode.position.x = x
        projectileNode.position.y = y
        addChild(projectileNode)
        
    }
    
    func addTower(name: String, speed: Float, range: Float, x: CGFloat, y:CGFloat){
        let towerNode = SKShapeNode(circleOfRadius: 25)
        var tower = Towers(name: name, speed: 10, range: 100, size: 25, color: SKColor.blueColor(),tower: towerNode, x: x, y: y)
        towerNode.fillColor = tower.color
        
        
        towerNode.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        towerNode.physicsBody!.affectedByGravity = false
        towerNode.physicsBody?.categoryBitMask = ColliderType.Tower.rawValue
        towerNode.physicsBody?.collisionBitMask = ColliderType.Projectile.rawValue
        
        towerNode.position.x = x
        towerNode.position.y = y
        addChild(towerNode)
    }
    
    func addEnemy(name: String, speed: Float, hp: Float, x: CGFloat, y: CGFloat){
        let enemyNode = SKShapeNode(circleOfRadius: 20)
        var enemy = Enemy(name: name, hp: 100, speed: 50, size: 20, enemy: enemyNode, color: SKColor.orangeColor(), x: x, y: y, path: [Float]())
        enemyNode.fillColor = enemy.color
        
        enemyNode.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        enemyNode.physicsBody!.affectedByGravity = false
        enemyNode.physicsBody?.categoryBitMask = ColliderType.Enemy.rawValue
        enemyNode.physicsBody?.collisionBitMask = ColliderType.Projectile.rawValue
        
        enemyNode.position.x = x
        enemyNode.position.y = y
        addChild(enemyNode)
        
        Paths(rider: enemyNode)
        
        
        
    }
    
    func minus (first: CGPoint, second: CGPoint) -> CGPoint {
        return CGPointMake(first.x - second.x, first.y - second.y)
    }//minus
    
    func projectileDidCollide(projectile: SKShapeNode, object: SKShapeNode){
    println("Projectile Hit: \(projectile.name) !")
    projectile.removeFromParent()
    //object.strokeColor = SKColor.redColor()

  
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // let touchCount = touches.count
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(self)
        addEnemy("The Juicer", speed: 5, hp: 100, x: 0, y: 0)
        
        let position = touch.locationInNode(self)
        println("x: \(position.x)y: \(position.y)")
        
        let touchLocation = SKShapeNode(circleOfRadius: 25)
        touchLocation.position = CGPointMake(location.x, location.y)
        
      /*  if DistanceBetween(circle.position, shooter.position) < 200{
            shoot(shooter, target: circle)
        }*/
        
     
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstNode = contact.bodyA.node as! SKShapeNode
        let secondNode = contact.bodyB.node as! SKShapeNode
        
        print("Hit!")
        
       /* if(contact.bodyA.categoryBitMask == PhysicsCategory.Circle) &&
            (contact.bodyB.categoryBitMask == PhysicsCategory.Projectile){
                projectileDidCollide(secondNode, object: firstNode )
                let contactPoint = contact.contactPoint
        */
        }
    }//didBeginContact
    
 /*   override func update(currentTime: NSTimeInterval) {
       
    }*/
    
//GameScene

/*  override func update(currentTime: CFTimeInterval) {
/* Called before each frame is rendered */
}*/

