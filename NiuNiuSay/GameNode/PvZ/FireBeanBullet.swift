//
//  FireBeanBullet.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/2/4.
//

import Foundation
import SpriteKit

class FireBeanBullet: GameCharacter {
    
    static let className = "FireBeanBullet"
    
    let shooter: GameCharacter?
    
    init(scene: SKScene, shooter: Peashooter) {
        guard let fireBeanFrames = textures(fromGifNamed: "FireBean"),
              let firstFrame = fireBeanFrames.first else {
            fatalError("无法加载fireBean动画帧或fireBean动画帧为空")
        }
        self.shooter = shooter
        super.init(creator: shooter, texture: firstFrame, color: .clear, size: firstFrame.size())
        self.position = CGPoint(x: shooter.position.x + 30, y: shooter.position.y + 25) // 设置初始位置为 Peashooter 的位置
        self.size = CGSize(width: 56, height: 34)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = bulletCategory
        self.physicsBody?.collisionBitMask = zombieCategory
        self.physicsBody?.contactTestBitMask = zombieCategory
        self.name = FireBeanBullet.className
        self.run(SKAction.repeatForever(SKAction.animate(with: fireBeanFrames, timePerFrame: 0.1)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func onDefeatedOther() {
        removeFromParent()
        shooter?.onDefeatedOther()
    }
}
