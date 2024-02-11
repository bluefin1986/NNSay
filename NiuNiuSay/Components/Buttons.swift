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
    @State private var microphoneMaskFill: CGFloat = 0
    
    private let microPhoneWidth = CGFloat(194)
    
    var body: some View {
        ZStack{
            Image("Microphone")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: microPhoneWidth)
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
                            .offset(y: 50 - (100 * microphoneMaskFill) / 3) // 调整遮罩的位置
                    )
                    .onDisappear {
                        isAnimating = false // 当视图消失时停止动画
                    }
                    .onAppear {
                        isAnimating = true
                    }
                    .onChange(of: recorder.audioMeter) { _,newMeterValue in
                        // 根据音量调整micmask填充
                        updateMicrophoneMaskFill(from: newMeterValue)
                    }
                Spacer()
            }
        }
        .padding(.top, 30)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressing = true
                    if !isRecording {
                        recorder.startRecording()
                    }
                }
                .onEnded { _ in
                    isPressing = false
                    if isRecording {
                        recorder.stopRecording()
                    }
                    microphoneMaskFill = 0
                }
        )
    }
    
    let animationInterval = 0.05 // 每0.05秒变化一次
    @State private var isAnimating = true
    
    private func updateMicrophoneMaskFill(from meterValue: Float) {
        // 将分贝值转换为0到1之间的值
        let normalizedMeterValue = min(max((meterValue + 60) / 60, 0), 1) // 假设最小分贝值为-60dB
        withAnimation(.linear(duration: 0.1)) {
            microphoneMaskFill = CGFloat(normalizedMeterValue)
        }
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
