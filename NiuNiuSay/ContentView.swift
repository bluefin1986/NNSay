//
//  ContentView.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var chineseSentence = "这是一棵树"
    @State private var userAnswer = ""
    @State private var isRecording = false
    @State private var isPlaying = false
    @State private var audioMeter: Float = 0.0
    
    // 音频录制和回放相关的属性
    @ObservedObject private var recorderController = RecorderController()
    @ObservedObject private var playerController = PlayerController()
    
    @GestureState var isLongPressed = false //用于刷新长按手势的状态

    var body: some View {
        VStack {
            HStack {
                Spacer() // 将文本和麦克风按钮平分空间
                
                VStack{
                    Text("请用英文说出这个句子")
                        .font(.headline)
                        .padding()
                    Text(chineseSentence)
                        .font(.title)
                        .padding()
                    
                }
                
                Spacer()
                
                // 录音按钮
                RecordButton(isRecording: $recorderController.isRecording, recorder: recorderController)
                // 回放按钮
                PlayButton(isPlaying: $playerController.isPlaying, player: playerController)
            
                Spacer()
            }
            
            TextField("说出英文", text: $userAnswer)
                .padding()
                .onReceive(recorderController.$recognizedText) { recognizedText in
                    userAnswer = recognizedText
                }
            
            Button("检查答案") {
                // 在这里添加检查答案的逻辑
                // 比较 userAnswer 和正确答案是否一致
                // 添加逻辑以进行下一题等
            }
            .padding()
        }
        .padding()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


