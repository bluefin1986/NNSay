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
    static let headName = "PeashooterHead"
    var detectionTimer: Timer?
    var ammoCount: Int = 0 // 假设初始载弹量为10
    // 已落地
    var onGround = false
    var headPhysicsBodyCreated = false
    var topPart:SKSpriteNode?

    init(scene: SKScene) {
        guard let peashooterFrames = textures(fromGifNamed: "pea-shooter"),
              let firstFrame = peashooterFrames.first else {
            fatalError("无法加载pea-shooter动画帧或pea-shooter动画帧为空")
        }
        super.init(texture: firstFrame, color: .clear, size: firstFrame.size())
        self.name = Peashooter.className
        self.texture = peashooterFrames[0]
        self.position = CGPoint(x: 280, y: scene.size.height - 100) // Start off-screen
        self.size = CGSize(width: 100, height: 100)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width / 2, height: self.size.height))
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = peashooterWholeBodyCategory
        self.physicsBody?.collisionBitMask = groundCategory
        self.physicsBody?.contactTestBitMask = groundCategory
        self.physicsBody?.restitution = 0
        self.run(SKAction.repeatForever(SKAction.animate(with: peashooterFrames, timePerFrame: 0.1)))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didCollide(with other: GameNode, completion: (() -> Void)? = nil) {
        if other.name == Zombie.className {
            // 启动计时器，5秒后执行消失逻辑
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                // 确保 Peashooter 还在场景中
                guard self.parent != nil else {
                    return
                }

                // Peashooter 消失逻辑
                self.onGameCharacterDie()
            }
        }
    }
    
    override func didCollide(withGround ground: SKSpriteNode) {
        onGround = true
        setupPeashooterHead()
    }
    
    func setupPeashooterHead() {
        if headPhysicsBodyCreated {
            return
        }
        topPart = SKSpriteNode(color: .clear, size: CGSize(width: self.size.width / 2, height: self.size.height / 2))
        topPart?.position = CGPoint(x: 0, y: self.size.height / 4) // 调整位置到上半部分
        topPart?.physicsBody = SKPhysicsBody(rectangleOf: topPart!.size)
        topPart?.physicsBody?.isDynamic = false
        topPart?.physicsBody?.affectedByGravity = false // 不受重力影响
        topPart?.physicsBody?.allowsRotation = false
        topPart?.physicsBody?.categoryBitMask = peashooterCategory // 为上半部分设置一个独特的类别掩码
        topPart?.physicsBody?.contactTestBitMask = sunCategory | zombieCategory // 设置为与太阳发生接触的掩码
        topPart?.physicsBody?.collisionBitMask = sunCategory | zombieCategory // 设置为与太阳发生接触的掩码
        topPart?.name = Peashooter.headName // 可选，为了识别
        self.addChild(topPart!)
        headPhysicsBodyCreated = true
    }
    
    func checkForZombiesAndFire() {
        guard let scene = self.scene else { return }
        
        scene.enumerateChildNodes(withName: Zombie.className) { node, _ in
            let zombie = node as! Zombie
            if self.ammoCount > 0 && self.onGround && zombie.currentState != .died{
                self.fireBullet()
            }
        }
    }
    
    func fireBullet() {
        guard ammoCount > 0 else { return } // 确保有弹药
        
        ammoCount -= 1 // 发射子弹时减少弹药数量
        // 创建子弹
        let bullet = FireBeanBullet(scene: self.scene!, shooter: self)
        self.scene?.addChild(bullet) // 将子弹添加到场景中
        // 发射子弹
        let moveAction = SKAction.moveBy(x: (self.scene?.size.width)! + bullet.size.width, y: 0, duration: 2) // 向前移动
//        let removeAction = SKAction.removeFromParent() // 移动完成后移除子弹
//        bullet.run(SKAction.sequence([moveAction, removeAction]))
        bullet.run(moveAction)
        
    }
    
    
    override func onGameCharacterDie() {
        self.removeFromParent()
        for attacker in attackers {
            attacker.onDefeatedOther()
        }
    }
    
    override func onDefeatedOther() {
        
    }
    
    func setupTimerForZombieDetection() {
        detectionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkForZombiesAndFire()
        }
    }
    
    func invalidateTimer() {
        detectionTimer?.invalidate()
        detectionTimer = nil
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        topPart?.physicsBody = nil
        topPart?.removeFromParent()
        invalidateTimer() // 当 Peashooter 被移除时停止定时器
    }
}
