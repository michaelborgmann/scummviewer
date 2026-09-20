//
//  Statement.swift
//  ScummCompiler
//
//  Created by Michael Borgmann on 13/11/2024.
//

import Foundation

/// Protocol for visiting statement nodes in an abstract syntax tree (AST).
///
/// Implementations of `StatementVisitor` define operations to perform on various types
/// of statements. This allows separating the operation logic from the data structure.
///
/// Associated Types:
/// - `StatementReturnType`: The type returned by each visitor method.
///
/// This protocol is a key component in building interpreters, AST printers, and other tools that analyze and process expressions within a programming language.
///
/// - SeeAlso: `Statement`
protocol StatementVisitor {
    
    /// The associated type representing the return type of visitor methods.
    associatedtype StatementReturnType
    
    /// Visits a print statement node.
    ///
    /// - Parameter stmt: The print statement to visit.
    /// - Returns: The result of the operation.
    func visitPrintStmt(_ stmt: Print) throws -> StatementReturnType
    
    /// Visits an expression statement node.
    ///
    /// - Parameter stmt: The expression statement to visit.
    /// - Returns: The result of the operation.
    func visitExpressionStmt(_ stmt: ExpressionStmt) throws -> StatementReturnType
    
    /// Visits a variable declaration statement node.
    ///
    /// - Parameter stmt: The variable statement to visit.
    /// - Returns: The result of the operation.
    func visitVarStmt(_ stmt: VariableStatement) throws -> StatementReturnType

    /// Visits a block statement node.
    ///
    /// - Parameter stmt: The block statement to visit.
    /// - Returns: The result of the operation.
    func visitBlockStmt(_ stmt: BlockStatement) throws -> StatementReturnType
}

/// Protocol representing a statement in an abstract syntax tree (AST).
///
/// The `Statement` protocol provides a way for statement nodes to accept
/// a `StatementVisitor` to perform operations specific to the statement type.
///
/// This protocol is essential for building interpreters, AST printers, and other tools that need to process and analyze expressions within a programming language.
///
/// - SeeAlso: `StatementVisitor`
/// ```
protocol Statement {
    
    /// Accepts a visitor to perform an operation on this statement.
    ///
    /// - Parameter visitor: The visitor implementing the desired operation.
    /// - Returns: The result of the visitor's operation.
    func accept<V: StatementVisitor, R>(visitor: V) throws -> R where R == V.StatementReturnType
}

/// Represents a print statement in the abstract syntax tree.
///
/// A print statement evaluates its expression and outputs the result as a string.
///
/// - Properties:
///   - expression: The expression to be evaluated and printed.
struct Print: Statement {
    
    /// The expression to be evaluated and printed.
    let expression: Expression
    
    /// Accepts a visitor to perform operations on the print statement.
    ///
    /// - Parameters:
    ///   - visitor: The visitor implementing the `StatementVisitor` protocol.
    /// - Returns: The result of the visitor's operation.
    /// - Throws: An error if the visitor encounters an issue during the operation.
    func accept<V, R>(visitor: V) throws -> R where V : StatementVisitor, R == V.StatementReturnType {
        try visitor.visitPrintStmt(self)
    }
}

/// Represents an expression statement in the abstract syntax tree.
///
/// An expression statement evaluates an expression and discards its result.
/// It is used in cases where the expression has side effects, such as function calls or assignments.
///
/// - Properties:
///   - expression: The expression to be evaluated.
struct ExpressionStmt: Statement {
    
    /// The expression to be evaluated.
    let expression: Expression
    
    /// Accepts a visitor to perform operations on the expression statement.
    ///
    /// - Parameters:
    ///   - visitor: The visitor implementing the `StatementVisitor` protocol.
    /// - Returns: The result of the visitor's operation.
    /// - Throws: An error if the visitor encounters an issue during the operation.
    func accept<V, R>(visitor: V) throws -> R where V : StatementVisitor, R == V.StatementReturnType {
        try visitor.visitExpressionStmt(self)
    }
}

/// Represents a variable declaration statement in the abstract syntax tree.
///
/// A variable declaration associates a name with an optional initializer expression.
/// If no initializer is provided, the variable is initialized to `nil`.
///
/// - Properties:
///   - name: The token representing the variable's name.
///   - initializer: The optional expression used to initialize the variable.
struct VariableStatement: Statement {
    
    /// The token representing the variable's name.
    let name: Token
    
    /// The optional expression used to initialize the variable.
    /// If `nil`, the variable is initialized to the default value (`nil`).
    let initializer: Expression?
    
    /// Accepts a visitor to perform operations on the variable declaration statement.
    ///
    /// - Parameters:
    ///   - visitor: The visitor implementing the `StatementVisitor` protocol.
    /// - Returns: The result of the visitor's operation.
    /// - Throws: An error if the visitor encounters an issue during the operation.
    func accept<V, R>(visitor: V) throws -> R where V : StatementVisitor, R == V.StatementReturnType {
        try visitor.visitVarStmt(self)
    }
}

/// Represents a block statement in the abstract syntax tree.
///
/// A block statement is a sequence of statements enclosed within `{}`.
/// It defines a new scope for variables and controls the execution of multiple statements as a single unit.
///
/// - Properties:
///   - statements: An array of statements contained within the block.
struct BlockStatement: Statement {
    
    /// The statements contained within the block.
    let statements: [Statement]
    
    /// Accepts a visitor to perform operations on the block statement.
    ///
    /// - Parameters:
    ///   - visitor: The visitor implementing the `StatementVisitor` protocol.
    /// - Returns: The result of the visitor's operation.
    /// - Throws: An error if the visitor encounters an issue during the operation.
    func accept<V, R>(visitor: V) throws -> R where V : StatementVisitor, R == V.StatementReturnType {
        try visitor.visitBlockStmt(self)
    }
}
