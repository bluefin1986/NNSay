//
//  ReadAloudView.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/30.
//

import Foundation
import SwiftUI
import UIKit
import SpriteKit

struct ReadAloudView: View {
    @ObservedObject var taskStore: TaskStore
    @State private var answerResultLabel: Int = 0
    @State private var originalSampleSentence: String = ""
    @State private var displaySampleSentence : NSMutableAttributedString = NSMutableAttributedString(string: "")
    @State private var displayTranslation: String = ""
    
    @State private var userAnswer = ""
    // 音频录制和回放相关的属性
    @ObservedObject private var sampleSpeakController = SampleSpeakController()
    @ObservedObject private var recorderController = RecorderController()
    @ObservedObject private var playerController = PlayerController()
    
    @State private var mainGameScene: MainGameScene? = nil
    
    init(taskStore: TaskStore){
        self.taskStore = taskStore
    }
    
    var body: some View{
        VStack(spacing: 0) {
            //GameView
            let gameViewHeight:CGFloat = 450
            GeometryReader { geometry in
                if mainGameScene == nil {
                    Color.clear
                        .onAppear {
                            mainGameScene = MainGameScene(size: CGSize(width: geometry.size.width, height: gameViewHeight),
                                                          taskStore: taskStore)
                        }
                } else {
                    SpriteView(scene: mainGameScene!)
                        .frame(width: geometry.size.width, height: gameViewHeight)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .frame(height: gameViewHeight)
            HStack(spacing: 0) {
                VStack{
                    HStack {
                        Spacer()
                        Button(action: {
                            nextPractice()
                        }) {
                            Text("点击我")
                                .foregroundColor(.white)
                                .frame(width: 100, alignment: .trailing)
                                .padding(.trailing, 30)
                        }
                    }
                    AttributedText(attributedString: displaySampleSentence,
                                   font: UIFont(name: "Arial", size: 40)!,
                                   color: .white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // 限制最大宽高
                    .fixedSize(horizontal: true, vertical: true) // 垂直方向上内容自适应
                    .frame(height:95, alignment: .leading)
                    HStack() {
                        Spacer()
                        ProgressIndicator(totalTasks: taskStore.getPracticesCount(), currentTaskIndex: taskStore.currentPracticeIndex)
                            .frame(width: 100)
                        Text("请用英文说出这个句子")
                            .font(Font.custom("gongfanwanshihei", size: 24))
                            .foregroundColor(.white)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    .padding(.top, 15)
                    Spacer()
                    Text("中文意思：\(displayTranslation)")
                        .font(Font.custom("gongfanwanshihei", size: 24))
                        .foregroundColor(UIColor.init(colorHex: 0x8F441B).toColor)
                        .frame(alignment: .leading)
                    Spacer()
                }
                .frame(maxWidth: 700, maxHeight: 282)
                .background(
                    Image("SentenceBoard") // 使用 Image 加载背景图片
                        .resizable() // 使图片可调整大小
//                        .aspectRatio(contentMode: .fill) // 填充模式，根据需要选择 .fit 或 .fill
                        .frame(maxWidth: 700, maxHeight: 282)
                        .scaledToFit()
                )
                .padding(0)
                
                VStack {
//                    PlaySampleButton(sampleSpeekController: sampleSpeakController,
//                                     isPlaying: $sampleSpeakController.isPlaying,
//                                     sampleSentence: $originalSampleSentence)
                    Spacer()
                    // 录音按钮
                    RecordButton(isRecording: $recorderController.isRecording, recorder: recorderController)
                    // 回放按钮
                    PlayButton(isPlaying: $playerController.isPlaying, player: playerController)
                    Spacer()
                }
                .padding(0)
                .frame(maxWidth: 294, maxHeight: 282)
                .background(
                    Image("RecorderBackground")
                        .resizable()
//                        .scaledToFill()
                        .frame(width: 294, height: 282)
                )
                
            }
            
////                    // 根据 answerResultLabel 显示不同的标签
////                    if answerResultLabel == 1 {
////                        Text("Good")
////                            .foregroundColor(.green)
////                            .onAppear {
////                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
////                                    //重置answerResultLabel
////                                    answerResultLabel = 0
////                                    nextSentence()
////                                }
////                            }
////                    } else if answerResultLabel == 2 {
////                        Text("Wrong")
////                            .foregroundColor(.red)
////                            .onAppear {
////                                // 用户重新说
////                            }
////                    }
                   
////                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .frame(width: 400)
             
////
////            TextField("说出英文", text: $userAnswer)
////                .padding()
////                .onAppear {
////                    recorderController.onRecognitionComplete = { recognizedText in
////                        guard !recognizedText.isEmpty, recognizedText != userAnswer else {
////                            return
////                        }
////                        userAnswer = recognizedText
////                        let allMatched: Bool
////                        (displaySampleSentence, allMatched) = compareAnswer(recognized: recognizedText, sample: originalSampleSentence)
////                        answerResultLabel = allMatched ? 1 : 2
////                        GameController.shared.handleMatchResult(answerResult: answerResultLabel)
////                    }
////                }
            
        }
        .padding(0)
        .onAppear {
            updateSentences()
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
    
    /**
      * 回答正确，跳下一题
     */
    private func nextPractice(){
        print("currentIndex \(taskStore.currentPracticeIndex + 1), practices count \(taskStore.getPracticesCount())")
        if taskStore.currentPracticeIndex == taskStore.getPracticesCount(){
            return
        }
        // 最后一下，不要再增加计数了，不然进度指示器会溢出
        if taskStore.currentPracticeIndex < taskStore.getPracticesCount(){
            DispatchQueue.main.async {
                taskStore.currentPracticeIndex += 1
                updateSentences()
                mainGameScene?.addAmmoToPeashooter()
            }
        }
    }
    
    // 比较用户的回答和标准答案，生成差异比较结果
    private func compareAnswer(recognized: String, sample: String) -> (attributedString: NSMutableAttributedString, allMatched: Bool) {
        let attributedString = NSMutableAttributedString(string: sample)
        let maxLength = max(sample.count, recognized.count)
        var allMatched = true

        for i in 0..<maxLength {
            let originalIndex = sample.index(sample.startIndex, offsetBy: min(i, sample.count - 1))
            let recognizedIndex = recognized.index(recognized.startIndex, offsetBy: min(i, recognized.count - 1))

            let originalChar = i < sample.count ? String(sample[originalIndex]) : ""
            let recognizedChar = i < recognized.count ? String(recognized[recognizedIndex]) : ""

            var color: UIColor = .black // 默认为黑色
            if i < sample.count && i < recognized.count {
                if originalChar.lowercased() == recognizedChar.lowercased() {
                    color = .green
                } else {
                    color = .red
                    allMatched = false
                }
            }
            
            attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: i, length: 1))
        }
        
        return (attributedString, allMatched)
    }
    
    
    private func updateSentences() {
        if taskStore.currentPracticeIndex < taskStore.getPracticesCount() {
            let practice = taskStore.getPractices()[taskStore.currentPracticeIndex]
            originalSampleSentence = practice.sentence
            displaySampleSentence = NSMutableAttributedString(string: originalSampleSentence)
            displayTranslation = practice.translation
        }
    }

    private func nextSentence() {
        if taskStore.currentPracticeIndex < taskStore.getPracticesCount() - 1 {
            DispatchQueue.main.async {
                taskStore.currentPracticeIndex += 1
            }
            updateSentences()
        }
    }
}
