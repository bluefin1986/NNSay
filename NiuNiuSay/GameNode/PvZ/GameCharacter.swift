//
//  GameCharacter.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/2/1.
//

import Foundation
import SpriteKit

let zombieCategory: UInt32 = 0x1 << 0
let peashooterCategory: UInt32 = 0x1 << 1

protocol GameCharacterDelegate: AnyObject {
    func didCollide(with other: GameCharacter)
    
    func onGameCharacterDie()
    
    func onDefeatedOther()
}

open class GameCharacter : SKSpriteNode, GameCharacterDelegate{
    func didCollide(with other: GameCharacter) {
        
    }
    
    func onGameCharacterDie() {
        
    }
    
    func onDefeatedOther() {
        
    }
    
    var attacker: GameCharacter?
    
    func setAttackedBy(who: GameCharacter){
        self.attacker = who
    }
}
