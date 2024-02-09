//
//  PvZAwardDialog.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/2/6.
//

import Foundation
import SwiftUI

struct PvZAwardDialogView: View {
    
    @ObservedObject var taskStore: TaskStore
    
    @State private var showAwardDialog = false
    
    init(taskStore: TaskStore){
        self.taskStore = taskStore
    }
    
    var body: some View {
        if taskStore.award != nil && taskStore.award > 0 {
            VStack {
                Spacer()
                
                // Display the number of coins
                Text("\(taskStore.award)")
                    .font(Font.custom("SFProRounded-Bold", size: 36))
                    .frame(width: 200, height: 100, alignment: .leading)
                    .foregroundColor(UIColor.init(colorHex: 0xDAA11B).toColor)
                    .padding(.top, 220)
                    .padding(.leading, 250)
                //            Spacer()
                
                // Return button
                Button(action: {
                    print("Return button tapped")
                    taskStore.taskType = .readAloud
                    taskStore.onProcess = false
                    taskStore.correctCount = 0
                }) {
                    Text("返回")
                        .font(Font.custom("SFProRounded-Bold", size: 20))
                        .frame(width: 160, height: 200, alignment: .center)
                        .foregroundColor(.white)
                        .padding(.top, 2)
                        .padding(.leading, 15)
                        .tracking(24) //增大字间距
                }
                //            .padding(.top, 15)
                Spacer()
            }
            .frame(width: 450)
            .background(
                Image("PvZAwardDialog")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
        }
    }
}
