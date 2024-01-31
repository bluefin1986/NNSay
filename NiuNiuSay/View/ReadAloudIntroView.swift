//
//  ReadAloudIntroView.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/31.
//

import Foundation
import SwiftUI

struct ReadAloudIntroView: View {
    // 状态变量控制视图切换
    @State private var showReadAloudView = false
    @State private var isBackgroundZoomed = false

    var body: some View {
        if showReadAloudView {
            ReadAloudView()
        } else {
            ZStack {
                // 背景图片
                Image("Almanac_ZombieBack") // 替换为你的背景图片名称
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("大声读出来吧！")
                        .font(Font.custom("gongfanwanshihei", size: 24))
                        .foregroundColor(.white) // 设置文字颜色为白色
                        .frame(height: 50)
                        .padding(.top, 30)
                    Spacer()
                    HStack {
                        Spacer ()
                        VStack {
                            Spacer()
                            let infoBoxWidth:CGFloat = 400
                            // 游戏说明
                            AttributedText(attributedString: NSAttributedString("阻止僵尸进入你的屋子，\n大声念出咒语获得能量，\n让豌豆射手把僵尸打倒吧！"),
                                           font: UIFont(name: "gongfanwanshihei", size: 28)!,
                                           color:UIColor.init(colorHex: 0x171A1F),
                                           fixedWidth: infoBoxWidth)
                            .frame(width: infoBoxWidth, height: 300,  alignment: .trailing)
                            .padding(.trailing, 100)
                            // 开始按钮
                            Button(action: {
                                // 当点击时，切换视图
                                self.showReadAloudView = true
                            }) {
                                ZStack {
                                    Image("PvZButton") // 替换为你的按钮图片名称
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 113, height: 41)
                                    Text("开始游戏")
                                        .font(Font.custom("gongfanwanshihei", size: 16))
                                        .foregroundColor(.white) // 设置文字颜色为白色
                                }
                            }
                            .padding(.trailing, 200)
                            Spacer()
                        }
                        .frame(width: 500, alignment: .trailing)
                    }
                    
                }
            }
        }
    }
}
