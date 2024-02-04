//
//  MainGameScene.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/31.
//

import Foundation
import SpriteKit
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
    private var zombie: Zombie?
    let background = SKSpriteNode(imageNamed: "background")
    
    private var firstRun = true
    
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
            self.setupZombie()
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

    func setupZombie() {
        zombie = Zombie(scene: self)
        zombie?.onExit = showGameOver
        addChild(zombie!)
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
    
    func showGameOver() {
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
            // 处理 zombie 和 shooter 的碰撞
            if let zombie = contact.bodyA.node as? Zombie ?? contact.bodyB.node as? Zombie,
               let shooter = contact.bodyA.node as? Peashooter ?? contact.bodyB.node as? Peashooter {
                zombie.didCollide(with: shooter)
            }
        case (zombieCategory, bulletCategory),
             (bulletCategory, zombieCategory):
            // 处理 bullet 和 zombie 的碰撞
            if let zombie = contact.bodyA.node as? Zombie ?? contact.bodyB.node as? Zombie,
               let bullet = contact.bodyA.node as? FireBeanBullet ?? contact.bodyB.node as? FireBeanBullet {
                zombie.didCollide(with: bullet)
            }
        case (groundCategory, peashooterCategory),
             (peashooterCategory, groundCategory):
            // 处理 peashooter 落地
            if let peashooter = contact.bodyA.node as? GameNode ?? contact.bodyB.node as? GameNode {
                let ground = contact.bodyA.node as? SKSpriteNode ?? contact.bodyB.node as? SKSpriteNode
                if ground?.name == "ground" {
                    peashooter.didCollide(withGround: ground!)
                }
            }
        default:
            // 处理其他类型的碰撞
            break
        }
    }
    
    func restartGame(){
        if !firstRun {
            // 关闭对话框（如果已经添加到场景中）
            if let dialog = childNode(withName: "pvzDialog") as? PvZDialogNode {
                dialog.removeFromParent()
            }
            // 重置地图缩放
            background.xScale = 1.0
            background.yScale = 1.0
            runBackgroundZoomAnimation {
                self.setupPeashooter()
                self.setupZombie()
                self.zombie!.runZombieWalkAnimation(walkSteps: 50)
            }
        } else {
            self.zombie!.runZombieWalkAnimation(walkSteps: 50)
        }
    }
    
    func peashooterRemoved(peashooter: Peashooter) {
        
    }
}
