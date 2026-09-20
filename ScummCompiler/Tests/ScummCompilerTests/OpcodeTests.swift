//
//  OpcodeTests.swift
//  
//
//  Created by Michael Borgmann on 14/12/2023.
//

import XCTest
@testable import ScummCompiler

final class OpcodeTests: XCTestCase {
    
    func testExistingMojoOpcodes() throws {
        XCTAssertTrue(MojoOpcode.allCases.count == 21)
        XCTAssertTrue(MojoOpcode.allCases.contains(.add))
        XCTAssertTrue(MojoOpcode.allCases.contains(.subtract))
        XCTAssertTrue(MojoOpcode.allCases.contains(.multiply))
        XCTAssertTrue(MojoOpcode.allCases.contains(.divide))
        XCTAssertTrue(MojoOpcode.allCases.contains(.return))
        XCTAssertTrue(MojoOpcode.allCases.contains(.constant))
        XCTAssertTrue(MojoOpcode.allCases.contains(.negate))
        XCTAssertTrue(MojoOpcode.allCases.contains(.true))
        XCTAssertTrue(MojoOpcode.allCases.contains(.false))
        XCTAssertTrue(MojoOpcode.allCases.contains(.nil))
        XCTAssertTrue(MojoOpcode.allCases.contains(.not))
        XCTAssertTrue(MojoOpcode.allCases.contains(.equal))
        XCTAssertTrue(MojoOpcode.allCases.contains(.greater))
        XCTAssertTrue(MojoOpcode.allCases.contains(.less))
        
        XCTAssertTrue(MojoOpcode.allCases.contains(.print))
        XCTAssertTrue(MojoOpcode.allCases.contains(.pop))
        XCTAssertTrue(MojoOpcode.allCases.contains(.defineGlobal))
        XCTAssertTrue(MojoOpcode.allCases.contains(.getGlobal))
        XCTAssertTrue(MojoOpcode.allCases.contains(.setGlobal))
        XCTAssertTrue(MojoOpcode.allCases.contains(.getLocal))
        XCTAssertTrue(MojoOpcode.allCases.contains(.setLocal))
    }
    
    func testExistingScummOpcodes() throws {
        XCTAssertTrue(ScummOpcode.allCases.count == 2)
        XCTAssertTrue(ScummOpcode.allCases.contains(.breakHere))
        XCTAssertTrue(ScummOpcode.allCases.contains(.expression))
    }
}
