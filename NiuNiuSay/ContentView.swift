//
//  ContentView.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import SwiftUI
import UIKit
import SpriteKit
import AVFoundation


struct ContentView: View {
    
    @EnvironmentObject var dailyMission: DailyMission
    
    @ObservedObject var taskStore: TaskStore
    
    init(taskStore: TaskStore){
        self.taskStore = taskStore
    }
    
    var body: some View {
        ZStack {
            HStack(spacing:0){
                SideMenuView()
                    .frame(width: 200)
                VStack(spacing: 0) {
                    // Top bar with date and page indicatorSpacer()
                    HStack {
                        Text(dateFormatter.string(from: Date()))
                            .font(.title)
                            .frame(alignment: .leading)
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Text("今日任务 \(dailyMission.finishedTask.count) / \(dailyMission.totalCount)")
                            .font(.headline)
                            .frame(alignment: .trailing)
                            .padding(.trailing, 50)
                            .padding(.top, 10)
                    }
                    .frame(height: 50) // 减少顶部栏的高度
                    // Bottom part with sentence display and buttons
                    switch(dailyMission.currentTask.taskType){
                    case .readAloud:
                        ReadAloudIntroView(taskStore: dailyMission.currentTask)
                    case .englishToChinese:
                        EnglishToChineseIntroView()
                    case .chineseToEnglish:
                        ChineseToEnglishIntroView()
                    }
                    
                    //TestView
                    //                GeometryReader { geometry in
                    //                    SpriteView(scene: DialogTestScene(size: CGSize(width: geometry.size.width, height: geometry.size.height)))
                    //                        .frame(width: geometry.size.width, height: geometry.size.height)
                    //                        .edgesIgnoringSafeArea(.all)
                    //                }
                    //                Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if dailyMission.currentTask!.taskFinished {
                // 半透明遮罩
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // 这里可以添加一个关闭奖励对话框的动作，或者什么都不做来防止下面的视图接收点击事件
                    }
                // 奖励对话框
                PvZAwardDialogView(taskStore: dailyMission.currentTask)
                    .frame(width: 300, height: 200) // 根据实际需要设置大小
                    .background(Color.white) // 为了清楚地看到对话框的边界
                    .transition(.move(edge: .bottom))
                    .animation(
                        Animation.interpolatingSpring(stiffness: 150, damping: 15).delay(0.5),
                        value: dailyMission.currentTask!.taskFinished
                    )
                    .environmentObject(dailyMission)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}




