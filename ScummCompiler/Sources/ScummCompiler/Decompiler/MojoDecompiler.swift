//
//  MojoDecompiler.swift
//  
//
//  Created by Michael Borgmann on 15/01/2024.
//

import Foundation

/// A decompiler for Mojo opcodes.
public class MojoDecompiler: BaseDecompiler<MojoOpcode> {
    
    /// Handle the decompilation of a Mojo opcode.
    /// - Parameter opcode: The Mojo opcode to handle.
    /// - Returns: The decompilation of the Mojo opcode.
    /// - Throws: An error if handling fails.
    override func handleInstruction(_ opcode: MojoOpcode) throws -> Decompilation {
        
        switch opcode {
            
        case .add:
            return try simpleInstruction(opcode: .add)
        case .subtract:
            return try simpleInstruction(opcode: .subtract)
        case .multiply:
            return try simpleInstruction(opcode: .multiply)
        case .divide:
            return try simpleInstruction(opcode: .divide)
        case .not:
            return try simpleInstruction(opcode: .not)
        case .constant:
            return try constantInstruction(opcode: .constant)
        case .negate:
            return try simpleInstruction(opcode: .negate)
        case .return:
            return try simpleInstruction(opcode: .return)
        case .true:
            return try simpleInstruction(opcode: .true)
        case .false:
            return try simpleInstruction(opcode: .false)
        case .equal:
            return try simpleInstruction(opcode: .equal)
        case .greater:
            return try simpleInstruction(opcode: .greater)
        case .less:
            return try simpleInstruction(opcode: .less)
        case .nil:
            return try simpleInstruction(opcode: .nil)
        case .print:
            return try simpleInstruction(opcode: .print)
        case .pop:
            return try simpleInstruction(opcode: .pop)
        case .defineGlobal:
            return try constantInstruction(opcode: .defineGlobal)
        case .getGlobal:
            return try constantInstruction(opcode: .getGlobal)
        case .setGlobal:
            return try constantInstruction(opcode: .setGlobal)
        case .getLocal:
            return try byteInstruction(opcode: .getLocal)
        case .setLocal:
            return try byteInstruction(opcode: .setLocal)
        }
    }
    
    /// Handle the decompilation of a Mojo constant instruction.
    /// - Parameter opcode: The Mojo opcode representing a constant instruction.
    /// - Returns: The decompilation of the Mojo constant instruction.
    /// - Throws: An error if handling fails.
    private func constantInstruction(opcode: MojoOpcode) throws -> Decompilation {
        
        guard
            let offset = offset,
            let constant = try chunk?.read(at: offset + 1),
            let value = try chunk?.readConstant(at: Int(constant))
        else {
            throw CompilerError.unknownIndex
        }
        
        let decompilation = Decompilation(offset: offset, opcode: opcode, constant: [constant: value])
        
        self.offset = offset + 2
        
        return decompilation
    }
    
    /// Handles the decompilation of a single-byte operand instruction.
    ///
    /// This method is used for opcodes that operate on a single-byte value, such as local variable access.
    /// It reads the byte following the opcode and interprets it as a slot index.
    ///
    /// - Parameter opcode: The Mojo opcode representing a single-byte instruction.
    /// - Returns: A `Decompilation` instance containing the decoded instruction information.
    /// - Throws: `CompilerError.unknownIndex` if the slot index cannot be read.
    private func byteInstruction(opcode: MojoOpcode) throws -> Decompilation {
        
        guard
            let offset = offset,
            let slot = try chunk?.read(at: offset + 1)
        else {
            throw CompilerError.invalidBytecodeRead(opcode: opcode.rawValue)
        }
        
        let decompilation = Decompilation(offset: offset, opcode: opcode, slot: slot)
        
        self.offset = offset + 2
        
        return decompilation
    }
}
