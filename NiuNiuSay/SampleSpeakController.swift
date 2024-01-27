//
//  PracticeController.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/24.
//

import Speech
import AVFoundation
import Foundation
import CommonCrypto

class SampleSpeakController : NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    @Published var isPlaying: Bool = false
    
    private var audioPlayer: AVAudioPlayer?
    
    public func generateSpeech(text: String) {
        let hash = text.sha256()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsDirectory.appendingPathComponent("\(hash).wav")
        
        if FileManager.default.fileExists(atPath: filePath.path) {
            self.playGeneratedSpeech(hash: hash) // 播放音频文件
            return
        }
        
        guard let url = URL(string: "http://192.168.50.82:8080/tts") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // 指定内容类型为 application/x-www-form-urlencoded
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // 准备请求体，格式为 key=value
        let postString = "text=\(text)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        request.httpBody = postString.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                try data.write(to: filePath)
                self.playGeneratedSpeech(hash: hash) // 播放音频文件
            } catch {
                print("Error saving file: \(error)")
            }
        }
        task.resume()
    }
    
    func playGeneratedSpeech(hash: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsDirectory.appendingPathComponent("\(hash).wav")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: filePath)
            audioPlayer?.delegate = self
            self.isPlaying = true
            audioPlayer?.play()
        } catch {
            print("无法播放音频文件：\(error.localizedDescription)")
            // 删除掉这个音频文件
            try? FileManager.default.removeItem(at: filePath)
            self.isPlaying = false
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}

extension String {
    func sha256() -> String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
