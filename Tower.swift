//
//  NewTower.swift
//  JakeyTowerDefense
//
//  Created by Jacob Wall on 10/29/15.
//  Copyright (c) 2015 Jacob Wall. All rights reserved.
//

import Foundation
import SpriteKit

class Tower : SKShapeNode
{
    var number: Int = 0
    var range: CGFloat = 200
    var enemies: [Enemy] = []
    var enemiesInRange: [Enemy] = []
    var enemiesInRangeNums: [Int] = []
    var firstEnemy: Int = 0
    var closestEnemy: Int = 0
    var hasATarget : Bool = true
    
    override init(){
        super.init()
        self.fillColor = SKColor.blueColor()
        
    } // init

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    } // required init
    
    func findEnemiesInRange(enemyDistances: [Int]) -> [Enemy]{
        // input is a an array of Ints from findEnemyDistances()
        //println("findEnemies()")
        enemiesInRange = []
        enemiesInRangeNums = []
        var counter = 0
        for(distance) in enemyDistances{
            if(distance <= Int(range)){
                enemiesInRange.append(enemies[counter])
                enemiesInRangeNums.append(counter)
            }
            counter+=1
        }
        
        if(enemiesInRangeNums.count>0){
            firstEnemy = enemiesInRangeNums.minElement()!+1
        }
        return enemiesInRange
    } // findEnemies
    
    func establishEnemies(enemies:[Enemy]){
      self.enemies = enemies
    }
    
    func findClosestEnemy(enemies: [Enemy]) -> Int{
        establishEnemies(enemies)
        let enemyDistances = findEnemyDistances(enemies)
        closestEnemy = enemyDistances.indexOf(findEnemyDistances(enemies).minElement()!)!
        
                
        return closestEnemy
    } // findClosestEnemy
    
    func findFurthestEnemy(enemies: [Enemy]) -> Int{
        print("findFurthestEnemy()")
        
        return 1
    } // findFurthestEnemy
    
    func findEnemyDistances(enemies: [Enemy]) -> [Int]{
        //println("findEnemyDistances()")
        var enemyDistances: [Int] = []
        
        for (Enemy) in enemies{
            enemyDistances.append(Int(getDistance(self.position, second: Enemy.position)))
        }
        
        return enemyDistances
    } // findEnemyDistances
    
    func shoot(){
        print("shoot()")
    } // shoot
    
    func establishNumber(number: Int){
        self.number = number
    } // establishNumber
    
    func getNumber() -> Int{
        return number
    } // getNumber
    
    func establishRange(range: CGFloat){
        self.range = range
    } // establishRange
    
    func getRange() -> CGFloat{
        return range
    } // getRange
    
    func getDistance(first: CGPoint, second: CGPoint) -> CGFloat{
        return (sqrt((((second.x - first.x)*(second.x - first.x))+((second.y - first.y)*(second.y - first.y)))))
    }
    
    func setHasTarget(hasATarget: Bool){
        self.hasATarget = hasATarget
    }
  
    func hasTarget() -> Bool{
        return hasATarget
    }
    
} // NewTower