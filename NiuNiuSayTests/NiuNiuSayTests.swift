//
//  NiuNiuSayTests.swift
//  NiuNiuSayTests
//
//  Created by 郑敏嘉 on 2024/1/22.
//

import XCTest
@testable import NiuNiuSay

final class NiuNiuSayTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let practiceController = SampleSpeakController()
        print("dddd")
        practiceController.generateSpeech(text: "这是一棵树", filename: sampleAudioFilename,
                                          locale: LOCALE_CHINESE) {
            print("生成成功")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    

}
