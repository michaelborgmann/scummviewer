//
//  ASTPrinter.swift
//
//
//  Created by Michael Borgmann on 03/01/2024.
//

import Foundation

/// A utility class for printing the Abstract Syntax Tree (AST) structure.
///
/// The `ASTPrinter` class provides methods to traverse an AST and generate a human-readable string representation
/// of its structure. It implements the `ExpressionVisitor` protocol to define behavior for different expression types.
///
/// Example Usage:
/// ```swift
/// let astPrinter = ASTPrinter()
/// if let expression = //... create or obtain an expression ... {
///     if let printedAST = astPrinter.print(expression: expression) {
///         print(printedAST)
///     }
/// }
/// ```
class ASTPrinter {
    
    /// Prints the structure of the given expression.
    ///
    /// - Parameters:
    ///   - expression: The root expression of the AST to be printed.
    /// - Returns: A string representation of the AST structure.
    func print(expression: Expression) throws -> String? {
        return try expression.accept(visitor: self)
    }
    
    /// Prints the structure of the given statement in a readable, parenthesized format.
    ///
    /// - Parameter statement: The root statement of the AST to be printed.
    /// - Returns: A string representation of the statement structure.
    /// - Throws: An error if traversal of the statement fails.
    func print(statement: Statement) throws -> String? {
        try statement.accept(visitor: self)
    }
    
    /// Creates a parenthesized representation of an expression with a given name.
    ///
    /// - Parameters:
    ///   - name: The name associated with the expression type.
    ///   - expressions: The expressions to be parenthesized.
    /// - Returns: A parenthesized string representation of the expressions.
    /// - Throws: An error if an issue occurs during the expression traversal.
    func parenthesize(name: String, expressions: Expression...) throws -> String {
        
        var result = "(\(name)"
        
        for expr in expressions {
            result += " \(try expr.accept(visitor: self))"
        }
        
        result += ")"
        
        return result
    }
    
    /// Creates a parenthesized representation of a set of parts, including expressions, statements, or tokens.
    ///
    /// - Parameters:
    ///   - name: The name associated with the type of construct being represented.
    ///   - parts: The components of the construct, which can include expressions, statements, or tokens.
    /// - Returns: A parenthesized string representation of the parts.
    /// - Throws: An error if an issue occurs during traversal of the parts.
    func parenthesize2(name: String, parts: Any...) throws -> String {
        
        var result = "(\(name)"
        
        result += try transform(parts)
        result += ")"
        
        return result
    }
    
    /// Transforms a list of parts into their string representations, handling expressions, statements, and tokens.
    ///
    /// - Parameter parts: A variadic list of components to transform.
    /// - Returns: A concatenated string of the transformed parts.
    /// - Throws: An error if traversal of any part fails.
    private func transform(_ parts: Any...) throws -> String {
        
        var result = ""
        
        for part in parts {
            
            result += " "
            
            switch part {
            case let expression as Expression:
                result += try expression.accept(visitor: self)
            case let statement as Statement:
                result += try statement.accept(visitor: self)
            case let token as Token:
                result += token.lexeme
//            case let list as [Any]:
//                try transform2(&builder, parts: list)
            default:
                result += "\(part)"
            }
        }
        
        return result
    }
}

extension ASTPrinter: ExpressionVisitor {
    
    /// Prints the structure of a binary expression.
    ///
    /// - Parameters:
    ///   - expression: The binary expression to be printed.
    /// - Returns: A string representation of the binary expression structure.
    /// - Throws: An error if an issue occurs during the expression traversal.
    func visitBinaryExpr(_ expression: BinaryExpression) throws -> String {
        try parenthesize(name: expression.operatorToken.lexeme, expressions: expression.left, expression.right)
    }
    
    /// Prints the structure of a grouping expression.
    ///
    /// - Parameters:
    ///   - expression: The grouping expression to be printed.
    /// - Returns: A string representation of the grouping expression structure.
    /// - Throws: An error if an issue occurs during the expression traversal.
    func visitGroupingExpr(_ expression: GroupingExpession) throws -> String {
        try parenthesize(name: "group", expressions: expression.expression)
    }
    
    /// Prints the structure of a literal expression.
    ///
    /// - Parameters:
    ///   - expression: The literal expression to be printed.
    /// - Returns: A string representation of the literal expression structure.
    func visitLiteralExpr(_ expression: LiteralExpression) -> String {
        "\(expression.value ?? "nil")"
    }
    
    /// Prints the structure of a unary expression.
    ///
    /// - Parameters:
    ///   - expression: The unary expression to be printed.
    /// - Returns: A string representation of the unary expression structure.
    /// - Throws: An error if an issue occurs during the expression traversal.
    func visitUnaryExpr(_ expression: UnaryExpression) throws -> String {
        try parenthesize(name: expression.operatorToken.lexeme, expressions: expression.right)
    }
    
    /// Prints the structure of a variable expression.
    ///
    /// A variable expression refers to a named identifier in the program's environment.
    ///
    /// - Parameters:
    ///   - expression: The variable expression to be printed.
    /// - Returns: A string representation of the variable name.
    /// - Throws: An error if an issue occurs during the expression traversal.
    func visitVariableExpr(_ expression: VariableExpression) throws -> String {
        expression.name.lexeme
    }
    
    /// Prints the structure of an assignment expression.
    ///
    /// An assignment expression assigns a value to a variable and is represented as `name = value`.
    ///
    /// - Parameters:
    ///   - expression: The assignment expression to be printed.
    /// - Returns: A string representation of the assignment expression structure.
    /// - Throws: An error if an issue occurs during the expression traversal.
    func visitAssignExpr(_ expression: AssignExpression) throws -> String {
        try parenthesize2(name: "=", parts: expression.name.lexeme, expression.value!)
    }
}

extension ASTPrinter: StatementVisitor {
    
    /// Prints the structure of a variable statement.
    ///
    /// - Parameter stmt: The variable statement to be printed.
    /// - Returns: A string representation of the variable statement structure.
    /// - Throws: An error if an issue occurs during the statement traversal.
    func visitVarStmt(_ stmt: VariableStatement) throws -> String {
        
        guard stmt.initializer != nil else {
            return try parenthesize2(name: "var", parts: stmt.name)
        }
        
        return try parenthesize2(name: "var", parts: stmt.name, "=", stmt.initializer!)
    }
    
    /// Prints the structure of a print statement.
    ///
    /// - Parameter stmt: The print statement to be printed.
    /// - Returns: A string representation of the print statement structure.
    /// - Throws: An error if an issue occurs during the statement traversal.
    func visitPrintStmt(_ stmt: Print) throws -> String {
        try parenthesize(name: "print", expressions: stmt.expression);
    }
    
    /// Prints the structure of an expression statement.
    ///
    /// - Parameter stmt: The expression statement to be printed.
    /// - Returns: A string representation of the expression statement structure.
    /// - Throws: An error if an issue occurs during the statement traversal.
    func visitExpressionStmt(_ stmt: ExpressionStmt) throws -> String {
        try parenthesize(name: ";", expressions: stmt.expression)
    }
    
    func visitBlockStmt(_ stmt: BlockStatement) throws -> String {
        var result = "(block"
        
        try stmt.statements.forEach { statement in
            result += try statement.accept(visitor: self)
        }
        
        result += ")"
        
        return result
    }
}
