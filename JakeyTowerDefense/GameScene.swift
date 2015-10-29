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

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
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
    
    static var shooters: [SKShapeNode] = []
    var enemies: [SKShapeNode] = []
    var inRange: [SKPhysicsBody] = []
    var range: SKShapeNode = SKShapeNode(circleOfRadius: 0)
    static var enemyCount: Float = 0
    var enemiesInRange: [SKPhysicsBody] = []
    var enemyOrder: [Float] = []
    var enemyDistances: [Float] = []
    var firstEnemy = SKNode()
    var firstEnemyNum: Float = 0
    var lastEnemyNum: Float = 0
    var closestEnemyDistance: Float = 0
    var closestEnemy: Int = 0
    
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.whiteColor()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("toShoot"), userInfo: nil, repeats: true)
        
        addTower("Jakey", speed: 10, range: 300, x: frame.width/2, y: 500)
        //addTower("Carl Steepenz", speed: 10, range: 100, x: frame.width/2, y: 600)
        
        addEnemy("The Juicer", speed: 5, hp: 100, x: 0, y: 0)
        
        addButton("addEnemy", height: 50, width: 100, x: 110, y: 45, color: SKColor.orangeColor())
        addButton("addTower", height: 50, width: 100, x: 660, y: 45, color: SKColor.blueColor())
        addButton("deleteTower", height: 50, width: 100, x: 680, y: 1200, color: SKColor.blueColor())
        
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
   
    func addEnemyInRange(body: SKNode, tower: SKNode){
        
        if (body.physicsBody!.categoryBitMask == EnemyCategory){
            
            enemiesInRange.append(body.physicsBody!)
            enemyOrder.append(body.name!.floatValue)
            enemyDistances.append(Float(getDistance(body.position, tower.position)))
            
        }
        
    }
    
    func addShooter(name: String, tower: SKShapeNode, withinRange: CGFloat, num: Int){
        let shooter = SKShapeNode(circleOfRadius: withinRange)
        shooter.fillColor = SKColor.grayColor()
        shooter.name = name
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
        GameScene.shooters.append(shooter)
    }
    
    func toShoot(){
        if GameScene.shooters.count > 0{
            for (shooter) in GameScene.shooters{
                objectsInRange(shooter.physicsBody!)
            }
        }
    }
    
    func shoot(target: SKNode, shooter: SKNode){
       
        println("\(shooter.name) is shooting a\(target.name)")
        let projectileNode = SKShapeNode(circleOfRadius: 10)
        var projectile = Projectile(damage: 10, size: 10, color: SKColor.redColor())
        projectileNode.fillColor = projectile.color
        projectileNode.position = shooter.position
/*
        projectileNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        projectileNode.physicsBody!.affectedByGravity = false
        projectileNode.physicsBody?.categoryBitMask = ProjectileCategory
        projectileNode.physicsBody?.collisionBitMask = 0
        projectileNode.physicsBody?.contactTestBitMask = WallCategory
        projectileNode.physicsBody?.contactTestBitMask = EnemyCategory
*/
        addChild(projectileNode)
       // println("created projectile")

 
        
        // 3 - Determine offset of location to projectile
        let offset = minus(target.position, second: shooter.position)


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
        /*
        towerNode.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        towerNode.physicsBody!.affectedByGravity = false
        towerNode.physicsBody?.categoryBitMask = TowerCategory
        towerNode.physicsBody?.collisionBitMask = 0
        towerNode.physicsBody?.dynamic = false
        */
        towerNode.position.x = x
        towerNode.position.y = y
        

        addShooter(name, tower: towerNode, withinRange: range, num: (GameScene.shooters.count+1))
        addChild(towerNode)
    }
    
    func addEnemy(name: String, speed: Float, hp: Float, x: CGFloat, y: CGFloat){
        GameScene.enemyCount += 1
        let enemyNode = SKShapeNode(circleOfRadius: 20)
        let num = GameScene.enemyCount
        var enemy = Enemy(num: num, name: name, hp: 100, speed: 50, size: 20, enemy: enemyNode, color: SKColor.orangeColor(), x: x, y: y, path: [Float]())
     //   enemyNode.name = (num.description)
        enemyNode.name = ("jakey")
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
        enemies.append(enemyNode)
        
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
    
    
    func objectsInRange(tower: SKPhysicsBody){
        
        for (object) in tower.allContactedBodies(){
            let body = unsafeBitCast(object, SKPhysicsBody.self)
            println(body.categoryBitMask)

            if (body.node?.physicsBody!.categoryBitMask == EnemyCategory){
                
                enemiesInRange.append(body)
                enemyOrder.append(body.node!.name!.floatValue)
                enemyDistances.append(Float(getDistance(body.node!.position, tower.node!.position)))

            }
        }
        if enemyOrder.count > 0{
            lastEnemyNum = maxElement(enemyOrder)
            firstEnemyNum = minElement(enemyOrder)
            
            firstEnemy = enemiesInRange[Int(firstEnemyNum)].node!
            closestEnemyDistance = minElement(enemyDistances)
            closestEnemy = find(enemyDistances, closestEnemyDistance)!
            
            println("-----------")
            println("Number of Shooters: \(GameScene.shooters.count)")
            println("totalEnemiesInRange: \(enemiesInRange.count)")
            println("enemiesInRange[0] \(enemiesInRange[0].node!.name)")
            println("firstEnemyNum: \(firstEnemyNum)")
            println("firstEnemy: \(firstEnemy.name)")
            println("firstEnemyXCoords \(firstEnemy.position.x)")
            println("firstEnemyYCoords \(firstEnemy.position.y)")
            println("lastEnemy: \(lastEnemyNum)")
            println("closestEnemyDistance: \(closestEnemyDistance)")
            println("closestEnemy: \(closestEnemy)")
        
            if enemiesInRange.count > 0{
               shoot(firstEnemy, shooter: tower.node!)
            
                //shoot(enemies[closestEnemy-1], shooter: tower.node!)
             
            }
        }


    }

    
    var touchCount: Float = 0
    var addTowerCount: Float = 0
    var toAddTower: Bool = false
    var deleteTowerCount: Float = 0
    var toDeleteTower: Bool = false
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent){
        for touch in touches{
            let touch = touches.first as! UITouch
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            touchedNode.position = location
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // let touchCount = touches.count
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(self)

        
        
        touchCount+=1
        addTowerCount = touchCount
        deleteTowerCount = touchCount
      
        let node: SKNode = self.nodeAtPoint(location)
        
        
        
        if (node.name == ("addEnemy") && !toAddTower){
            addEnemy("The Juicer", speed: 5, hp: 100, x: 0, y: 0)
        }
        
        if (node.name == ("addTower")){
            toAddTower = true
            addTowerCount+=1
        }
        
        if (node.name == ("deleteTower")){
            toDeleteTower = true
            deleteTowerCount+=1
        }
        
        if(toAddTower && (touchCount == addTowerCount)){
            addTower("Carl Steepenz", speed: 10, range: 400, x: location.x, y: location.y)
            toAddTower = false
        }
        
        if(toDeleteTower && (touchCount == deleteTowerCount)){
            node.removeFromParent()
            var nodeNum = node.name!.toInt()
            
            println(GameScene.shooters.count)
           // GameScene.shooters.removeAtIndex(nodeNum!)
            toDeleteTower = false
        }
        
        let position = touch.locationInNode(self)
        println("x: \(position.x)y: \(position.y)")
        
        let touchLocation = SKShapeNode(circleOfRadius: 25)
        touchLocation.position = CGPointMake(location.x, location.y)
        
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
          //  shoot( firstNode.node!, shooter: secondNode.node!)
            objectsInRange(secondNode.node!.physicsBody!)
            
        }
        
        if((firstNode.categoryBitMask == EnemyCategory) && (secondNode.categoryBitMask == ProjectileCategory)){
            println("hit!--------------------------------------------")
        }
        
      
        
        if ((firstNode.categoryBitMask == EnemyCategory) && (secondNode.categoryBitMask == ProjectileCategory)) {
            
        }
        
        
        
   //     println("firstNode: \(firstNode.name)")
     //   println("secondNode: \(secondNode.name)")

        }
    
    


}
    //didBeginContact


//GameScene


