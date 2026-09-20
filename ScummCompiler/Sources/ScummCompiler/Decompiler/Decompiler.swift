//
//  Decompilation.swift
//  
//
//  Created by Michael Borgmann on 15/12/2023.
//

import Foundation

/// A protocol for defining a decompiler.
public protocol Decompiler {
    
    /// Decompile the provided bytecode chunk.
    /// - Parameter chunk: The bytecode chunk to decompile.
    /// - Returns: An array of decompilations representing the decompiled instructions.
    /// - Throws: An error if decompilation fails.
    func decompile(_ chunk: Chunk) throws -> [Decompilation]?
    
    /// Trace the decompilation of an instruction at a specific offset in the bytecode chunk.
    /// - Parameters:
    ///   - chunk: The bytecode chunk.
    ///   - offset: The offset of the instruction to trace.
    /// - Returns: A string representation of the traced instruction.
    /// - Throws: An error if tracing fails.
    func trace(_ chunk: Chunk, offset: Int) throws -> String
    
    /// Pretty print the decompiled instructions.
    /// - Parameters:
    ///   - decompilation: An array of decompilations to print.
    ///   - name: The name associated with the decompilation.
    func prettyPrint(_ decompilation: [Decompilation], name: String)
    
    /// Print the header for the decompiled output.
    /// - Parameter name: The name associated with the decompilation.
    func printHeader(name: String)
}

public struct Decompilation {
    
    /// The offset of the instruction in the bytecode chunk.
    let offset: Int
    
    /// The opcode of the instruction.
    let opcode: any Opcode
    
    /// The constant values associated with the instruction.
    let constant: [UInt8: Value]?
    
    /// The memory slot or index used by the instruction, if applicable.
    let slot: UInt8?
    
    /// Initializes a new decompilation entry.
    ///
    /// - Parameters:
    ///   - offset: The offset of the instruction in the bytecode chunk.
    ///   - opcode: The opcode of the instruction.
    ///   - constant: The constant value associated with the instruction, if applicable.
    ///   - slot: The memory slot used by the instruction, if applicable.
    init(offset: Int, opcode: any Opcode, constant: [UInt8 : Value]? = nil, slot: UInt8? = nil) {
        self.offset = offset
        self.opcode = opcode
        self.constant = constant
        self.slot = slot
    }
}

/// A base class for decompilers.
public class BaseDecompiler<T: Opcode>: Decompiler {
    
    // MARK: Properties
    
    /// The bytecode chunk being decompiled.
    var chunk: Chunk?
    
    /// The current offset in the bytecode chunk.
    var offset: Array.Index?
    
    // MARK: Lifecycle
    
    /// Initializes a new instance of the decompiler.
    public init() { }
    
    // MARK: Actions
    
    /// Decompile the provided bytecode chunk.
    /// - Parameter chunk: The bytecode chunk to decompile.
    /// - Returns: An array of decompilations representing the decompiled instructions.
    /// - Throws: An error if decompilation fails.
    public func decompile(_ chunk: Chunk) throws -> [Decompilation]? {
        
        reset(with: chunk)
        
        var decompilation: [Decompilation]?
        
        while let current = offset, current < chunk.size {
            
            let instruction = try decompileInstruction(at: current)
            decompilation = (decompilation ?? []) + [instruction]
        }
        
        return decompilation
    }
    
    /// Trace the decompilation of an instruction at a specific offset in the bytecode chunk.
    /// - Parameters:
    ///   - chunk: The bytecode chunk.
    ///   - offset: The offset of the instruction to trace.
    /// - Returns: A string representation of the traced instruction.
    /// - Throws: An error if tracing fails.
    public func trace(_ chunk: Chunk, offset: Int) throws -> String {
        
        reset(with: chunk)
        self.offset = offset
        
        let decompilation = try decompileInstruction(at: offset)
        
        return format(decompilation)
    }
    
    /// Pretty print the decompiled instructions.
    /// - Parameters:
    ///   - decompilation: An array of decompilations to print.
    ///   - name: The name associated with the decompilation.
    public func prettyPrint(_ decompilation: [Decompilation], name: String) {
        
        printHeader(name: name)
        
        decompilation.forEach { instruction in
            print(format(instruction))
        }
    }
    
    // MARK: Override
    
    /// Handle the decompilation of a specific opcode.
    /// - Parameter opcode: The opcode to handle.
    /// - Returns: The decompilation of the opcode.
    /// - Throws: An error if handling fails.
    func handleInstruction(_ opcode: T) throws -> Decompilation {
        fatalError("Method should be overridden by subclasses")
    }
}

// MARK: - Helper

extension BaseDecompiler {
    
    /// Reset the decompiler with a new bytecode chunk.
    /// - Parameter chunk: The new bytecode chunk.
    private func reset(with chunk: Chunk) {
        self.chunk = chunk
        offset = 0
    }
}

// MARK: - Decompile Opcode

extension BaseDecompiler {
    
    /// Decompile the instruction at a specific offset in the bytecode chunk.
    /// - Parameter offset: The offset of the instruction to decompile.
    /// - Returns: The decompilation of the instruction.
    /// - Throws: An error if decompilation fails.
    private func decompileInstruction(at offset: Int) throws -> Decompilation {
        
        guard let instruction = try chunk?.read(at: offset) else {
            throw RuntimeError.cantFetchInstruction(offset)
        }
        
        guard let opcode = T(rawValue: instruction) else {
            throw CompilerError.unknownOpcode(instruction)
        }
        
        return try handleInstruction(opcode)
    }
    
    /// Decompile a simple instruction with a specified opcode.
    /// - Parameter opcode: The opcode of the simple instruction.
    /// - Returns: The decompilation of the simple instruction.
    /// - Throws: An error if decompilation fails.
    func simpleInstruction(opcode: T) throws -> Decompilation {
        
        guard let offset = offset else {
            throw CompilerError.unknownIndex
        }
        
        let decompilation = Decompilation(offset: offset, opcode: opcode)
        
        self.offset = offset + 1
        
        return decompilation
    }
}

// MARK: - Debug Printing

extension BaseDecompiler {

    /// Print the header for the decompiled output.
    /// - Parameter name: The name associated with the decompilation.
    public func printHeader(name: String) {
        
        print("== \(name) ==")
        
        print(
            "Offset".withCString { String(format: "%-6s", $0) },
            "Line".withCString { String(format: "%-4s", $0) },
            "Opcode".withCString { String(format: "%-16s", $0) },
            "@".withCString { String(format: "%-1s", $0) },
            "###".withCString { String(format: "%-3s", $0) }
        )
    }
    
    /// Format a decompilation instruction.
    /// - Parameter instruction: The decompilation instruction to format.
    /// - Returns: The formatted representation of the instruction.
    private func format(_ instruction: Decompilation) -> String {
        var output = ""
        
        guard let chunk = chunk else {
            return "----"
        }
        
        let offset = String(format: "%04d", instruction.offset)
        let line = String(format: "%4d", chunk.lines[instruction.offset])
        let opcode = instruction.opcode.name.withCString { String(format: "%-16s", $0) }
        
        if instruction.offset > 0,
           chunk.lines[instruction.offset] == chunk.lines[instruction.offset - 1]
        {
            output += "[\(offset)]    | " + opcode
        } else {
            output += "[\(offset)] \(line) \(opcode)"
        }
        
        if let constant = instruction.constant,
           let key = constant.keys.first,
           let value = constant[key]
        {
            
            switch value {
            case .object(let type):
                switch type.type {
                case .string(let value):
                    output += " \(key) '\(value)'"
                }
            case .nil:
                print("nil")
            case .bool(let value):
                print(value ? "true" : "false")
            default:
                output += " \(key) '\(value)'"
            }
        } else if let slot = instruction.slot {
            output += " \(slot)"
        }
        
        output += "\n"
        
        return output
    }
}
