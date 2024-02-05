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
    @State private var practices: [Practice] = []
    @State private var answerResultLabel: Int = 0
    @StateObject private var taskStore = TaskStore()
    @State private var originalSampleSentence: String = ""
    @State private var displaySampleSentence : NSMutableAttributedString = NSMutableAttributedString(string: "")
    @State private var displayTranslation: String = ""
    
    @State private var userAnswer = ""
    // 音频录制和回放相关的属性
    @ObservedObject private var sampleSpeakController = SampleSpeakController()
    @ObservedObject private var recorderController = RecorderController()
    @ObservedObject private var playerController = PlayerController()
    
    @State private var mainGameScene: MainGameScene? = nil
    
    var body: some View{
        VStack(spacing: 0) {
            //GameView
            GeometryReader { geometry in
                if mainGameScene == nil {
                    Color.clear
                        .onAppear {
                            mainGameScene = MainGameScene(size: CGSize(width: geometry.size.width, height: geometry.size.height))
                            mainGameScene?.setTaskStore(taskStore: taskStore)
                        }
                } else {
                    SpriteView(scene: mainGameScene!)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                }
            }
//            Spacer()
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
                        ProgressIndicator(totalTasks: practices.count, currentTaskIndex: $taskStore.currentIndex)
                            .frame(width: 100)
                        Text("请用英文说出这个句子")
                            .font(Font.custom("gongfanwanshihei", size: 24))
                            .foregroundColor(.white)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    .padding(.top, 15)
                    Spacer()
//                    // 根据 answerResultLabel 显示不同的标签
//                    if answerResultLabel == 1 {
//                        Text("Good")
//                            .foregroundColor(.green)
//                            .onAppear {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                                    //重置answerResultLabel
//                                    answerResultLabel = 0
//                                    nextSentence()
//                                }
//                            }
//                    } else if answerResultLabel == 2 {
//                        Text("Wrong")
//                            .foregroundColor(.red)
//                            .onAppear {
//                                // 用户重新说
//                            }
//                    }
                    Text("中文意思：\(displayTranslation)")
                        .font(Font.custom("gongfanwanshihei", size: 24))
                        .foregroundColor(UIColor.init(colorHex: 0x8F441B).toColor)
                        .frame(alignment: .leading)
                    Spacer()
                }
                .background(
                    Image("SentenceBoard") // 使用 Image 加载背景图片
                        .resizable() // 使图片可调整大小
                        .aspectRatio(contentMode: .fill) // 填充模式，根据需要选择 .fit 或 .fill
                )
                .padding(0)
                .frame(height: 280)
//                .frame(maxWidth: 350)
                Spacer()
                HStack {
//                    PlaySampleButton(sampleSpeekController: sampleSpeakController,
//                                     isPlaying: $sampleSpeakController.isPlaying,
//                                     sampleSentence: $originalSampleSentence)
                    
                    // 录音按钮
                    RecordButton(isRecording: $recorderController.isRecording, recorder: recorderController)
                    // 回放按钮
                    PlayButton(isPlaying: $playerController.isPlaying, player: playerController)
                }
                .padding(0)
                Spacer()
            }
            .padding(.bottom)
//
//            TextField("说出英文", text: $userAnswer)
//                .padding()
//                .onAppear {
//                    recorderController.onRecognitionComplete = { recognizedText in
//                        guard !recognizedText.isEmpty, recognizedText != userAnswer else {
//                            return
//                        }
//                        userAnswer = recognizedText
//                        let allMatched: Bool
//                        (displaySampleSentence, allMatched) = compareAnswer(recognized: recognizedText, sample: originalSampleSentence)
//                        answerResultLabel = allMatched ? 1 : 2
//                        GameController.shared.handleMatchResult(answerResult: answerResultLabel)
//                    }
//                }
            
        }
        .padding()
        .onAppear {
            loadSentences()
            updateSentences()
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
    
    /**
      * 回答正确，跳下一题
     */
    private func nextPractice(){
        print("currentIndex \(taskStore.currentIndex + 1), practices count \(practices.count)")
        if taskStore.currentIndex == practices.count{
            return
        }
        // 最后一下，不要再增加计数了，不然进度指示器会溢出
        if taskStore.currentIndex < practices.count - 1{
            taskStore.currentIndex += 1
        }
        updateSentences()
        mainGameScene?.addAmmoToPeashooter()
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
    
    // 在这里读取 JSON 数据并初始化 sentences
    private func loadSentences() {
        // 假设您已经有了一个包含 JSON 数据的字符串
        let practiceJson = """
        [
            {
                "sentence": "This is an apple",
                "translation" :"这是一颗苹果"
            },
            {
                "sentence": "This is a dog",
                "translation" :"这是一只狗"
            },
            
        ]
        """
//        {
//            "sentence": "This is a dolphin",
//            "translation" :"这是一只海豚"
//        },
//        {
//            "sentence": "These are monkeys",
//            "translation" :"这些是猴子"
//        },
//        {
//            "sentence": "These are apples",
//            "translation" :"这些是苹果"
//        },
//        {
//            "sentence": "These are cherry",
//            "translation" :"这些是樱桃"
//        },
//        {
//            "sentence": "These are eggs",
//            "translation" :"这些是鸡蛋"
//        },
//        {
//            "sentence": "These is an eggs",
//            "translation" :"这是一颗鸡蛋"
//        },
        if let data = practiceJson.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                let practices = try decoder.decode([Practice].self, from: data)
                self.practices = practices // 更新你的状态变量
                self.taskStore.totalTaskCount = practices.count
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
    }
    
    private func updateSentences() {
        if taskStore.currentIndex < practices.count {
            let practice = practices[taskStore.currentIndex]
            originalSampleSentence = practice.sentence
            displaySampleSentence = NSMutableAttributedString(string: originalSampleSentence)
            displayTranslation = practice.translation
        }
    }

    private func nextSentence() {
        if taskStore.currentIndex < practices.count - 1 {
            taskStore.currentIndex += 1
            updateSentences()
        }
    }
}
