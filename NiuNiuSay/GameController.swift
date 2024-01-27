//
//  GameController.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/27.
//

import Foundation
import AVFoundation

class GameController {
    static let shared = GameController()
    private var audioPlayer: AVAudioPlayer?

    private init() {}

    private func playSound(named soundName: String) {
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Couldn't load sound file")
        }
    }

    func handleMatchResult(answerResult: Int) {
        if answerResult == 1 {
            // 这里执行 allMatched 为 true 时的一连串操作
            playSound(named: "success")
            // 其他游戏逻辑
        } else {
            playSound(named: "fail")
            // 其他游戏逻辑
        }
    }

    // ... 其他游戏相关方法 ...
}
