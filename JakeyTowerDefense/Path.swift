//
//  Path.swift
//  JakeyTowerDefense
//
//  Created by Jacob Wall on 9/26/15.
//  Copyright (c) 2015 Jacob Wall. All rights reserved.
//

import Foundation
import SpriteKit



class Paths {
    
    
    init(rider: SKShapeNode, speed: Double){
        
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 20, 760)
        CGPathAddLineToPoint(path, nil, 400, 600)
        CGPathAddLineToPoint(path, nil, 340, 420)
        CGPathAddLineToPoint(path, nil, 80, 366)
        CGPathAddLineToPoint(path, nil, 86, 70)
        CGPathAddLineToPoint(path, nil, 350, 60)
        // CGPathAddArcToPoint(path, nil, <#x1: CGFloat#>, <#y1: CGFloat#>, <#x2: CGFloat#>, <#y2: CGFloat#>, <#radius: CGFloat#>)
        
        let action: SKAction = SKAction.runBlock({
            GameScene.enemyCount -= 1
           // GameScene.enemies
        })
        
       //execute path
        let followLine = SKAction.followPath(path, asOffset: true, orientToPath: false, duration: speed)
        let followLineDone = SKAction.removeFromParent()
          rider.runAction(SKAction.sequence([followLine, followLineDone, action]))

        
        
       
    }
    
    
    
}
