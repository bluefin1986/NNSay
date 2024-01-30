//
//  ContentView.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import SwiftUI
import UIKit
import AVFoundation



struct ContentView: View {
    
    var body: some View {
        HStack(spacing:0){
            SideMenuView()
                .frame(width: 200)
            VStack(spacing: 0) {
                // Top bar with date and page indicatorSpacer()
                HStack {
                    Text("2024年2月2日")
                        .font(.title)
                        .frame(alignment: .leading)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    Text("今日任务 1 / 3")
                        .font(.subheadline)
                        .frame(alignment: .trailing)
                        .padding(.trailing, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top)
                
                Spacer()
                
                // Bottom part with sentence display and buttons
                ReadAloudView()
            }
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




