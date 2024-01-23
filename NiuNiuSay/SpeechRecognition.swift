//
//  SpeechRecognition.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/23.
//

import Foundation
import Speech

class SpeechRecognitionViewModel: ObservableObject {
    @Published var transcription: String = ""
    
    // 常量定义
    static let LOCALE_CHINESE = "zh-CN"
    static let LOCALE_ENGLISH = "en-US"
    
    // 标识当前的语音识别区域，默认为中文
    @Published var currentLocaleIdentifier: String = LOCALE_CHINESE

    enum RecognitionResult {
        case success(String)
        case failure(Error)
    }

    func recognizeSpeech(from audioURL: URL, completion: @escaping (RecognitionResult) -> Void) {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: currentLocaleIdentifier))

        guard let recognizer = recognizer else {
            print("Speech recognition is not supported on this device.")
            completion(.failure(NSError(domain: "SpeechRecognition", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition not supported"])))
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)

        recognizer.recognitionTask(with: request) { [weak self] (result, error) in
            if let result = result {
                // 获取最佳的识别结果
                let transcription = result.bestTranscription.formattedString

                print("Transcription: \(transcription)")
                // 更新视图模型的属性
                DispatchQueue.main.async {
                    self?.transcription = transcription
                    completion(.success(transcription))
                }
            } else if let error = error {
                // 处理语音识别错误
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // 切换语音识别区域
    func changeLocale(to: String) {
        if to != SpeechRecognitionViewModel.LOCALE_CHINESE
            || to != SpeechRecognitionViewModel.LOCALE_ENGLISH {
            print("not supported locale: \(to)")
            return
        }
        currentLocaleIdentifier = to
    }
}
