//
//  Practice.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/2/5.
//

import Foundation

struct Practice: Codable{
    
    var sentence: String
    var translation: String
    
    init(sentence: String, translation: String){
        self.sentence = sentence
        self.translation = translation
    }
}


class TaskStore: ObservableObject {
    @Published public var totalTaskCount: Int = 0
    @Published public var currentIndex: Int = 0
    @Published public var correctCount: Int = 0
    
    public func taskFinished() -> Bool{
        return correctCount == totalTaskCount - 1
    }
    
}
