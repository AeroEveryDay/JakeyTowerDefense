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
    case Shooter = 5
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

func getDistance(first: CGPoint, second: CGPoint) -> CGFloat{
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
    let TowerCategory   : UInt32 = 0x1 << 0
    let EnemyCategory : UInt32 = 0x1 << 1
    let ProjectileCategory  : UInt32 = 0x1 << 2
    let WallCategory : UInt32 = 0x1 << 3
    let ShooterCategory : UInt32 = 0x1 << 4
    let None : UInt32 = 0x1 << 5
    var towers: [Towers] = []
    var range: SKShapeNode = SKShapeNode(circleOfRadius: 0)
    

    
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        
        addTower("Jakey", speed: 10, range: 300, x: frame.width/2, y: 200)
        //addTower("Carl Steepenz", speed: 10, range: 100, x: frame.width/2, y: 600)
        
        addEnemy("The Juicer", speed: 5, hp: 100, x: 0, y: 0)
        
        addButton("addEnemy", height: 50, width: 100, x: 110, y: 45, color: SKColor.orangeColor())
        addButton("addTower", height: 50, width: 100, x: 660, y: 45, color: SKColor.blueColor())
        
    }//didMoveToView
    
    func addButton(name: String?, height: CGFloat, width: CGFloat, x: CGFloat, y:CGFloat, color: SKColor){
        var button = SKShapeNode(rectOfSize: CGSize(width: width, height: height))
        button.fillColor = color
        button.name = name
        button.position.x = x
        button.position.y = y
        addChild(button)
    }
    
    func newAddChild(node: SKNode){
        addChild(node)
    }
   
    func addShooter(name: String, tower: SKShapeNode, withinRange: CGFloat){
        let shooter = SKShapeNode(circleOfRadius: withinRange)
        shooter.fillColor = SKColor.grayColor()
        shooter.alpha = 0.5
        shooter.physicsBody = SKPhysicsBody(circleOfRadius: withinRange)
        shooter.physicsBody?.affectedByGravity = false
        shooter.physicsBody?.categoryBitMask = ShooterCategory
        shooter.physicsBody?.contactTestBitMask =  EnemyCategory
        shooter.physicsBody?.collisionBitMask = 0
        shooter.position = tower.position
        shooter.physicsBody?.usesPreciseCollisionDetection = true
        shooter.physicsBody?.dynamic = true
        addChild(shooter)
        
    }
    
    func shoot(target: SKNode, shooter: SKNode){
        
        let projectileNode = SKShapeNode(circleOfRadius: 10)
        var projectile = Projectile(damage: 10, size: 10, color: SKColor.redColor())
        
        projectileNode.fillColor = projectile.color
        projectileNode.position = shooter.position
        
        projectileNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        projectileNode.physicsBody!.affectedByGravity = false
        projectileNode.physicsBody?.categoryBitMask = ColliderType.Projectile.rawValue
        projectileNode.physicsBody?.collisionBitMask = ColliderType.Enemy.rawValue
        projectileNode.physicsBody?.collisionBitMask = ColliderType.Wall.rawValue
        
 
 
        addChild(projectileNode)
        
        // 3 - Determine offset of location to projectile
        let offset = minus(target.position, second: shooter.position)
        
        // 5 - OK to add now - you've double checked position
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + shooter.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectileNode.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        
    }
 
  //  func getTarget(shooter: SKNode) -> SKNode{}
    
    func addTower(name: String, speed: Float, range: CGFloat, x: CGFloat, y:CGFloat){
        let towerNode = SKShapeNode(circleOfRadius: 25)
        
        var tower = Towers(name: name, speed: 10, range: 100, size: 25, color: SKColor.blueColor(),tower: towerNode, x: x, y: y)
        towerNode.fillColor = tower.color
  
        towers.append(tower)
        
        towerNode.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        towerNode.physicsBody!.affectedByGravity = false
        towerNode.physicsBody?.categoryBitMask = ColliderType.Tower.rawValue
        towerNode.physicsBody?.collisionBitMask = ColliderType.Projectile.rawValue
        
        towerNode.position.x = x
        towerNode.position.y = y
        towerNode.physicsBody?.dynamic = false
        addShooter(name, tower: towerNode, withinRange: range)
        addChild(towerNode)
    }
    
    func addEnemy(name: String, speed: Float, hp: Float, x: CGFloat, y: CGFloat){
        let enemyNode = SKShapeNode(circleOfRadius: 20)
        var enemy = Enemy(name: name, hp: 100, speed: 50, size: 20, enemy: enemyNode, color: SKColor.orangeColor(), x: x, y: y, path: [Float]())
        enemyNode.fillColor = enemy.color
        
        enemyNode.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        enemyNode.physicsBody!.affectedByGravity = false
        enemyNode.physicsBody?.categoryBitMask = EnemyCategory
        enemyNode.physicsBody?.contactTestBitMask = ShooterCategory
        enemyNode.physicsBody?.collisionBitMask = 0
        enemyNode.physicsBody?.usesPreciseCollisionDetection = true

        enemyNode.position.x = x
        enemyNode.position.y = y
        enemyNode.physicsBody?.dynamic = true
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
    
    var touchCount: Float = 0
    var addTowerCount: Float = 0
    var toAddTower: Bool = false
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // let touchCount = touches.count
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(self)
        
        touchCount+=1
        addTowerCount = touchCount
    
        let node: SKNode = self.nodeAtPoint(location)
        
        if (node.name == ("addEnemy") && !toAddTower){
            addEnemy("The Juicer", speed: 5, hp: 100, x: 0, y: 0)
        }
        
        if (node.name == ("addTower")){
            toAddTower = true
            addTowerCount+=1
          
        }
        println("addTowerCount: \(addTowerCount) touchCount: \(touchCount) toAddTower: \(toAddTower)")
        
        if(toAddTower && (touchCount == addTowerCount)){
            addTower("Carl Steepenz", speed: 10, range: 100, x: location.x, y: location.y)
            toAddTower = false
        }
        
        
      //  addEnemy("The Juicer", speed: 5, hp: 100, x: 0, y: 0)
        
        let position = touch.locationInNode(self)
        println("x: \(position.x)y: \(position.y)")
        
        let touchLocation = SKShapeNode(circleOfRadius: 25)
        touchLocation.position = CGPointMake(location.x, location.y)
        
      /*  if DistanceBetween(circle.position, shooter.position) < 200{
            shoot(shooter, target: circle)
        }*/
        
     
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstNode: SKPhysicsBody
        var secondNode: SKPhysicsBody
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstNode = contact.bodyA
            secondNode = contact.bodyB
        } else {
            firstNode = contact.bodyB
            secondNode = contact.bodyA
        }
        
        let firstNodePosition: CGPoint = firstNode.node!.position
        let secondNodePosition: CGPoint = secondNode.node!.position

        
        if ((firstNode.categoryBitMask == EnemyCategory) && (secondNode.categoryBitMask == ShooterCategory)) {
            // println("hit")
            // println(firstNode.node?.position)
            // println(secondNode.node?.position)
            shoot( firstNode.node!, shooter: secondNode.node!)
            
        }
        
        
        
   //     println("firstNode: \(firstNode.name)")
     //   println("secondNode: \(secondNode.name)")

        }
    
    }//didBeginContact

//GameScene

    func update(currentTime: CFTimeInterval) {

        
}

