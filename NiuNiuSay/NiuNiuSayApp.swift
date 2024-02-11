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
    @State var initFinished = false
    var body: some Scene {
        WindowGroup {
            ZStack{
                // Use ViewControllerWrapper to embed the ViewController directly
                if initFinished {
                    ContentView(taskStore: dailyMission.currentTask)
                        .environmentObject(dailyMission)
                } else {
                    SplashView(initFinished: $initFinished)
                }
            }
        }
    }
}

struct SplashView: View {
    @Binding var initFinished: Bool

    var body: some View {
        Image("Splash")
        .resizable()
        .scaledToFill() // 或者使用`.scaledToFit()`，取决于您的图片应该如何显示
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // 延迟2秒钟
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.initFinished = true
                }
            }
        }
    }
}
