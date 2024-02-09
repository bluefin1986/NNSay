//
//  Buttons.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import Foundation
import SwiftUI



struct RecordButton: View {
    @Binding var isRecording: Bool
    @ObservedObject var recorder: RecorderController
    @State private var isPressing = false
    @State private var microphoneMaskFill: CGFloat = 0.5
    
    private let microPhoneWidth = CGFloat(194)
    
    var body: some View {
        ZStack{
            Image("Microphone")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: microPhoneWidth)
//                .buttonStyle(PlainButtonStyle()) // 移除按钮默认的背景效果
//                .contentShape(Rectangle()) // 确保点击效果应用于整个按钮区域
//                .animation(nil, value: isPressing)
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
            // 作为遮罩的 MicMask 图标
            VStack{
                Image("MicMask")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 66)
                    .foregroundColor(.blue) // 遮罩的填充颜色
                    .mask(
                        Rectangle()
                            .fill(Color.white) // 遮罩颜色（不重要，因为它是遮罩）
                            .frame(width: 100, height: 100 * microphoneMaskFill)
                            .offset(y: 66 - (100 * microphoneMaskFill) / 2) // 调整遮罩的位置
                    )
                    .onDisappear {
                        isAnimating = false // 当视图消失时停止动画
                    }
                    .onAppear {
                        isAnimating = true
                        incrementMicrophoneFill()
                    }
                Spacer()
            }
        }
        .padding(.top, 30)
    }
    
    let animationStep: CGFloat = 0.1 // 每步变化的量
    let animationInterval = 0.1 // 每0.5秒变化一次
    @State private var isAnimating = true

    private func incrementMicrophoneFill() {
        guard isAnimating else { return } // 检查是否应该继续动画
        let newValue = microphoneMaskFill + animationStep > 1 ? 0 : microphoneMaskFill + animationStep
        withAnimation(.linear(duration: animationInterval)) {
            microphoneMaskFill = newValue
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationInterval) {
            incrementMicrophoneFill()
        }
    }
//    private func startUpdatingMicrophoneFill() {
//        // 通过定时器或其他方式定期更新 microphoneFill
//        // 这里你需要获取到音量并将其映射到 0 到 1 的范围内
//        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//            // 这里是假设的音量获取方法
//    
//            self.microphoneFill = min(max(0, volume / maxVolume), 1) // 确保值在 0 到 1 之间
//        }
//    }
   
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
        HStack{
            Spacer()
            Button(action: {
                player.togglePlaying()
            }) {
                Image(isPlaying ? "PlayerStop" : "PlayerPlay")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
            .padding(.trailing, 30)
            .frame(alignment: .trailing)
        }
    }
}


struct PlaySampleButton: View {
    @ObservedObject var sampleSpeekController: SampleSpeakController
    @Binding var isPlaying: Bool
    @Binding var sampleSentence: String
    
    var body: some View {
        Button(action: {
            // 点击按钮后调用 generateSpeech 方法
            sampleSpeekController.generateSpeech(text: sampleSentence)
        }) {
            // 使用 SF Symbols 中的喇叭图标
            Image(systemName: "speaker.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(UIColor.init(colorHex: 0xE75480).toColor) // 玫红色
                .opacity(isPlaying ? 0.7 : 1.0)
        }
        .padding()
        .disabled(isPlaying)
        .onAppear {
            // 用于重置按钮状态
            isPlaying = false
        }
    }
}
