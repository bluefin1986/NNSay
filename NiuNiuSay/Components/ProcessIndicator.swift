//
//  ProcessIndicator.swift
//  进度指示器
//
//  Created by 郑敏嘉 on 2024/1/30.
//

import Foundation
import SwiftUI

struct ProgressIndicator: View {
    var totalTasks: Int
    var currentTaskIndex: Int

    var body: some View {
        Text("(\(currentTaskIndex) / \(totalTasks))")
            .font(Font.custom("gongfanwanshihei", size: 24))
            .frame(maxWidth:160, alignment: .trailing)
            .foregroundColor(.white)
            .padding(0)
    }
}
