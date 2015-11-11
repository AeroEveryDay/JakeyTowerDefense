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
    
    static var enemyCount: Float = 0
    
    
    var towers: [Tower] = []
    var enemies: [Enemy] = []
    var enemiesEver: Int = 0
    var enemiesAlive: [Bool] = []
    
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.whiteColor()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("toShoot"), userInfo: nil, repeats: true)
        
        
        // addTower("Jakey", speed: 10, range: 300, x: frame.width/2, y: 500)
        //addTower("Carl Steepenz", speed: 10, range: 100, x: frame.width/2, y: 600)
        
        addButton("addEnemy", height: 50, width: 100, x: 110, y: 45, color: SKColor.orangeColor())
        addButton("addTower", height: 50, width: 100, x: 660, y: 45, color: SKColor.blueColor())
        addButton("deleteTower", height: 50, width: 100, x: 680, y: 1200, color: SKColor.blueColor())
        
        
        
        // addEnemy("The Juicer", speed: 5, hp: 100, x: 0, y: 0)
        
        addTower(frame.width/2, y: frame.height/2)
        addEnemy(0, y: 0)
        
    }//didMoveToView
    
    
    
    func addTower(x: CGFloat, y: CGFloat){
        let tower = Tower(circleOfRadius: 25)
        tower.position.x = x
        tower.position.y = y
        towers.append(tower)
        tower.establishNumber(towers.count)
        
        //creating range visualization
        let range = SKShapeNode(circleOfRadius: tower.getRange())
        range.fillColor = SKColor.grayColor()
        range.position.x = x
        range.position.y = y
        range.alpha = 0.5
        
        addChild(range)
        addChild(tower)
        
    }
    
    func addEnemy(x: CGFloat, y: CGFloat){
        let enemy = Enemy(circleOfRadius: 20)
        var enemyCount = enemiesAlive.filter{$0}.count
        enemiesEver += 1
        let num = enemyCount
        
        enemy.position.x = x
        enemy.position.y = y
        enemy.physicsBody?.categoryBitMask = EnemyCategory
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.contactTestBitMask = ProjectileCategory
        
        enemies.append(enemy)
        enemiesAlive.append(true)
        enemy.establishNum(num)
        enemy.name = String(num)
        print("Enemy Name after Created \(enemy.name)", terminator: "")
        addChild(enemy)
        Paths(rider: enemy, speed: 20)
    }
    
    func addButton(name: String, height: CGFloat, width: CGFloat, x: CGFloat, y:CGFloat, color: SKColor){
        let button = SKShapeNode(rectOfSize: CGSize(width: width, height: height))
        button.fillColor = color
        button.name = name
        button.position.x = x
        button.position.y = y
        addChild(button)
    }
    
    func toShoot(){
        
        if towers.count > 0{
            for (tower) in towers{
                tower.establishEnemies(enemies)
                let enemyDistances = tower.findEnemyDistances(enemies)
                let enemiesInRange = tower.findEnemiesInRange(enemyDistances)
                
                
                
                
                /* for(Enemy) in enemyDistances{
                println(Enemy)
                }*/
                print("----------------------")
                print("All Enemies:")
                print("Count: \(enemies.count)")
                
                if enemiesInRange.count > 0{
                    for(Enemy) in enemiesInRange{
                        
                        //println("shooting: \(tower.firstEnemy-1)")
                        
                        // shoot(enemiesInRange[tower.firstEnemy-1],tower: tower)
                        print("Closest Enemy: \(tower.findClosestEnemy(enemies))")
                        shoot(enemies[tower.closestEnemy],tower: tower)
                    }
                }
            }
        }
    }
    
    func getEnemies() -> [Enemy]{
        return enemies
    }
    
    
    
    
    
    func shoot(enemy: Enemy, tower: Tower){
        
        //print("Tower \(tower.getNumber()) is shooting at Enemy \(enemy.name)")
        let projectileNode = SKShapeNode(circleOfRadius: 10)
        let projectile = Projectile(damage: 10, size: 10, color: SKColor.redColor())
        projectileNode.fillColor = projectile.color
        projectileNode.position = tower.position
        
        projectileNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        projectileNode.physicsBody!.affectedByGravity = false
        projectileNode.physicsBody?.categoryBitMask = ProjectileCategory
        projectileNode.physicsBody?.collisionBitMask = 0
        projectileNode.physicsBody?.contactTestBitMask = WallCategory
        projectileNode.physicsBody?.contactTestBitMask = EnemyCategory
        
        addChild(projectileNode)
        // println("created projectile")
        
        
        
        // 3 - Determine offset of location to projectile
        let offset = minus(enemy.position, second: tower.position)
        
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + tower.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 0.7)
        let actionMoveDone = SKAction.removeFromParent()
        projectileNode.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        
    }
    
    //  func getTarget(shooter: SKNode) -> SKNode{}
    
    func minus (first: CGPoint, second: CGPoint) -> CGPoint {
        return CGPointMake(first.x - second.x, first.y - second.y)
    }//minus
    
    func projectileDidCollide(projectile: SKShapeNode, object: SKShapeNode){
        print("Projectile Hit: \(projectile.name) !")
        projectile.removeFromParent()
        //object.strokeColor = SKColor.redColor()
    }
    
    var touchCount: Float = 0
    var addTowerCount: Float = 0
    var toAddTower: Bool = false
    var deleteTowerCount: Float = 0
    var toDeleteTower: Bool = false
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?){
        for touch in touches{
            let touch = touches.first
            let location = touch!.locationInView(view)
            let touchedNode = nodeAtPoint(location)
            touchedNode.position = location
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // let touchCount = touches.count
        let touch = touches.first
        let location = touch!.locationInNode(self)
        
        
        
        touchCount+=1
        addTowerCount = touchCount
        deleteTowerCount = touchCount
        
        let node: SKNode = self.nodeAtPoint(location)
        
        print(node.name)
        
        if (node.name == ("addEnemy") && !toAddTower){
            addEnemy(0, y: 0)
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
            addTower(location.x, y: location.y)
            toAddTower = false
        }
        
        if(toDeleteTower && (touchCount == deleteTowerCount)){
            node.removeFromParent()
            
            toDeleteTower = false
        }
        
        /* printing location of touch
        
        let position = touch.locationInNode(self)
        println("x: \(position.x)y: \(position.y)")
        
        */
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
        
        
        if((firstNode.categoryBitMask == EnemyCategory) && (secondNode.categoryBitMask == ProjectileCategory)){
            // print("hit!--------------------------------------------")
            //   print(firstNode.node?.name, terminator: "")
            firstNode.node?.removeFromParent()
            secondNode.node?.removeFromParent()
            //print("Deleting: \((firstNode.node?.name)!.toInt()!)")
            print("Deleting: \((Int((firstNode.node?.name)!)!)-(enemiesEver-(enemies.count)))")
            
            enemies.removeAtIndex((Int((firstNode.node?.name)!)!)-(enemiesEver-(enemies.count)))
          
           // enemiesAlive[(Int((firstNode.node?.name)!)!)-(enemiesEver-(enemies.count))] = false
            
            print("Setting enemiesAlive[\((Int((firstNode.node?.name)!)!)-(enemiesEver-(enemies.count))+1)] = false")
            /*
            when 4 and 5 are left
            
            total ever = 5
            
            enemy num  4
            -
            ( total ever 5
            -
            total enemies left) 2
            */
        }
        
        
        //     println("firstNode: \(firstNode.name)")
        //   println("secondNode: \(secondNode.name)")
        
    }
    
    
    
    
}
//didBeginContact


//GameScene


