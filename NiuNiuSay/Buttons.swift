//
//  Buttons.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import Foundation
// Buttons.swift

import SwiftUI

public extension UIColor {
    convenience init(colorHex hex: UInt) {
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255,
                  green: CGFloat((hex & 0x00FF00) >> 8) / 255,
                  blue: CGFloat(hex & 0x0000FF) / 255, alpha: 1)
    }
}

struct RecordButton: View {
    @Binding var isRecording: Bool
    @ObservedObject var recorder: RecorderController
    @State private var isPressing = false
    
    private let microPhoneIconSquareSize = CGFloat(100)
    
    var body: some View {
        ZStack{
            
            Button {
                // 点击事件为空，由长按事件处理
            } label: {
                Image(systemName: "mic.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: microPhoneIconSquareSize, height: microPhoneIconSquareSize)
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle()) // 移除按钮默认的背景效果
            .padding()
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged{ value in
                        isPressing = true
                        if !isRecording {
                            recorder.startRecording()
                        }
                    }
                    .onEnded{ state in
                        isPressing = false
                        if isRecording {
                            recorder.stopRecording()
                        }
                    }
            )
            Circle()
                .fill(Color.blue)
                .frame(width: microPhoneIconSquareSize, height: microPhoneIconSquareSize)
                .scaleEffect(calculateMeterCircle())
                .opacity(isPressing ? 0.5 : 0)
        }
    }
   
    private func calculateMeterCircle() -> CGFloat{
        let minScale: CGFloat = 0.5
        let maxScale: CGFloat = 1.2
        let adjust = 0.5
        
        let normalizedAudioMeter = CGFloat((100 + recorder.audioMeter) / 100)
        let result = min(max(normalizedAudioMeter, minScale), maxScale)
        
//        print("recorder.audioMeter: \(recorder.audioMeter) normalized to \(normalizedAudioMeter), result is \(result)")
        return result + adjust
    }
}



struct PlayButton: View {
    @Binding var isPlaying: Bool
    var player : PlayerController
    
    var body: some View {
        Button(action: {
            player.togglePlaying()
        }) {
            Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(isPlaying ? .red : .green)
        }
        .padding()
    }
}
