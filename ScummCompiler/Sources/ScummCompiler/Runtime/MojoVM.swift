//
//  MojoVM.swift
//
//
//  Created by Michael Borgmann on 16/12/2023.
//

import Foundation

/// A virtual machine implementation specialized for executing bytecode with Mojo opcodes.
///
/// `MojoVM` is a concrete implementation of the `BaseVM` class, providing a runtime environment
/// for interpreting and executing bytecode instructions using the opcodes defined in the
/// `MojoOpcode` enumeration.
public class MojoVM: BaseVM<MojoOpcode> {
    
    // MARK: Actions
    
    /// Executes the bytecode stored in the associated `chunk` using Mojo opcodes.
    ///
    /// The `run` method of `MojoVM` interprets and executes the bytecode instructions in the
    /// associated `chunk` using the opcodes defined in the `MojoOpcode` enumeration.
    ///
    /// - Throws: An error of type `VirtualMachineError` if an issue occurs during execution.
    internal override func run() throws {
        
        try super.run()
        
        while
            let instructionPointer = instructionPointer,
            let chunk = chunk,
            instructionPointer < chunk.size
        {
            
            try printDecompilation()
            
            let byte = try readNextByte()
            
            guard let instruction = MojoOpcode(rawValue: byte) else {
                throw CompilerError.unknownOpcode(byte)
            }
            
            try handleInstruction(instruction)
            
            if Configuration.DEBUG_TRACE_EXECUTION {
                showStack()
            }
        }
    }
}

// MARK: - Debug

extension MojoVM {
    
    /// Prints the decompilation of the current instruction if decompiler is enabled.
    ///
    /// - Throws: An error of type `VirtualMachineError` if an issue occurs during decompilation.
    private func printDecompilation() throws {
        
        guard let instructionPointer = instructionPointer else {
            throw VirtualMachineError.undefinedInstructionPointer
        }
        
        guard let chunk = chunk else {
            throw VirtualMachineError.emptyChunk
        }
        
        if let decompilation = try decompiler?.trace(chunk, offset: instructionPointer) {
            print(decompilation)
        }
    }
}

extension MojoVM {
    
    /// Handles the execution of Mojo opcodes.
    ///
    /// The `handleInstruction` method processes and executes instructions based on the provided Mojo opcode.
    ///
    /// - Parameters:
    ///   - instruction: The Mojo opcode to be executed.
    /// - Throws: An error of type `VirtualMachineError` if an issue occurs during instruction execution.
    private func handleInstruction(_ instruction: MojoOpcode) throws {
        
        switch instruction {
            
        case .add:
            
            guard let a = peek(0), let b = peek(1) else {
                throw RuntimeError.missingOperands
            }
            
            if a.isString && b.isString {
                try concatenate(op: +)
                
            } else if a.isNumeric && b.isNumeric {
                try binaryOperation(valueType: Value.int, op: +)
                
            } else {
                throw RuntimeError.invalidOperands
            }
            
        case .subtract:
            try binaryOperation(valueType: Value.int, op: -)
            
        case .multiply:
            try binaryOperation(valueType: Value.int, op: *)
            
        case .divide:
            try binaryOperation(valueType: Value.int, op: /)
            
        case .not:
            try push(value: .bool(pop().isFalsey))
            
        case .return:
             break
            
        case .constant:
            try handleConstant()
            
        case .negate:
            
            guard
                case .int = peek(0),
                case .int(let poppedValue) = try pop()
            else {
                throw RuntimeError.invalidOperands
            }
            
            try push(value: .int(-poppedValue))
            
        case .true:
            try push(value: .bool(true))
            
        case .false:
            try push(value: .bool(false))
            
        case .equal:
            
            let b = try pop()
            let a = try pop()
            try push(value: .bool(a == b))
            
        case .greater:
            try binaryOperation(valueType: Value.bool, op: >)
            
        case .less:
            try binaryOperation(valueType: Value.bool, op: <)
            
        case .nil:
            try push(value: .nil)
            
        case .print:
            let value = try pop()
            print(value.description)
            
        case .pop:
            _ = try pop()
            
        case .defineGlobal:
            
            let index = try Int(readNextByte())
            
            guard let constant = try chunk?.readConstant(at: index).asString else {
                throw RuntimeError.unknownVariableIndex(index: index)
            }
            
            globals[constant] = peek(0)
            _ = try pop()
            
        case .getGlobal:
            
            let index = try Int(readNextByte())
            
            guard let key = try chunk?.readConstant(at: index).asString else {
                throw RuntimeError.unknownVariableIndex(index: index)
            }
            
            guard let value = globals[key] else {
                throw RuntimeError.undefinedVariable(name: key)
            }
            
            try push(value: value)
            
        case .setGlobal:
            
            let index = try Int(readNextByte())
            
            guard let constant = try chunk?.readConstant(at: index).asString else {
                throw RuntimeError.unknownVariableIndex(index: index)
            }
            
            if globals[constant] == nil {
                globals.removeValue(forKey: constant)
                throw RuntimeError.undefinedVariable(name: constant)
            } else {
                globals[constant] = peek(0)
            }
            
        case .getLocal:
            
            let slot = try Int(readNextByte())
            
            guard let constant = stack[slot] else {
                fatalError()
            }
            
            try push(value: constant)
            
        case .setLocal:
            
            let slot = try Int(readNextByte())
            stack[slot] = peek(0)
        }
    }
    
    /// Handles the execution of the constant instruction and manages the garbage collection linkage for objects.
    ///
    /// This method retrieves a constant value from the bytecode at a specified index and pushes it onto the virtual machine's stack. If the constant is an object and custom garbage collection is enabled, the object is linked into the `objects` list for future garbage collection.
    ///
    /// - Throws:
    ///   - `VirtualMachineError.emptyChunk` if the bytecode chunk is empty or unavailable.
    ///   - Any error thrown by `chunk.readConstant(at:)` if reading the constant at the specified index fails.
    ///
    /// - Note:
    ///   - If custom garbage collection is enabled, and the constant is an object, the object is linked to the global `objects` list by setting its `next` property to point to the current head of the `objects` list. The object then becomes the new head of the list.
    private func handleConstant() throws {
        
        guard let chunk = chunk else {
            throw VirtualMachineError.emptyChunk
        }
        
        let index = try Int(readNextByte())
        let constant = try chunk.readConstant(at: index)
        try push(value: constant)
        
        #if CUSTOM_GARBAGE_COLLECTION
        if case .object(let object) = constant {
            object.next = objects
            objects = object
        }
        #endif
    }
}
