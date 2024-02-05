//
//  MainGameScene.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/31.
//

import Foundation
import SpriteKit
import SwiftUI
import ImageIO

func textures(fromGifNamed name: String) -> [SKTexture]? {
    guard let path = Bundle.main.path(forResource: name, ofType: "gif") else {
        print("无法找到 GIF 文件路径")
        return nil
    }
    guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil) else {
        print("无法从路径创建 CGImageSource")
        return nil
    }

    var textures: [SKTexture] = []

    let count = CGImageSourceGetCount(source)
    for i in 0..<count {
        if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
            let texture = SKTexture(cgImage: cgImage)
            textures.append(texture)
        }
    }
    return textures
}

class MainGameScene: SKScene, SKPhysicsContactDelegate {
    private var peashooter: Peashooter?
    let background = SKSpriteNode(imageNamed: "background")
    private var zombieSpawnTimer: Timer?
    private var releasedZombies:[Zombie] = [] //已生成的僵尸数组
    private var releasedZombiesCount: Int = 0 //已生成的僵尸数量
    var taskStore: TaskStore?
    
    private var firstRun = true
    
    func setTaskStore(taskStore: TaskStore){
        self.taskStore = taskStore
    }
    
    override init(size: CGSize){
        super.init(size: size)
        setupBackground()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.runBackgroundZoomAnimation(){
            // 调试用，显示物理边框的
            view.showsPhysics = true
            
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
            let ground = SKSpriteNode(color: .clear, size: CGSize(width: self.size.width + 300, height: 2))
            ground.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 100)
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.isDynamic = false // 使其不受重力影响
            ground.physicsBody?.categoryBitMask = groundCategory
            ground.physicsBody?.collisionBitMask = zombieCategory | bulletCategory
            ground.name = "ground"
            self.addChild(ground)
            self.setupPeashooter()
            let zombie = self.setupZombie()
            zombie.runZombieWalkAnimation(walkSteps: 50)
//            self.startZombieSpawnTimer()
            self.restartGame()
            self.firstRun = false
        }
    }
    
    func setupBackground() {
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        let aspectRatio = background.size.height / background.size.width
        background.size = CGSize(width: size.width, height: size.width * aspectRatio)
        addChild(background)
    }

    func setupPeashooter() {
        peashooter = Peashooter(scene: self)
        if peashooter == nil {
            return
        }
        addChild(peashooter!)
        peashooter!.setupTimerForZombieDetection()
    }
    
    func startZombieSpawnTimer() {
        zombieSpawnTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            if self!.taskStore == nil {
                return
            }
            if self!.releasedZombiesCount < self!.taskStore!.totalTaskCount {
                let zombie = self?.setupZombie()
                if zombie == nil {
                    return
                }
                zombie!.runZombieWalkAnimation(walkSteps: 50)
                
            } else {
                self!.zombieSpawnTimer?.invalidate()
            }
        }
    }
    
    func setupZombie() -> Zombie{
        let zombie = Zombie(scene: self)
        zombie.onExit = showGameOver
        zombie.afterDeath = { [weak self] in
            DispatchQueue.main.async {
                self?.taskStore?.correctCount += 1
            }
        }
        self.releasedZombies.append(zombie)
        self.releasedZombiesCount += 1
        addChild(zombie)
        return zombie
    }

    func runBackgroundZoomAnimation(completion: @escaping () -> Void) {
        let zoomAction = SKAction.scale(to: 1.3, duration: 2.0)
        background.run(zoomAction) {
            completion()
        }
    }

    func runPeashooterSmokeEffect() {
        // 创建烟雾效果
//         let smokeEffect = SKEmitterNode(fileNamed: "SmokeEffect")
//         peashooter.addChild(smokeEffect)
    }
    
    private var dialogShown = false
    func showGameOver() {
        if dialogShown {
            return
        }
        // 创建并显示对话框
        let dialog = PvZDialogNode(size: CGSize(width: 318, height: 248), scale: 1.2)
        dialog.setText("你失败了\n没关系,重来一次吧", fontName: "gongfanwanshihei", fontSize: 24)
        dialog.setPosition(x: self.frame.midX, y: self.frame.midY)
        dialog.setButtonText("重新开始", fontName: "gongfanwanshihei", fontSize: 18)
        // 设置按钮点击处理
        dialog.setButtonAction {
            self.restartGame()
        }
        dialog.name = "pvzDialog"
        addChild(dialog)
        zombieSpawnTimer?.invalidate()
        dialogShown = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let touchedNode = atPoint(touchLocation)

        if touchedNode.name == "pvzDialogButton" {
            // 重新开始游戏
            (touchedNode.parent as? PvZDialogNode)?.onButtonPressed?()
        } else if touchedNode.name == "pvzDialogButtonText" {
            // 重新开始游戏
            (touchedNode.parent?.parent as? PvZDialogNode)?.onButtonPressed?()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let categoryBitMasks = (contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask)
        print("Collision detected: \(contact.bodyA.categoryBitMask) with \(contact.bodyB.categoryBitMask)")
            
        switch categoryBitMasks {
        case (zombieCategory, peashooterCategory),
             (peashooterCategory, zombieCategory):
            let nodeA = contact.bodyA.node
            let nodeB = contact.bodyB.node
            // 处理 zombie 和 shooter 的碰撞
            let shooterHeadNode:SKSpriteNode?
            if nodeA?.name == Peashooter.headName {
                shooterHeadNode = nodeA as? SKSpriteNode
            } else if nodeB?.name == Peashooter.headName {
                shooterHeadNode = nodeB as? SKSpriteNode
            } else {
                shooterHeadNode = nil
            }
            if let zombie = contact.bodyA.node as? Zombie ?? contact.bodyB.node as? Zombie{
                if Peashooter.headName == shooterHeadNode?.name {
                    let shooter = shooterHeadNode?.parent as! Peashooter
                    zombie.didCollide(with: shooter)
                    shooter.didCollide(with: zombie)
                }
            }
        case (zombieCategory, bulletCategory),
             (bulletCategory, zombieCategory):
            // 处理 bullet 和 zombie 的碰撞
            if let zombie = contact.bodyA.node as? Zombie ?? contact.bodyB.node as? Zombie,
               let bullet = contact.bodyA.node as? FireBeanBullet ?? contact.bodyB.node as? FireBeanBullet {
                zombie.didCollide(with: bullet) {
                    if self.taskStore?.taskFinished() == true{
                        print("恭喜通关！！！")
                    }
                }
            }
        case (groundCategory, peashooterWholeBodyCategory),
             (peashooterWholeBodyCategory, groundCategory):
            // 处理 peashooter 落地
            if let peashooter = contact.bodyA.node as? GameNode ?? contact.bodyB.node as? GameNode {
                let ground = contact.bodyA.node as? SKSpriteNode ?? contact.bodyB.node as? SKSpriteNode
                if ground?.name == "ground" {
                    peashooter.didCollide(withGround: ground!)
                }
            }
        case (sunCategory, peashooterCategory),
            (peashooterCategory, sunCategory):
            let nodeA = contact.bodyA.node
            let nodeB = contact.bodyB.node
            
            // 确定哪个节点是sun
            let sunNode: SKSpriteNode?
            if nodeA?.name == "sun" {
                sunNode = nodeA as? SKSpriteNode
            } else if nodeB?.name == "sun" {
                sunNode = nodeB as? SKSpriteNode
            } else {
                sunNode = nil
            }
            self.peashooter?.ammoCount += 1
            print("Peashooter 现在有子弹：\(String(describing: self.peashooter?.ammoCount)) 发")
            sunNode?.physicsBody = nil
            sunNode?.removeFromParent() // 移除小太阳节点
        default:
            // 处理其他类型的碰撞
            break
        }
    }
    
    func restartGame(){
        if !firstRun {
            // 关闭对话框（如果已经添加到场景中）
            if let dialog = childNode(withName: "pvzDialog") as? PvZDialogNode {
                for zombie in releasedZombies{
                    zombie.physicsBody = nil
                    zombie.removeFromParent()
                }
                releasedZombies.removeAll()
                self.releasedZombiesCount = 0
                dialog.removeFromParent()
                dialogShown = false
                taskStore?.currentIndex = 0
                peashooter?.removeFromParent()
            }
            // 重置地图缩放
            background.xScale = 1.0
            background.yScale = 1.0
            runBackgroundZoomAnimation {
                self.setupPeashooter()
                self.startZombieSpawnTimer()
//                self.setupZombie()
//                self.zombie!.runZombieWalkAnimation(walkSteps: 50)
            }
        } else {
//            self.zombie!.runZombieWalkAnimation(walkSteps: 50)
            self.startZombieSpawnTimer()
        }
    }
    
    public func addAmmoToPeashooter(){
        // 1. 创建小太阳节点
        guard let sunFrames = textures(fromGifNamed: "Sun"),
            let firstFrame = sunFrames.first else {
                fatalError("无法加载sun动画帧或sun动画帧为空")
            }
        let sun = SKSpriteNode(texture: firstFrame, color: UIColor.clear, size: firstFrame.size())
        let startX = CGFloat.random(in: 100...500) // 屏幕底部随机位置
        let startY = CGFloat(0) // 屏幕底部
        sun.position = CGPoint(x: startX, y: startY)
        sun.name = "sun"
        // 为太阳添加物理体
        sun.physicsBody = SKPhysicsBody(circleOfRadius: sun.size.width / 10)
        sun.physicsBody?.affectedByGravity = true // 受重力影响
        sun.physicsBody?.isDynamic = true
        sun.physicsBody?.categoryBitMask = sunCategory // 自定义的太阳类别掩码
        sun.physicsBody?.collisionBitMask = peashooterCategory // 定义可以与之碰撞的物体
        sun.physicsBody?.contactTestBitMask = peashooterCategory // 定义接触测试掩码以检测与豌豆射手的接触

        self.addChild(sun)
        
        // 给太阳一个初始推力，以模拟抛物线运动
        let dx = (peashooter?.position.x ?? self.size.width / 2) - startX
        let dy = (peashooter?.position.y ?? self.size.height / 2)
        let impulse = CGVector(dx: dx * 0.01, dy: dy * 0.02) // 你可能需要调整这些值以获得理想的抛物线
        sun.physicsBody?.applyImpulse(impulse)
    }
}
