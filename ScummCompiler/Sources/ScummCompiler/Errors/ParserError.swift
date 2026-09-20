//
//  ParserError.swift
//
//
//  Created by Michael Borgmann on 05/01/2024.
//

import Foundation

/// Enum representing errors that can occur during parsing.
enum ParserError: LocalizedError, Equatable {
    
    /// Indicates that an expression is expected at a specific line in the source code.
    ///
    /// - Parameters:
    ///   - line: The line number where the expression is expected.
    case expressionExpected(line: Int)
    
    /// Indicates the presence of an unexpected token during parsing.
    ///
    /// - Parameters:
    ///   - message: Additional details or message associated with the unexpected token.
    case unexpectedToken(message: String)
    
    /// Indicates an invalid assignment at a given line.
    ///
    /// - Parameters:
    ///   - line: The line number where the invalid assignment occurred.
    case invalidAssignment(line: Int)
    
    /// Indicates a missing semicolon at a specific line.
    ///
    /// - Parameters:
    ///   - line: The line number where the semicolon is expected.
    case missingSemicolon(line: Int)
    
    /// Indicates a missing bracket (either opening or closing).
    ///
    /// - Parameters:
    ///   - line: The line number where the bracket is expected.
    case missingBracket(line: Int)
    
    /// Indicates that a variable name was expected but not found.
    ///
    /// - Parameters:
    ///   - line: The line number where the variable name is expected.
    case missingVariable(line: Int)
    
    /// An error indicating that a closing brace is missing in the source code.
    ///
    /// - Parameters:
    ///   - line: The line number in the source code where the missing closing brace was expected.
    case missingClosingBraces(line: Int)
    
    /// A human-readable description of the error.
    var errorDescription: String? {
        
        switch self {
            
        case .expressionExpected:
            return "Expression Expected"
            
        case .unexpectedToken:
            return "Unexpected Token"
            
        case .invalidAssignment:
            return "Invalid Assignment"
            
        case .missingSemicolon:
            return "Missing Semicolon"
            
        case .missingVariable:
            return "Missing Variable Name"
            
        case .missingBracket:
            return "Missing Bracket"
            
        case .missingClosingBraces:
            return "Missing Clsing Braces"
        }
    }
    
    /// A localized message describing what caused the failure.
    var failureReason: String? {
        
        switch self {
            
        case .expressionExpected(let line):
            return "An expression is expected at line \(line)."
            
        case .unexpectedToken(let message):
            return message
            
        case .invalidAssignment(let line):
            return "Invalid assignment at line \(line)."
            
        case .missingSemicolon(let line):
            return "A semicolon is expected at line \(line)."
            
        case .missingVariable(let line):
            return "A variable name is expected at line \(line)."
            
        case .missingBracket(let line):
            return "A bracket (either '(' or ')') is missing at line \(line)."
            
        case .missingClosingBraces(let line):
            return "Closing braces`}` of code block is missing at line \(line)."
        }
    }
    
    /// A localized recovery suggestion to resolve the error.
    var recoverySuggestion: String? {
        
        switch self {
            
        case .expressionExpected:
            return "Ensure that the token at the specified line can initiate an expression. Check for correct syntax or consider adding a valid expression at this position."
            
        case .unexpectedToken:
            return "Review the source code for any unexpected tokens or syntax errors. Make sure the input adheres to the language grammar rules."
            
        case .invalidAssignment:
            return "Check the assignment statement and ensure it's being used correctly. Valid assignments should be to variables."
            
        case .missingSemicolon:
            return "Check if you've forgotten to include a semicolon at the end of the statement."

        case .missingVariable:
            return "Ensure that a variable name is provided at the specified line. Check if it's properly declared."
            
        case .missingBracket:
            return "Ensure that all brackets are correctly paired and closed."
            
        case .missingClosingBraces:
            return "Ensure that the scope of the code block is correctly paired and closed."
        }
    }
}
