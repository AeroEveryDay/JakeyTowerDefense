//
//  NewEnemy.swift
//  JakeyTowerDefense
//
//  Created by Jacob Wall on 10/29/15.
//  Copyright (c) 2015 Jacob Wall. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy : SKShapeNode{
    
    var hp: Int = 100
    var num: Int = 0
    
    override init(){
        super.init()
        self.fillColor = SKColor.orangeColor()
        self.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = 0
      
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getHp() -> Int{
        return hp
    }
    
    func establishHp(hp: Int){
        self.hp = hp
    }
    
    func getNum() -> Int{
        return num
    }
    
    func establishNum(num: Int){
        self.num = num
    }
}