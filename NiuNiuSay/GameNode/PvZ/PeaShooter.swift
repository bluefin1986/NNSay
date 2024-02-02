//
//  PeaShooter.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/2/1.
//

import Foundation
import SpriteKit


class Peashooter: GameCharacter {
    
    static let className = "Peashooter"

    init(scene: SKScene) {
        guard let peashooterFrames = textures(fromGifNamed: "pea-shooter"),
              let firstFrame = peashooterFrames.first else {
            fatalError("无法加载pea-shooter动画帧或pea-shooter动画帧为空")
        }
        super.init(texture: firstFrame, color: .clear, size: firstFrame.size())
        self.name = Peashooter.className
        self.texture = peashooterFrames[0]
        self.position = CGPoint(x: 280, y: scene.size.height + 100) // Start off-screen
        self.size = CGSize(width: 100, height: 100)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width / 2, height: self.size.height))
        self.physicsBody?.affectedByGravity = true
//        self.physicsBody?.isDynamic = false // 使其不受重力影响
//        self.physicsBody?.linearDamping = 5.0
        self.physicsBody?.categoryBitMask = peashooterCategory
        self.physicsBody?.collisionBitMask = zombieCategory
        self.physicsBody?.contactTestBitMask = zombieCategory
        self.physicsBody?.restitution = 0
        self.run(SKAction.repeatForever(SKAction.animate(with: peashooterFrames, timePerFrame: 0.1)))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didCollide(with other: GameCharacter) {
        if other.name == Zombie.className {
            // 启动计时器，5秒后执行消失逻辑
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                // 确保 Peashooter 还在场景中
                guard self.parent != nil else { return }

                // Peashooter 消失逻辑
                self.onGameCharacterDie()
            }
        }
    }
    
    override func onGameCharacterDie() {
        self.removeFromParent()
        attacker?.onDefeatedOther()
    }
    
    override func onDefeatedOther() {
        
    }
}
