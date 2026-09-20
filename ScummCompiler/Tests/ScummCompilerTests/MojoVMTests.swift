//
//  MojoVMTests.swift
//  
//
//  Created by Michael Borgmann on 10/01/2024.
//

import XCTest
@testable import ScummCompiler

final class MojoVMTests: XCTestCase {
    
    var chunk: Chunk!
    var virtualMachine: BaseVM<MojoOpcode>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        virtualMachine = MojoVM()
        chunk = Chunk()
    }
    
    override func tearDownWithError() throws {
        virtualMachine = nil
        chunk = nil
        try super.tearDownWithError()
    }
    
    func testAddInstruction() throws {
        
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(2))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        constant = chunk.addConstant(value: .int(3))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.add.rawValue, line: 1)
        
        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)
        
        if case let .int(poppedValue) = try virtualMachine.pop() {
            XCTAssertEqual(poppedValue, 5)
        } else {
            XCTFail("Can't pop integer value from stack.")
            return
        }
    }
    
    func testSubtractInstruction() throws {
        
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(5))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        constant = chunk.addConstant(value: .int(2))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.subtract.rawValue, line: 1)
        
        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)
        
        if case let .int(poppedValue) = try virtualMachine.pop() {
            XCTAssertEqual(poppedValue, 3)
        } else {
            XCTFail("Can't pop integer value from stack.")
            return
        }
    }
    
    func testMultiplyInstruction() throws {
        
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(3))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        constant = chunk.addConstant(value: .int(4))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.multiply.rawValue, line: 1)
        
        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)
        
        if case let .int(poppedValue) = try virtualMachine.pop() {
            XCTAssertEqual(poppedValue, 12)
        } else {
            XCTFail("Can't pop integer value from stack.")
            return
        }
    }
    
    func testDivideInstruction() throws {
        
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(10))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        constant = chunk.addConstant(value: .int(2))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.divide.rawValue, line: 1)
        
        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)
        
        if case let .int(poppedValue) = try virtualMachine.pop() {
            XCTAssertEqual(poppedValue, 5)
        } else {
            XCTFail("Can't pop integer value from stack.")
            return
        }
    }
    
    func testNegateInstruction() throws {
        
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        let constant = chunk.addConstant(value: .int(8))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.negate.rawValue, line: 1)
        
        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)
        
        if case let .int(poppedValue) = try virtualMachine.pop() {
            XCTAssertEqual(poppedValue, -8)
        } else {
            XCTFail("Can't pop integer value from stack.")
            return
        }
    }
    
    func testConstantInstruction() throws {
        
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        let constant = chunk.addConstant(value: .int(42))
        try chunk.write(byte: UInt8(constant), line: 1)
        
        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)
        
        if case let .int(poppedValue) = try virtualMachine.pop() {
            XCTAssertEqual(poppedValue, 42)
        } else {
            XCTFail("Can't pop integer value from stack.")
            return
        }
    }
    
    func testNotBoolInstrunction() throws {
        
        try chunk.write(byte: MojoOpcode.true.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.not.rawValue, line: 1)
        
        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)
        
        if case let .bool(poppedVaue) = try virtualMachine.pop() {
            XCTAssertFalse(poppedVaue)
        } else {
            XCTFail("Can't pop boo value from stack.")
            return
        }
    }
    
    func testIntegerEquality() throws {
        
        // 5 == 5
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(5))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        constant = chunk.addConstant(value: .int(5))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.equal.rawValue, line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)

        if case let .bool(result) = try virtualMachine.pop() {
            XCTAssertTrue(result)
        } else {
            XCTFail("Expected boolean result for equality comparison.")
        }
    }
    
    func testBooleanEquality() throws {
        
        // true == true
        try chunk.write(byte: MojoOpcode.true.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.true.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.equal.rawValue, line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)

        if case let .bool(result) = try virtualMachine.pop() {
            XCTAssertTrue(result)
        } else {
            XCTFail("Expected boolean result for equality comparison.")
        }
    }
    
    func testNilEquality() throws {
        
        // nil == nil
        try chunk.write(byte: MojoOpcode.nil.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.nil.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.equal.rawValue, line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)

        if case let .bool(result) = try virtualMachine.pop() {
            XCTAssertTrue(result)
        } else {
            XCTFail("Expected boolean result for equality comparison.")
        }
    }
    
    func testMixedEquality() throws {
        
        // 5 == true (should be false)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        let constant = chunk.addConstant(value: .int(5))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.true.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.equal.rawValue, line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)

        if case let .bool(result) = try virtualMachine.pop() {
            XCTAssertFalse(result)
        } else {
            XCTFail("Expected boolean result for equality comparison.")
        }
    }
    
    func testIntegerInequality() throws {
        
        // 5 != 3
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(5))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        constant = chunk.addConstant(value: .int(3))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.equal.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.not.rawValue, line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)

        if case let .bool(result) = try virtualMachine.pop() {
            XCTAssertTrue(result)
        } else {
            XCTFail("Expected boolean result for inequality comparison.")
        }
    }
    
    func testBooleanInequality() throws {
        
        // true != false
        try chunk.write(byte: MojoOpcode.true.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.false.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.equal.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.not.rawValue, line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)

        if case let .bool(result) = try virtualMachine.pop() {
            XCTAssertTrue(result)
        } else {
            XCTFail("Expected boolean result for inequality comparison.")
        }
    }
    
    func testNilInequality() throws {
        
        // nil != true
        try chunk.write(byte: MojoOpcode.nil.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.true.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.equal.rawValue, line: 1)
        try chunk.write(byte: MojoOpcode.not.rawValue, line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)

        if case let .bool(result) = try virtualMachine.pop() {
            XCTAssertTrue(result)
        } else {
            XCTFail("Expected boolean result for inequality comparison.")
        }
    }
    
    func testIntegerGreaterThan() throws {
        
        // 10 > 5
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(10))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        constant = chunk.addConstant(value: .int(5))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.greater.rawValue, line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)

        if case let .bool(result) = try virtualMachine.pop() {
            XCTAssertTrue(result)
        } else {
            XCTFail("Expected boolean result for greater-than comparison.")
        }
    }
    
    func testIntegerLessThan() throws {
        
        // 5 < 10
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(5))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        constant = chunk.addConstant(value: .int(10))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.less.rawValue, line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)

        if case let .bool(result) = try virtualMachine.pop() {
            XCTAssertTrue(result)
        } else {
            XCTFail("Expected boolean result for less-than comparison.")
        }
    }
    
    func testIntegerGreaterThanOrEqual() throws {
        
        // 10 >= 5
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(10))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        constant = chunk.addConstant(value: .int(5))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.greater.rawValue, line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)

        if case let .bool(result) = try virtualMachine.pop() {
            XCTAssertTrue(result)
        } else {
            XCTFail("Expected boolean result for greater-than-or-equal comparison.")
        }
    }
    
    func testIntegerLessThanOrEqual() throws {
        
        // 5 <= 10
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(5))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        constant = chunk.addConstant(value: .int(10))
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.less.rawValue, line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)

        if case let .bool(result) = try virtualMachine.pop() {
            XCTAssertTrue(result)
        } else {
            XCTFail("Expected boolean result for less-than-or-equal comparison.")
        }
    }
    
    func testGetLocal() throws {
        // Prepare the local variables
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(42))  // Pushing an integer constant
        try chunk.write(byte: UInt8(constant), line: 1)
        try chunk.write(byte: MojoOpcode.setLocal.rawValue, line: 1)
        
        // Now retrieve the local variable
        try chunk.write(byte: MojoOpcode.getLocal.rawValue, line: 1)
        
        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 1)
        
        if case let .int(value) = try virtualMachine.pop() {
            XCTAssertEqual(value, 42)
        } else {
            XCTFail("Expected integer value from getLocal.")
        }
    }
    
    func testSetLocal() throws {
        // First, load the constant value 5 onto the stack
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        var constant = chunk.addConstant(value: .int(5))  // Load constant 5
        try chunk.write(byte: UInt8(constant), line: 1)
        
        // Then, load the constant value 10 onto the stack
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        constant = chunk.addConstant(value: .int(10))  // Load constant 10
        try chunk.write(byte: UInt8(constant), line: 1)
        
        // Now, set the local variable (slot 0) with the value 10
        try chunk.write(byte: MojoOpcode.setLocal.rawValue, line: 1)

        // Pop the value from the stack after setting it to the local variable
        try chunk.write(byte: MojoOpcode.pop.rawValue, line: 1)

        // Execute the bytecode and verify the result
        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        XCTAssertEqual(virtualMachine.stackTop, 2)
        
        if case let .int(value) = try virtualMachine.pop() {
            XCTAssertEqual(value, 10)  // The final value of 'a' should be 10
        } else {
            XCTFail("Expected integer value from getLocal after setLocal.")
        }
    }

    
    #if CUSTOM_GARBAGE_COLLECTION
    func testNoObjectsInitially() throws {
        XCTAssertNil(virtualMachine.objects)
    }
    
    func testSingleObjectConstantHandling() throws {
        
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        let constant = chunk.addConstant(value: .object(Object(type: .string("test"))))
        try chunk.write(byte: UInt8(constant), line: 1)

        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        
        XCTAssertEqual(virtualMachine.stackTop, 1)
        XCTAssertNotNil(virtualMachine.objects)
        
        if let firstObject = virtualMachine.objects {
            XCTAssertEqual(firstObject.type, .string("test"))
            XCTAssertNil(firstObject.next)
        } else {
            XCTFail("Expected object to be added to objects list.")
        }
    }
    
    func testMultipleObjectConstantHandling() throws {
        
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        let firstConstant = chunk.addConstant(value: .object(Object(type: .string("first"))))
        try chunk.write(byte: UInt8(firstConstant), line: 1)
        try chunk.write(byte: MojoOpcode.constant.rawValue, line: 1)
        let secondConstant = chunk.addConstant(value: .object(Object(type: .string("second"))))
        try chunk.write(byte: UInt8(secondConstant), line: 1)
        
        XCTAssertNoThrow(try virtualMachine.interpret(chunk: chunk))
        
        XCTAssertNotNil(virtualMachine.objects)
        
        if let firstObject = virtualMachine.objects {
            XCTAssertEqual(firstObject.type, .string("second"))
            XCTAssertNotNil(firstObject.next)
            
            if let nextObject = firstObject.next {
                XCTAssertEqual(nextObject.type, .string("first"))
                XCTAssertNil(nextObject.next) // This should be the last object.
            } else {
                XCTFail("Expected object linkage in the garbage collection chain.")
            }
        } else {
            XCTFail("Expected objects to be linked.")
        }
        
    }
    #endif
}
