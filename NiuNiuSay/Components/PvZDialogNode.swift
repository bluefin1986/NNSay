//
//  PvZDialog.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/31.
//

import Foundation
import SpriteKit

class PvZDialogNode: SKNode {
    
    let backgroundNode: SKSpriteNode
    let button: SKSpriteNode
    let buttonText: SKLabelNode
    var onButtonPressed: (() -> Void)?

    init(size: CGSize, scale: CGFloat = 1.0) {
        // 创建背景节点
        backgroundNode = SKSpriteNode(imageNamed: "PvZDialog")
        backgroundNode.size = CGSize(width: size.width * scale, height: size.height * scale)

        // 设置 centerRect 以适应九宫格
        let texture = backgroundNode.texture!
//        let centerRectWidth = 1.0 / texture.size().width
//        let centerRectHeight = 1.0 / texture.size().height
        let centerRectWidth = 15.0 / texture.size().width // 根据实际图像调整
        let centerRectHeight = 15.0 / texture.size().height // 根据实际图像调整
        backgroundNode.centerRect = CGRect(x: centerRectWidth, y: centerRectHeight, 
                                        width: 1 - 2 * centerRectWidth,
                                        height: 1 - 2 * centerRectHeight)
        
        // 创建按钮
        button = SKSpriteNode(color: SKColor.clear, size: CGSize(width: 113, height: 41))
        button.position = CGPoint(x: 0, y: -size.height / 3 - 20) // 调整按钮位置
        button.name = "pvzDialogButton" // 设置节点名称以便识别
        button.texture = SKTexture(imageNamed: "PvZButton")
        
        buttonText = SKLabelNode(text:"button")
        buttonText.name = "pvzDialogButtonText"
        super.init()
        
        // 添加背景和文本到对话框节点
        addChild(backgroundNode)
        button.addChild(buttonText)
        addChild(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ text: String, fontName: String = "Arial", fontSize: CGFloat = 24) {
        // 创建文本节点
        let textNode = SKLabelNode(fontNamed: fontName)
        textNode.text = text
        textNode.fontSize = fontSize
        textNode.fontColor = SKColor.white
        textNode.numberOfLines = 0
        textNode.lineBreakMode = .byWordWrapping
        textNode.preferredMaxLayoutWidth = backgroundNode.size.width - 40 // 根据背景尺寸调整

        // 设置文本节点的位置
        textNode.position = CGPoint(x: 0, y: 0)
        
        // 添加文本节点到对话框
        addChild(textNode)
    }
    
    // 设置按钮文本的方法
    func setButtonText(_ text: String, fontName: String = "Arial", fontSize: CGFloat = 16) {
        buttonText.text = text
        buttonText.fontName = fontName
        buttonText.fontSize = fontSize
        buttonText.position = CGPoint(x: 0, y: -buttonText.frame.size.height / 2 + 2) // 设置文本位置
    }
    
    func setPosition(x: CGFloat, y: CGFloat) {
        position = CGPoint(x: x, y: y)
    }
    
    func setButtonAction(_ action: @escaping () -> Void) {
        onButtonPressed = action
    }
}
