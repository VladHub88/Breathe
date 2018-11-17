//
//  BreatheTests.swift
//  BreatheTests
//
//  Created by Vladyslav Vovk on 11/17/18.
//  Copyright © 2018 Vladyslav Vovk. All rights reserved.
//

import XCTest
@testable import Breathe

class BreatheTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBreathePhasesJsonParse() {
        let bundle = Bundle(for: type(of: self))
        let phasesJsonUrl = bundle.url(forResource: "phases", withExtension: "json")
        XCTAssertNotNil(phasesJsonUrl, "Failed to get url of \"phases.json\" file.")
        
        let phasesJsonData = try? Data(contentsOf: phasesJsonUrl!)
        XCTAssertNotNil(phasesJsonData, "Failed to get data from \"phases.json\" file.")
        
        let breathePhases = BreathePhasesParser.parse(jsonData: phasesJsonData!)
        XCTAssertNotNil(breathePhases, "Failed to parse breathe phases correctly..")
        
        let breathePhase1 = breathePhases![safe: 0]
        XCTAssertTrue(breathePhase1?.type == .inhale)
        XCTAssertTrue(breathePhase1?.duration == 4)
        XCTAssertTrue(breathePhase1?.color.hexString == "FF00FF")
        
        let breathePhase2 = breathePhases![safe: 1]
        XCTAssertTrue(breathePhase2?.type == .exhale)
        XCTAssertTrue(breathePhase2?.duration == 2)
        XCTAssertTrue(breathePhase2?.color.hexString == "00FFFF")
        
        let breathePhase3 = breathePhases![safe: 2]
        XCTAssertTrue(breathePhase3?.type == .hold)
        XCTAssertTrue(breathePhase3?.duration == 7)
        XCTAssertTrue(breathePhase3?.color.hexString == "FFFF00")
        
        let breathePhase4 = breathePhases![safe: 3]
        XCTAssertTrue(breathePhase4?.type == .inhale)
        XCTAssertTrue(breathePhase4?.duration == 3)
        XCTAssertTrue(breathePhase4?.color.hexString == "FF0000")
        
        let breathePhase5 = breathePhases![safe: 4]
        XCTAssertTrue(breathePhase5?.type == .exhale)
        XCTAssertTrue(breathePhase5?.duration == 1)
        XCTAssertTrue(breathePhase5?.color.hexString == "0000FF")

        let breathePhase6 = breathePhases![safe: 5]
        XCTAssertTrue(breathePhase6?.type == .hold)
        XCTAssertTrue(breathePhase6?.duration == 8)
        XCTAssertTrue(breathePhase6?.color.hexString == "FFFFFF")
    }
}
