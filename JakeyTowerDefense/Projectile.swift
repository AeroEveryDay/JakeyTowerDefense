//
//  Projectile.swift
//  JakeyTowerDefense
//
//  Created by Jacob Wall on 9/26/15.
//  Copyright (c) 2015 Jacob Wall. All rights reserved.
//

import Foundation
import SpriteKit

class Projectile {
    var damage: Float = 0
    var size: Float = 0
    var x: CGFloat
    var y: CGFloat
    var color: SKColor
    
    init(damage: Float, size: Float, x: CGFloat, y: CGFloat, color: SKColor){
        self.x = x
        self.y = y
        self.size = size
        self.damage = damage
        self.color = color
    }
    
    
}