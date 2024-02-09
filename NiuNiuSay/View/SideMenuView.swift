//
//  SideMenuView.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/30.
//

import Foundation
import SwiftUI

struct SideMenuView: View {
    @State private var selectedMenuItem: String = "朗读练习"
    @EnvironmentObject var dailyMission: DailyMission
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Spacer()
                Image("profile") // Replace "profile" with your image name
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding(.trailing, 10)
                    .padding(.leading, 10)
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    AttributedText(attributedString: NSAttributedString("金妞妞"),
                                   font: UIFont(name: "Arial", size: 18)!,
                                   color:UIColor.init(colorHex: 0x171A1F))
                    .frame(height: 30)
                    .padding(0)
                    AttributedText(attributedString: NSAttributedString("金币 30000"),
                                   font: UIFont(name: "Arial", size: 14)!,
                                   color: UIColor.init(colorHex: 0x565D6D))
                    .frame(height: 20)
                    .padding(0)
                    Spacer()
                }
                Spacer()
            }
            .frame(height:  80)
            .cornerRadius(10) // Optional: if you want rounded corners
            .padding(.horizontal, 8)
            .padding(.top, 20)
            Divider()
            
            HStack() {
                Spacer()
                VStack{
                    MenuItem(title: "朗读练习", icon: "smile", isSelected: selectedMenuItem == "朗读练习")
                        .onTapGesture {
                            selectedMenuItem = "朗读练习"
                            dailyMission.currentTask.taskType = .readAloud
                        }
                    MenuItem(title: "英翻中练习", icon: "eng2chn", isSelected: selectedMenuItem == "英翻中练习")
                        .onTapGesture {
                            selectedMenuItem = "英翻中练习"
                            dailyMission.currentTask.taskType = .englishToChinese
                        }
                    MenuItem(title: "中翻英练习", icon: "chn2eng", isSelected: selectedMenuItem == "中翻英练习")
                        .onTapGesture {
                            selectedMenuItem = "中翻英练习"
                            dailyMission.currentTask.taskType = .chineseToEnglish
                        }
                    MenuItem(title: "Settings", icon: "setting", isSelected: selectedMenuItem == "Settings")
                        .onTapGesture { selectedMenuItem = "Settings" }
                }
                Spacer()
            }
            .padding(.leading)
            .frame(width: 190)
            
            Spacer()
        }
        .background(UIColor.init(colorHex: 0xFAFAFB).toColor)
    }
}
