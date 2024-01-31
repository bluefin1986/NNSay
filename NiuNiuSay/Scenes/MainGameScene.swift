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

class MainGameScene: SKScene {
    let peashooter = SKSpriteNode()
    let zombie = SKSpriteNode()
    let background = SKSpriteNode(imageNamed: "background")
    var hasSetup = false

    override func didMove(to view: SKView) {
        restartGame()
    }
    
    func setupBackground() {
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        let aspectRatio = background.size.height / background.size.width
        background.size = CGSize(width: size.width, height: size.width * aspectRatio)
        addChild(background)
    }

    func setupPeashooter() {
        if let peashooterFrames = textures(fromGifNamed: "pea-shooter"), !peashooterFrames.isEmpty {
            peashooter.texture = peashooterFrames[0]
            peashooter.position = CGPoint(x: 280, y: size.height + 100) // Start off-screen
            peashooter.size = CGSize(width: 100, height: 100)
            peashooter.run(SKAction.repeatForever(SKAction.animate(with: peashooterFrames, timePerFrame: 0.1)))
            addChild(peashooter)
        }
    }

    func setupZombie() {
        zombie.position = CGPoint(x: size.width + 100, y: size.height / 2) // Start off-screen
        if let zombieWalkFrames = textures(fromGifNamed: "Zombie"), !zombieWalkFrames.isEmpty {
            zombie.texture = zombieWalkFrames[0]
            zombie.size = zombieWalkFrames[0].size()
            addChild(zombie)
        }
    }

    func runBackgroundZoomAnimation(completion: @escaping () -> Void) {
        let zoomAction = SKAction.scale(to: 1.3, duration: 2.0)
        background.run(zoomAction) {
            completion()
        }
    }

    func runPeashooterDropAnimation(completion: @escaping () -> Void) {
        let dropAction = SKAction.moveTo(y: size.height / 2, duration: 1.0)
        peashooter.run(dropAction) {
            completion()
        }
    }

    func runPeashooterSmokeEffect() {
        // 创建烟雾效果
//         let smokeEffect = SKEmitterNode(fileNamed: "SmokeEffect")
//         peashooter.addChild(smokeEffect)
    }

    func runZombieWalkAnimation() {
        guard let zombieWalkFrames = textures(fromGifNamed: "Zombie"),
              !zombieWalkFrames.isEmpty,
              let zombieAttackFrames = textures(fromGifNamed: "ZombieAttack"),
              !zombieAttackFrames.isEmpty else {
            print("无法加载僵尸动画帧")
            return
        }
        let walkAnimation = SKAction.animate(with: zombieWalkFrames, timePerFrame: 0.1)
        zombie.run(SKAction.repeatForever(walkAnimation))

        let distanceToPeashooter = zombie.position.x - peashooter.position.x - 10
        let moveAction = SKAction.moveBy(x: -distanceToPeashooter, y: 0, duration: Double(distanceToPeashooter) / 60.0)
        let switchToAttackAnimation = SKAction.run {
            let attackAnimation = SKAction.animate(with: zombieAttackFrames, timePerFrame: 0.1)
            self.zombie.run(SKAction.repeatForever(attackAnimation))
        }
        let sequence = SKAction.sequence([
            moveAction,
            switchToAttackAnimation,
            SKAction.wait(forDuration: 5.0), // 僵尸攻击豌豆射手持续 5 秒
            SKAction.run {
                self.peashooter.removeFromParent() // 移除豌豆射手
                self.runZombieExitAnimation() // 让僵尸继续走动
            }
        ])
        zombie.run(sequence)
    }
    
    func runZombieExitAnimation() {
        let exitAction = SKAction.moveTo(x: -zombie.size.width, duration: 5.0) // 调整持续时间以控制僵尸离开屏幕的速度
        let endSequence = SKAction.sequence([
            exitAction,
            SKAction.run {
                self.showGameOver() // 显示游戏结束画面
            }
        ])
        zombie.run(endSequence)
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
    
    func reset(){
        // 关闭对话框（如果已经添加到场景中）
        if let dialog = childNode(withName: "pvzDialog") as? PvZDialogNode {
            dialog.removeFromParent()
        }
        // 重置地图缩放
        background.xScale = 1.0
        background.yScale = 1.0

        setupPeashooter()

        // 重置僵尸位置
        zombie.position = CGPoint(x: size.width + 100, y: size.height / 2) // Start off-screen
    }
    
    func restartGame(){
        if !hasSetup {
            setupBackground()
            setupPeashooter()
            setupZombie()
            hasSetup = true
        } else {
            reset()
        }
        
        runBackgroundZoomAnimation {
            self.runPeashooterDropAnimation {
                self.runPeashooterSmokeEffect()
                self.runZombieWalkAnimation()
            }
        }
    }
}
