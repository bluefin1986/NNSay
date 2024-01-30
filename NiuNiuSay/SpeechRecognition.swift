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
    @Published var isRecognitionComplete: Bool = false

    enum RecognitionResult {
        case success(String)
        case failure(Error)
    }

    func recognizeSpeech(from audioURL: URL, completion: @escaping (RecognitionResult) -> Void) {
        isRecognitionComplete = false
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

        guard let recognizer = recognizer else {
            print("Speech recognition is not supported on this device.")
            completion(.failure(NSError(domain: "SpeechRecognition", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition not supported"])))
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)

        recognizer.recognitionTask(with: request) { [weak self] (result, error) in
            DispatchQueue.main.async {
                if let result = result {
                    if !result.isFinal{
                        return
                    }
                    let transcription = result.bestTranscription.formattedString
                    self?.transcription = transcription
                    self?.isRecognitionComplete = true
                    completion(.success(transcription))
                } else if let error = error {
                    print("Error: \(error)")
                    self?.isRecognitionComplete = true
                    completion(.failure(error))
                }
            }
        }
    }
    
}
