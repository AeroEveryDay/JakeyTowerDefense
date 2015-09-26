//
//  Enemy.swift
//  JakeyTowerDefense
//
//  Created by Jacob Wall on 9/24/15.
//  Copyright (c) 2015 Jacob Wall. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy{
    var name: String
    var hp: Float = 0
    var color: SKColor
    var speed: Float = 0
    var size: CGFloat = 0
    var path: [Float]
    
    init(name: String, hp: Float, speed: Float, size: CGFloat, enemy: SKShapeNode, color: SKColor, x: CGFloat, y: CGFloat, path: [Float]){
        self.hp = hp
        self.name = name
        self.color = color
        self.speed = speed
        self.size = size
        self.path = path
    }
    
    func addEnemy(Name: String, enemy: Enemy){
        let Name = SKShapeNode(circleOfRadius: size)
        Name.strokeColor = SKColor.redColor()
        
    }
    
 
    

    
}