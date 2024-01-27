//
//  ContentView.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var sampleSentence:String = "this is a tree"
    @State private var userAnswer = ""
    @State private var audioMeter: Float = 0.0
    
    @State private var englishToChinese = true
    @State private var chineseToEnglish = false
    
    // 音频录制和回放相关的属性
    @ObservedObject private var sampleSpeakController = SampleSpeakController()
    @ObservedObject private var recorderController = RecorderController()
    @ObservedObject private var playerController = PlayerController()
    
    @GestureState var isLongPressed = false //用于刷新长按手势的状态

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
                    Text(sampleSentence)
                        .font(.title)
                        .padding()
                        .foregroundColor(.black) // Set default color to black
                    
                }
                
                Spacer()
                
                PlaySampleButton(sampleSpeekController: sampleSpeakController,
                                 isPlaying: $sampleSpeakController.isPlaying,
                                 sampleSentence: $sampleSentence)
                
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
                    // 比较userAnswer 和 sampleSentence 的差异，在sampleSentence中标记出来， 差异部分用红色显示，一致的标绿色
                    let diff = calculateDiffBetween(sampleSentence, and: userAnswer)
                    let attributedString = NSMutableAttributedString(string: sampleSentence)
                    for change in diff {
                        let range = NSRange(change.range, in: sampleSentence)
                        let color: UIColor = change.operation == "delete" ? .red : .green
                        attributedString.addAttribute(.foregroundColor, value: color, range: range)
                    }
                    sampleSentence = attributedString.string
                }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func calculateDiffBetween(_ str1: String, and str2: String) -> [(operation: String, range: Range<String.Index>)] {
    var diffs: [(operation: String, range: Range<String.Index>)] = []

    let str1Chars = Array(str1)
    let str2Chars = Array(str2)
    
    var index1 = 0
    var index2 = 0

    var strIndex1 = str1.startIndex
    var strIndex2 = str2.startIndex

    while strIndex1 < str1.endIndex || strIndex2 < str2.endIndex {
        if strIndex1 < str1.endIndex && strIndex2 < str2.endIndex && str1Chars[index1] == str2Chars[index2] {
            strIndex1 = str1.index(after: strIndex1)
            strIndex2 = str2.index(after: strIndex2)
            index1 += 1
            index2 += 1
        } else {
            if strIndex1 < str1.endIndex {
                diffs.append((operation: "delete", range: strIndex1..<str1.index(after: strIndex1)))
                strIndex1 = str1.index(after: strIndex1)
                index1 += 1
            }
            if strIndex2 < str2.endIndex {
                diffs.append((operation: "insert", range: strIndex2..<str2.index(after: strIndex2)))
                strIndex2 = str2.index(after: strIndex2)
                index2 += 1
            }
        }
    }

    return diffs
}


