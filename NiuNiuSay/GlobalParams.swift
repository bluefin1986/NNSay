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
    var font: UIFont
    var color: UIColor?

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0  // 支持多行
        label.font = font
        label.textColor = color ?? label.textColor
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
