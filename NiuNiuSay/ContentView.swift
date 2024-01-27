//
//  ContentView.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import SwiftUI
import UIKit
import AVFoundation

struct AttributedText: UIViewRepresentable {
    var attributedString: NSAttributedString

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0  // 支持多行
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedString
    }
}

struct ContentView: View {
    @State private var sentences: [String] = []
    @State private var currentIndex = 0
    @State private var originalSampleSentence: String = ""
    @State private var displaySampleSentence : NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    @State private var userAnswer = ""
    
    @State private var englishToChinese = true
    @State private var chineseToEnglish = false
    
    @State private var answerResultLabel: Int = 0

    
    // 音频录制和回放相关的属性
    @ObservedObject private var sampleSpeakController = SampleSpeakController()
    @ObservedObject private var recorderController = RecorderController()
    @ObservedObject private var playerController = PlayerController()
    
    var body: some View {
        VStack {
            HStack {
                Toggle("中翻英", isOn: $englishToChinese)
                    .padding()
                    .onChange(of: englishToChinese, {
                        chineseToEnglish = !englishToChinese
                        
                    })
                Toggle("英翻中", isOn: $chineseToEnglish)
                    .padding()
                    .onChange(of: chineseToEnglish, {
                        englishToChinese = !chineseToEnglish
                    })
                Spacer() // 将 Switch 1 推到左上角
            }
            Spacer() // 确保开关垂直居中
            HStack {
                Spacer() // 将文本和麦克风按钮平分空间
                
                VStack{
                    Text("请用英文说出这个句子")
                        .font(.headline)
                        .padding()
                    AttributedText(attributedString: displaySampleSentence)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // 限制最大宽高
                        .fixedSize(horizontal: true, vertical: true) // 垂直方向上内容自适应
                        .font(.title)
                        .padding()
                    // 根据 answerResultLabel 显示不同的标签
                    if answerResultLabel == 1 {
                        Text("Good")
                            .foregroundColor(.green)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    //重置answerResultLabel
                                    answerResultLabel = 0
                                    nextSentence()
                                }
                            }
                    } else if answerResultLabel == 2 {
                        Text("Wrong")
                            .foregroundColor(.red)
                            .onAppear {
                                // 用户重新说
                            }
                    }
                }
                
                Spacer()
                
                PlaySampleButton(sampleSpeekController: sampleSpeakController,
                                 isPlaying: $sampleSpeakController.isPlaying,
                                 sampleSentence: $originalSampleSentence)
                
                // 录音按钮
                RecordButton(isRecording: $recorderController.isRecording, recorder: recorderController)
                // 回放按钮
                PlayButton(isPlaying: $playerController.isPlaying, player: playerController)
            
                Spacer()
            }
            
            TextField("说出英文", text: $userAnswer)
                .padding()
                .onAppear {
                    recorderController.onRecognitionComplete = { recognizedText in
                        guard !recognizedText.isEmpty, recognizedText != userAnswer else {
                            return
                        }
                        userAnswer = recognizedText
                        let allMatched: Bool
                        (displaySampleSentence, allMatched) = compareAnswer(recognized: recognizedText, sample: originalSampleSentence)
                        answerResultLabel = allMatched ? 1 : 2
                        GameController.shared.handleMatchResult(answerResult: answerResultLabel)
                    }
                }

        }
        .padding()
        .onAppear {
            loadSentences()
            updateSentences()
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
    
    // 在这里读取 JSON 数据并初始化 sentences
    private func loadSentences() {
        // 假设您已经有了一个包含 JSON 数据的字符串
        let jsonString = """
        [
            {"sentence": "This is the first sentence"},
            {"sentence": "Here is the second sentence"}
        ]
        """
        
        if let data = jsonString.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonArray = json as? [[String: String]] {
                    self.sentences = jsonArray.compactMap { $0["sentence"] }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
    }
    
    private func updateSentences() {
        if currentIndex < sentences.count {
            originalSampleSentence = sentences[currentIndex]
            print("current originalSampleSentence is : \(originalSampleSentence)")
            displaySampleSentence = NSMutableAttributedString(string: originalSampleSentence)
            // 后续的逻辑，比如用户的输入处理等
        }
    }

    private func nextSentence() {
        if currentIndex < sentences.count - 1 {
            currentIndex += 1
            updateSentences()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




