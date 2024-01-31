//
//  DialogTestScene.swift
//  NiuNiuSayTests
//
//  Created by 郑敏嘉 on 2024/1/31.
//

import Foundation
import SpriteKit

class DialogTestScene: SKScene {
    
    override func didMove(to view: SKView) {
        // 背景设置（可选）
        backgroundColor = SKColor.white

        // 创建并显示对话框
        let dialog = PvZDialogNode(size: CGSize(width: 318, height: 248), scale: 1.2)
        dialog.setText("你失败了\n没关系,重来一次吧", fontName: "gongfanwanshihei", fontSize: 24)
        dialog.setPosition(x: self.frame.midX, y: self.frame.midY)
        addChild(dialog)

        // 创建重新开始按钮（如果需要）
        let restartButton = SKSpriteNode(color: SKColor.clear, size: CGSize(width: 100, height: 50))
        restartButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 150)
        restartButton.name = "restartButton"
        addChild(restartButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 处理点击事件，比如点击重新开始按钮
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)

        if touchedNode.name == "restartButton" {
            // 处理重新开始按钮的点击
        }
    }
}
