//
//  RecorderDeligate.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

// RecorderDelegate.swift

import AVFoundation

class RecorderDelegate: NSObject, AVAudioRecorderDelegate {
    var updateMetering: ((Float) -> Void)?
    
    func updateAudioMeter(recorder: AVAudioRecorder) {
        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)
        updateMetering?(averagePower)
    }
}
