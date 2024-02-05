//
//  GameCharacter.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/2/1.
//

import Foundation
import SpriteKit

let groundCategory: UInt32 = 0x1 << 0
let zombieCategory: UInt32 = 0x1 << 1
let peashooterCategory: UInt32 = 0x1 << 2
let peashooterWholeBodyCategory: UInt32 = 0x1 << 3
let bulletCategory: UInt32 = 0x1 << 4
let sunCategory: UInt32 = 0x1 << 5

protocol GameCharacterDelegate: GameNodeDelegate {
    
    func onGameCharacterDie()
    
    func onDefeatedOther()
}

open class GameCharacter : GameNode, GameCharacterDelegate{
    
    func onGameCharacterDie() {
        
    }
    
    func onDefeatedOther() {
        
    }
    
    var attackers: [GameCharacter] = []
    
    func setAttackedBy(who: GameCharacter){
        if !attackers.contains(where: { $0 === who }) {
            attackers.append(who)
        }
    }
}
