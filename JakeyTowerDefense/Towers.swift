//
//  Towers.swift
//  JakeyTowerDefense
//
//  Created by Jacob Wall on 9/18/15.
//  Copyright (c) 2015 Jacob Wall. All rights reserved.
//

import Foundation
import SpriteKit

 class Towers{
    var tower:SKShapeNode
    var strength: Float = 0
    var speed: Float = 0
    var range: CGFloat = 0
    var size: CGFloat = 0
    var color: SKColor
    var name: String = ""
    
    var enemiesInRange: [SKPhysicsBody] = []
    var enemyOrder: [Float] = []
    var enemyDistances: [Float] = []
    var firstEnemy = SKNode()
    var firstEnemyNum: Float = 0
    var lastEnemyNum: Float = 0
    var closestEnemyDistance: Float = 0
    var closestEnemy: Int = 0
    
    init(name: String, speed: Float, range: CGFloat, size: Float, color: SKColor, tower: SKShapeNode, x: CGFloat, y: CGFloat){
        self.name = name
        self.speed = speed
        self.range = range
        self.tower = tower
        self.color = color
    }
 
    func objectsInRange(tower: SKPhysicsBody){
        
        for (object) in tower.allContactedBodies(){
            let body = unsafeBitCast(object, SKPhysicsBody.self)
            println(body.categoryBitMask)
            
          
        }
       
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
                GameScene.shoot(firstEnemy, shooter: tower.node!)
                
                //shoot(enemies[closestEnemy-1], shooter: tower.node!)
                
            }
        

        
    }
    
}//Tower



