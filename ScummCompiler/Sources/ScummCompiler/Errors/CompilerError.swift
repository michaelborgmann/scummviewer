//
//  CompilerError.swift
//
//
//  Created by Michael Borgmann on 14/12/2023.
//

import Foundation

/// An error representing various failures that can occur during the compilation process.
enum CompilerError: LocalizedError, Equatable {
    
    /// An error indicating an unknown opcode was encountered during compilation.
    ///
    /// This error occurs when the compiler encounters an opcode that is not recognized.
    ///
    /// - Parameter opcode: The unknown opcode that caused the error.
    case unknownOpcode(UInt8)
    
    /// An error indicating that an attempt was made to compile an empty code chunk.
    ///
    /// This error occurs when there is no bytecode to process.
    ///
    /// - Throws: `CompilerError.emptyCodeChunk` if the chunk contains no code.
    case emptyCodeChunk
    
    /// An error indicating that an invalid index was used when reading from the bytecode.
    ///
    /// This error occurs when attempting to access an instruction at an index that is out of bounds or does not exist.
    ///
    /// - Throws: `CompilerError.unknownIndex` if the requested index is invalid.
    case unknownIndex
    
    /// A general compilation error.
    ///
    /// This error is used when a specific compilation failure does not fall into other categories.
    case compileError
    
    /// An error indicating that a variable has been declared more than once in the same scope.
    ///
    /// This error occurs when a variable is redeclared within the same block or function.
    ///
    /// - Parameter name: The name of the redeclared variable.
    /// - Throws: `CompilerError.variableRedeclaration` if a variable with the same name already exists in the scope.
    case variableRedeclaration(String)
    
    /// An error indicating that a variable is accessed within its own initializer.
    ///
    /// This error occurs when an attempt is made to use a variable in an expression while it is still being initialized.
    ///
    /// - Parameter name: The name of the variable being accessed too early.
    /// - Throws: `CompilerError.variableAccessInOwnInitializer` if the variable is referenced before initialization is complete.
    case variableAccessInOwnInitializer(String)
    
    /// An error indicating an invalid attempt to read bytecode at a given offset.
    ///
    /// This error occurs when the compiler tries to read a bytecode instruction from an offset that is out of bounds or corrupted.
    ///
    /// - Parameter bytecode: The opcode that causes the error.
    /// - Throws: `CompilerError.invalidBytecodeRead` if the read operation is invalid.
    case invalidBytecodeRead(opcode: UInt8)
    
    /// An error indicating a missing operand in an expression.
    ///
    /// This error occurs when an expression is incomplete and lacks a required operand.
    ///
    /// - Parameters:
    ///   - type: The type of expression (e.g., "unary", "binary").
    ///   - line: The line number in the source code where the error occurred.
    /// - Throws: `CompilerError.missingOperand` if an operand is required but not provided.
    case missingOperand(type: String, line: Int)
    
    /// An error indicating an attempt to use a variable that has not been defined.
    ///
    /// This error occurs when a variable is referenced before being declared.
    ///
    /// - Parameter name: The name of the undefined variable.
    /// - Throws: `CompilerError.undefinedVariable` if a variable is accessed without being declared.
    case undefinedVariable(name: String)
    
    // MARK: Error Descriptions
    
    var errorDescription: String? {
        
        switch self {
            
        case .unknownOpcode:
            return "Unknown Opcode"
            
        case .emptyCodeChunk:
            return "Empty Code Chunk"
        
        case .unknownIndex:
            return "Unknown Index"
            
        case .compileError:
            return "Compile Error"
            
        case .variableRedeclaration:
            return "Variable Redeclaration"
            
        case .variableAccessInOwnInitializer:
            return "Variable Access In Own Initializer"
            
        case .missingOperand:
            return "Missing Integer Operand"
            
        case .undefinedVariable:
            return "Undefined Variable"
            
        case .invalidBytecodeRead:
            return "Invalid Bytecode Read"
        }
        
    }
    
    // MARK: Failure Reason
    
    var failureReason: String? {
        
        switch self {
            
        case .unknownOpcode(let byte):
            return "No opcode is assigned for the instruction byte `\(byte)`."
            
        case .emptyCodeChunk:
            return "The chunk is empty, but should have byte code."
            
        case .unknownIndex:
            return "Unknown index for operation."
            
        case .compileError:
            return "Failed to compile the source code."
            
        case .variableRedeclaration(let name):
            return "The variable '\(name)' has already been declared in this scope."
            
        case .variableAccessInOwnInitializer(let name):
            return "Can't read local variable `\(name)` in its own initializer."
            
        case .missingOperand(let type, let line):
            return "\(type.capitalized) expression at line \(line) expects in operand."
            
        case .undefinedVariable(let name):
            return "The variable '\(name)' was referenced before it was declared or initialized."
            
        case .invalidBytecodeRead(let opcode):
            return "The compiler attempted to read a bytecode instruction for opcode `\(opcode)` at an invalid offset, but the requested byte was out of bounds or unreadable."
        }
    }
    
    // MARK: Recovery Suggestions
    
    var recoverySuggestion: String? {
        
        switch self {
            
        case .unknownOpcode:
            return "The data is corrupted, and can be a compilation error. Try to clean the project and compile again."
            
        case .emptyCodeChunk:
            return "Try to clean the project and compile again."
            
        case .unknownIndex:
            return "Try to clean the project and compile again."
            
        case .compileError:
            return "Check the source code is using the correct syntax."

        case .variableRedeclaration:
            return "Try renaming the variable or check if it should be declared in a different scope."
            
        case .variableAccessInOwnInitializer:
            return "Consider reordering your code to initialize the variable before using it in its own initializer."
            
        case .missingOperand:
            return "Check the expression for missing operands and correct the syntax."
            
        case .undefinedVariable:
            return "Ensure that the variable is declared before use."
            
        case .invalidBytecodeRead:
            return "Ensure that the bytecode chunk is correctly generated and that all instructions are properly encoded. If this error occurs during decompilation, verify that the chunk has not been corrupted or truncated."
        }
    }
}
