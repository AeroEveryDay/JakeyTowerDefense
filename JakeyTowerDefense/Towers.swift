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
    var range: Float = 0
    var size: CGFloat = 0
    var color: SKColor
    var name: String = ""
    
    init(name: String, speed: Float, range: Float, size: Float, color: SKColor, tower: SKShapeNode, x: CGFloat, y: CGFloat){
        self.name = name
        self.speed = speed
        self.range = range
        self.tower = tower
        self.color = color
    }
 
}//Tower



