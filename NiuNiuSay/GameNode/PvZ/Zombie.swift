//
//  Zombie.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/2/1.
//

import Foundation
import SpriteKit

enum ZombieState {
    case walking
    case attacking
    case died
}

class Zombie: GameCharacter{
    static let className = "Zombie"
    var currentState: ZombieState = .walking
    
    var onExit : (() -> Void)?

    init(scene: SKScene) {
        guard let zombieFrames = textures(fromGifNamed: "Zombie"),
              let firstFrame = zombieFrames.first else {
            fatalError("无法加载zombie动画帧或zombie动画帧为空")
        }
        super.init(texture: firstFrame, color: .clear, size: firstFrame.size())
        self.position = CGPoint(x: scene.size.width + 100, y: scene.size.height / 2)
        self.name = Zombie.className
        self.texture = zombieFrames[0]
        self.size = zombieFrames[0].size()
        
        let offsetX = 20.0 // 根据需要调整偏移量,僵尸图左侧有一些空白部分
        let size = CGSize(width: 62, height: 128)
        let path = CGMutablePath()
        path.addRect(CGRect(x: -size.width / 2 + offsetX, y: -size.height / 2, width: size.width, height: size.height))
        self.physicsBody = SKPhysicsBody(polygonFrom: path)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.restitution = 0
        self.physicsBody?.categoryBitMask = zombieCategory
        self.physicsBody?.collisionBitMask = peashooterCategory | groundCategory | bulletCategory
        self.physicsBody?.contactTestBitMask = peashooterCategory | bulletCategory
//        self.physicsBody?.linearDamping = 5.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func runZombieWalkAnimation(walkSteps: CGFloat) {
        guard let zombieWalkFrames = textures(fromGifNamed: "Zombie"), !zombieWalkFrames.isEmpty else {
            print("无法加载僵尸动画帧")
            return
        }

        let walkAnimation = SKAction.animate(with: zombieWalkFrames, timePerFrame: 0.1)
        self.run(SKAction.repeatForever(walkAnimation))

        let moveAction = SKAction.moveTo(x: -self.size.width, duration: Double(self.position.x / walkSteps))
        self.run(moveAction, completion: {
            self.removeFromParent()
            self.onExit?()
        })
    }
    
    func attack() {
        guard let zombieAttackFrames = textures(fromGifNamed: "ZombieAttack"), !zombieAttackFrames.isEmpty else {
            print("无法加载僵尸攻击动画帧")
            return
        }

        let attackAnimation = SKAction.animate(with: zombieAttackFrames, timePerFrame: 0.1)
        let repeatAttack = SKAction.repeatForever(attackAnimation)

        self.run(repeatAttack, withKey: "attacking")
    }
    
    func stopAttack() {
        self.removeAction(forKey: "attacking") // 停止攻击动画
        runZombieWalkAnimation(walkSteps: 30.0) // 恢复行走动画
    }
    
    override func didCollide(with other: GameNode) {
        
        if other.name == Peashooter.className {
            // 检查当前状态，避免重复触发攻击动画
            guard currentState != .attacking else { return }
            self.physicsBody?.velocity = CGVector.zero
            self.physicsBody?.angularVelocity = 0
            
            // 停止所有当前动画，切换到攻击状态
            self.removeAllActions()
            currentState = .attacking
            attack()
            // 强转为gameCharacter类型
            if let gameCharacter = other as? GameCharacter {
                gameCharacter.setAttackedBy(who: self)
            }
        } else if other.name == FireBeanBullet.className{
            // 如果other没有creator但是other是GameCharacter类型
            if let gameCharacter = other as? GameCharacter {
                // 直接调用other的onDefeatedOther方法
                gameCharacter.onDefeatedOther()
            }
            onGameCharacterDie()
        }
    }
    
    override func onGameCharacterDie() {
        guard let zombieBoomDieFrames = textures(fromGifNamed: "ZombieBoomDie"), !zombieBoomDieFrames.isEmpty else {
            print("无法加载僵尸死亡动画帧")
            return
        }
        self.currentState = .died
        removeAllActions() //移除全部动画
        self.physicsBody = nil //移除物理体，避免继续碰撞
        let boomDieAnimation = SKAction.animate(with: zombieBoomDieFrames, timePerFrame: 0.1)
        
        // 创建等待动作
        let waitAction = SKAction.wait(forDuration: 0.5)
        
        // 创建一个块（block）动作来移除节点
        let removeAction = SKAction.run { [weak self] in
            self?.removeFromParent()
        }
        
        // 将动画、等待和移除动作组合成一个序列
        let sequence = SKAction.sequence([boomDieAnimation, waitAction, removeAction])
        
        // 执行序列动作
        self.run(sequence, withKey: "boomDie")
    }
    
    override func onDefeatedOther() {
        stopAttack()
    }

}
