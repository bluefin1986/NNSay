//
//  RecorderController.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import Foundation
import AVFoundation
import Combine
import Speech

class RecorderController: ObservableObject {
    @Published var audioMeter: Float = 0.0
    @Published var isRecording: Bool = false
    //识别到的文本
    @Published var recognizedText: String = ""
    
    private var speechRecognition = SpeechRecognitionViewModel()
    private var audioRecorder: AVAudioRecorder?
    private let recorderDelegate = RecorderDelegate()
    private var meterUpdateTimer: Timer?

    
    init(){
        setupAudioRecorder()
    }
    
    private func setupAudioRecorder() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            // 初始化 audioRecorder
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = recorderDelegate
            audioRecorder?.isMeteringEnabled = true
        } catch {
            print("录音设置失败：\(error)")
        }
        
        // 设置音量更新闭包
        recorderDelegate.updateMetering = { [weak self] meter in
            self?.audioMeter = meter
        }
    }
    
    private func startMeterUpdateTimer() {
        // 定时更新音量信息
        meterUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.audioRecorder == nil {
                meterUpdateTimer?.invalidate()
                return
            }
            self.recorderDelegate.updateAudioMeter(recorder: self.audioRecorder!)
        }
    }

    private func stopMeterUpdateTimer() {
        if meterUpdateTimer != nil {
            meterUpdateTimer?.invalidate()
        }
        meterUpdateTimer = nil
    }

    // 开始录音
    public func startRecording() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            if authStatus != .authorized {
               return
            }
        }
        if !isRecording {
            isRecording = true
            audioRecorder?.record()
            startMeterUpdateTimer()
            print("recording started...")
        }
    }
    
    // 停止录音
    public func stopRecording() {
        if isRecording {
            audioRecorder?.stop()
            stopMeterUpdateTimer()
            isRecording = false
            //开始识别转换文本
            speechRecognition.recognizeSpeech(from: audioFilename) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let recognizedText):
                    self.recognizedText = recognizedText
                    print("Recognition success: \(recognizedText)")
                case .failure(let error):
                    print("Recognition failure: \(error)")
                }
            }
        }
        print("recording stopped...\(audioFilename)")
    }
    
    
}
