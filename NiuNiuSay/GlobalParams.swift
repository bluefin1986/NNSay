//
//  GlobalParams.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import Foundation
import SwiftUI
import UIKit

struct AttributedText: UIViewRepresentable {
    var attributedString: NSAttributedString
    var font: UIFont?
    var color: UIColor?
    var fixedWidth: CGFloat? // 可选的固定宽度
    

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0  // 支持多行
        label.font = font ?? UIFont.systemFont(ofSize: 18)
        label.textColor = color ?? label.textColor
        label.lineBreakMode = .byWordWrapping // 单词换行
        label.attributedText = attributedString
        label.translatesAutoresizingMaskIntoConstraints = false // 允许自动布局
        // 只有在提供了 fixedWidth 时才设置宽度约束
        if let width = fixedWidth {
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: width)
            ])
        }
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedString
        if let color = color {
            uiView.textColor = color // Only update the color if one is provided
        }
    }
    
}

public extension UIColor {
    convenience init(colorHex hex: UInt) {
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255,
                  green: CGFloat((hex & 0x00FF00) >> 8) / 255,
                  blue: CGFloat(hex & 0x0000FF) / 255, alpha: 1)
    }
    var toColor: Color {
        return Color(self)
    }
}

let audioFilename = FileManager.default.temporaryDirectory.appendingPathComponent("recordedAudio.caf")
let sampleAudioFilename = FileManager.default.temporaryDirectory.appendingPathComponent("sample.caf")

// 调试标识，为true的时候， 显示物理体边框等
let debugFlag = true
