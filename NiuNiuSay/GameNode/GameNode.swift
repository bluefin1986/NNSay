//
//  GameNode.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/2/3.
//

import Foundation
import SpriteKit

protocol GameNodeDelegate {
    func didCollide(with other: GameNode, completion: (() -> Void)?)
}

open class GameNode: SKSpriteNode, GameNodeDelegate{
    
    let creatorNode: GameNode?
    
    init(creator: GameNode? = nil, texture: SKTexture?, color: UIColor, size: CGSize) {
        self.creatorNode = creator
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        // 其他初始化代码
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didCollide(with other: GameNode, completion: (() -> Void)? = nil) {
        
    }
    
    func didCollide(withGround ground: SKSpriteNode) {
        
    }
}
