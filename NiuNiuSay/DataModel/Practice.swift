//
//  Practice.swift
//  NiuNiuSay
//
//  Created by 郑敏嘉 on 2024/2/5.
//

import Foundation
import SwiftUI


class DailyMission: ObservableObject{
    @Published public var totalCount: Int = 0
    @Published public var completedCount: Int = 0
    @Published public var taskList: [TaskStore]
    @Published public var currentTask: TaskStore!
    @Published public var finishedTask: [TaskStore]
    
    init(){
        //初始化每日任务
        taskList = []
        finishedTask = []
        let readingSentences = DailyMission.loadReadingSentence()
        let readAloudTask = TaskStore(taskType: .readAloud, practices: readingSentences)
        taskList.append(readAloudTask)
        
        totalCount = taskList.count
        currentTask = taskList.first
    }
    
    private static func loadReadingSentence() ->[Practice]{
        // 假设您已经有了一个包含 JSON 数据的字符串
        let practiceJson = """
        [
            {
                "sentence": "This is an apple",
                "translation" :"这是一颗苹果"
            },
            {
                "sentence": "This is a dog",
                "translation" :"这是一只狗"
            },
            
            
        ]
        """
//        {
//            "sentence": "This is a dolphin",
//            "translation" :"这是一只海豚"
//        },
//        {
//            "sentence": "These are monkeys",
//            "translation" :"这些是猴子"
//        },
//        {
//            "sentence": "These are apples",
//            "translation" :"这些是苹果"
//        },
//        {
//            "sentence": "These are cherry",
//            "translation" :"这些是樱桃"
//        },
//        {
//            "sentence": "These are eggs",
//            "translation" :"这些是鸡蛋"
//        },
//        {
//            "sentence": "These is an eggs",
//            "translation" :"这是一颗鸡蛋"
//        },
        if let data = practiceJson.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                let practices = try decoder.decode([Practice].self, from: data)
                return practices
//                self.practices = practices // 更新你的状态变量
//                taskStore.totalTaskCount = practices.count
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        return []
    }
}

enum TaskType{
    case readAloud  //朗读
    case englishToChinese   //英翻中
    case chineseToEnglish   //中翻英
}

class TaskStore: ObservableObject {
    @Published public var currentPracticeIndex: Int = 0
    @Published public var correctCount: Int = 0
    
    @Published public var taskType:TaskType
    
    @Published public var award: Int = 0
    
    @Published public var onProcess: Bool = false
    
    private var practices: [Practice]
    
    init(taskType:TaskType, practices:[Practice]){
        self.taskType = taskType
        self.practices = practices
    }
    
    public var taskFinished: Bool{
        return correctCount > 0 && correctCount == practices.count
    }
    
    public func increaseCorrect(){
        correctCount += 1
        award += 5
    }
    
    public func setPractices(practices: [Practice]){
        self.practices = practices
    }
    
    public func getPractices() -> [Practice]{
        return self.practices
    }
    
    public func getPracticesCount() -> Int{
        return self.practices.count
    }
    
}

struct Practice: Codable{
    
    var sentence: String
    var translation: String
    
    init(sentence: String, translation: String){
        self.sentence = sentence
        self.translation = translation
    }
}
