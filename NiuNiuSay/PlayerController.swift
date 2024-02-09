//
//  PlayerController.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import Foundation
import AVFoundation
import Combine


class PlayerController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    
    private var audioPlayer: AVAudioPlayer?
   
    // 开始或停止回放
    public func togglePlaying() {
        if isPlaying {
            stopPlaying()
            isPlaying = false
        } else {
            isPlaying = true
            startPlaying()
        }
    }
    
    // 开始回放录音
    public func startPlaying() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                guard let self = self else { return }
                self.audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.prepareToPlay() // 可选，减少播放开始的延迟
                self.audioPlayer?.play()
            } catch {
                DispatchQueue.main.async {
                    print("播放录音失败：\(error)")
                }
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 播放完毕时更新 isPlaying 的状态
        isPlaying = false
        print("play finished")
    }
    
    // 停止回放录音
    public func stopPlaying() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.audioPlayer?.stop()
            DispatchQueue.main.async {
                self?.audioPlayer = nil
            }
        }
    }
}
