//
//  NiuNiuSayApp.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import SwiftUI

@main
struct NiuNiuSayApp: App {
    @StateObject private var dailyMission: DailyMission = DailyMission()
    var body: some Scene {
        WindowGroup {
            // Use ViewControllerWrapper to embed the ViewController directly
            ContentView(taskStore: dailyMission.currentTask)
                .environmentObject(dailyMission)
        }
    }
}
