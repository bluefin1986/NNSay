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
    @Binding var currentTaskIndex: Int

    var body: some View {
        Text("(\(currentTaskIndex + 1) / \(totalTasks))")
            .font(.headline)
            .frame(maxWidth: 60, alignment: .trailing)
            .padding(0)
    }
}
