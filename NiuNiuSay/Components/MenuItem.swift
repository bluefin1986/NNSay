//
//  MenuItem.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/1/30.
//

import Foundation
import SwiftUI

struct MenuItem: View {
    let title: String
    let icon: String // Assuming you are using system names for the icons
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(isSelected ? Color.purple : Color.white)
                .frame(width: 4, height: 30)
            
            Image(uiImage: UIImage(named: icon) ?? UIImage())
                .resizable()
                .foregroundColor(isSelected ? .purple : .gray)
                .frame(width: 30, height: 30)
            
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(UIColor.init(colorHex: 0x6D31ED).toColor) // Or any other color you want for the text
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
