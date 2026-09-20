//
//  Interpreter.swift
//
//
//  Created by Michael Borgmann on 03/01/2024.
//

import Foundation

/// A class responsible for interpreting expressions in the abstract syntax tree (AST).
///
/// The `Interpreter` class evaluates AST expressions, performing arithmetic operations and handling errors as needed.
///
/// - Note: This class serves as the core interpreter for expressions and provides methods for interpretation and value conversion.
///
/// Example Usage:
/// ```swift
/// let scanner = Scanner(source: source)
/// let tokens = try scanner.scanAllTokens()
/// let parser = DecentParser(tokens: tokens)
/// let expression = try parse.parse()
/// let interpreter = Interpreter()
/// let result = try interpreter.interpret(ast: expression)
/// print(interpreter.stringify(result))
/// ```
///
/// - SeeAlso: `Expression`, `ExpressionVisitor`, `InterpreterError` for related components.
class Interpreter {
    
    // MARK: Properties
    
    /// The current execution environment, managing variable scopes and supporting nested environments for global and local variable resolution.
    private var environment = Environment()
    
    // MARK: Actions
    
    /// Interprets the given AST expression.
    ///
    /// - Parameters:
    ///   - ast: The AST expression to be interpreted.
    /// - Returns: The result of the interpretation, which can be of any type.
    /// - Throws: An error if the interpretation encounters issues.
    func interpret(ast: Expression) throws -> Any? {
        try evaluate(ast)
    }
    
    /// Interprets a list of statements.
    ///
    /// Executes each statement in order within the given environment. Throws a runtime error if any statement cannot be executed.
    ///
    /// - Parameters:
    ///   - statements: A list of statements to execute.
    /// - Throws: `RuntimeError.invalidOperands` if the execution of a statement fails.
    func interpret(statements: [Statement]) throws {
        
        do {
            try statements.forEach { statement in
                try execute(statement)
            }
        } catch {
            throw RuntimeError.invalidOperands          // TODO: Check error type
        }
    }
    
    /// Converts a value to its string representation.
    ///
    /// - Parameters:
    ///   - value: The value to be converted.
    /// - Returns: A string representation of the value.
    func stringify(_ value: Any?) -> String {
        
        guard let value = value else {
            return "nil"
        }
        
        switch value {
        case let double as Double where double.truncatingRemainder(dividingBy: 1) == 0:
            return String(format: "%.0f", double)
        default:
            return String(describing: value)
        }
    }
    
    // MARK: Helper
    
    /// Executes a given statement by visiting it.
    ///
    /// - Parameters:
    ///   - statement: The statement to execute.
    /// - Throws: Any error encountered during the execution of the statement.
    internal func execute(_ statement: Statement) throws {
        _ = try statement.accept(visitor: self)
    }
    
    private func executeBlock(statements: [Statement], environment: Environment) throws {
        
        let previous = self.environment
        self.environment = environment
        
        defer {
            self.environment = previous
        }
        
        for statement in statements {
            try execute(statement)
        }
    }
    
    /// Evaluates an expression within the AST.
    ///
    /// - Parameters:
    ///   - expression: The expression to be evaluated.
    /// - Returns: The result of the evaluation, which can be of any type.
    /// - Throws: An error if the evaluation encounters issues.
    internal func evaluate(_ expression: Expression) throws -> Any? {
        try expression.accept(visitor: self)
    }
}

extension Interpreter: ExpressionVisitor {
    
    /// Visits a literal expression node in the AST.
    ///
    /// - Parameters:
    ///   - expression: The `Literal` expression to be visited.
    /// - Returns: The value of the literal expression.
    func visitLiteralExpr(_ expression: LiteralExpression) -> Any? {
        
        switch expression.value {
        case let stringValue as String:
            return String(stringValue.dropFirst().dropLast())
        default:
            return expression.value
        }
    }
    
    /// Visits a grouping expression node in the AST.
    ///
    /// - Parameters:
    ///   - expression: The `Grouping` expression to be visited.
    /// - Returns: The result of the grouped expression.
    /// - Throws: An error if the evaluation of the grouped expression encounters issues.
    func visitGroupingExpr(_ expression: GroupingExpession) throws -> Any? {
        try evaluate(expression.expression)
    }
    
    /// Visits a unary expression node in the AST.
    ///
    /// - Parameters:
    ///   - expression: The `Unary` expression to be visited.
    /// - Returns: The result of the unary operation.
    /// - Throws: An error if the evaluation of the unary expression encounters issues.
    func visitUnaryExpr(_ expression: UnaryExpression) throws -> Any? {

        guard let right = try evaluate(expression.right) else {
            throw InterpreterError.missingOperand(type: "unary", line: expression.operatorToken.line)
        }
        
        switch expression.operatorToken.type {
        
        case .minus:
            
            switch right {
            case let rightInt as Int:
                return -rightInt
            case let rightDouble as Int:
                return -rightDouble
            default:
                throw InterpreterError.unsupportedOperator(type: "unary", line: expression.operatorToken.line)
            }
            
        case .bang:
            
            guard
                let right = try evaluate(expression.right) as? Bool
            else {
                throw InterpreterError.expressionEvaluationFailed
            }
            
            return !right
            
        default:
            throw InterpreterError.unsupportedOperator(type: "unary", line: expression.operatorToken.line)
        }
    }
    
    /// Visits a binary expression node in the AST.
    ///
    /// - Parameters:
    ///   - expression: The `Binary` expression to be visited.
    /// - Returns: The result of the binary operation.
    /// - Throws: An error if the evaluation of the binary expression encounters issues.
    func visitBinaryExpr(_ expression: BinaryExpression) throws -> Any? {
        
        let left = try evaluate(expression.left)
        let right = try evaluate(expression.right)
        
        func evaluateBinaryOp<T>(operation: (T, T) -> T) throws -> T? {
            
            if let a = left as? T, let b = right as? T {
                return operation(a, b)
            }
            
            return nil
        }
        
        switch expression.operatorToken.type {
            
        case .minus:
            if let result = try evaluateBinaryOp(operation: -) as Int? { return result }
            if let result = try evaluateBinaryOp(operation: -) as Double? { return result }
            
        case .slash:
            
            guard (right as? Int != 0) || (right as? Int != 0) else {
                throw InterpreterError.divisionByZero(line: expression.operatorToken.line)
            }
            
            if let result = try evaluateBinaryOp(operation: /) as Int? { return result }
            if let result = try evaluateBinaryOp(operation: /) as Double? { return result }
            
        case .star:
            if let result = try evaluateBinaryOp(operation: *) as Int? { return result }
            if let result = try evaluateBinaryOp(operation: *) as Double? { return result }
            
        case .plus:
            if let result = try evaluateBinaryOp(operation: +) as Int? { return result }
            if let result = try evaluateBinaryOp(operation: +) as Double? { return result }
            if let result = try evaluateBinaryOp(operation: +) as String? { return result }
            
        case .greater:
            if let a = left as? Int, let b = right as? Int { return a > b }
            if let a = left as? Double, let b = right as? Double { return a > b }
            
        case .greaterEqual:
            if let a = left as? Int, let b = right as? Int { return a >= b }
            if let a = left as? Double, let b = right as? Double { return a >= b }
            
        case .less:
            if let a = left as? Int, let b = right as? Int { return a < b }
            if let a = left as? Double, let b = right as? Double { return a < b }
            
        case .lessEqual:
            if let a = left as? Int, let b = right as? Int { return a <= b }
            if let a = left as? Double, let b = right as? Double { return a <= b }
            
        case .equalEqual:
            if let a = left as? Int, let b = right as? Int { return a == b }
            if let a = left as? Double, let b = right as? Double { return a == b }
            if let a = left as? Bool, let b = right as? Bool { return a == b }
            if let a = left as? String, let b = right as? String { return a == b }
            
            return left == nil && right == nil
            
        case .bangEqual:
            if let a = left as? Int, let b = right as? Int { return a != b }
            if let a = left as? Double, let b = right as? Double { return a != b }
            if let a = left as? Bool, let b = right as? Bool { return a != b }
            if let a = left as? String, let b = right as? String { return a != b }
            
            return (left == nil) != (right == nil)
            
        default:
            throw InterpreterError.unsupportedOperator(type: "binary", line: expression.operatorToken.line)
        }
        
        throw InterpreterError.unsupportedOperator(type: "binary", line: expression.operatorToken.line)
    }
    
    /// Visits a variable expression in the AST.
    ///
    /// Resolves the value of a variable by looking it up in the current environment.
    ///
    /// - Parameters:
    ///   - expression: The `VariableExpression` representing the variable to be resolved.
    /// - Returns: The value of the variable, or throws an error if it is undefined.
    /// - Throws: `RuntimeError.undefinedVariable` if the variable is not found in the current or enclosing environment.
    /// - SeeAlso: `Environment.get(name:)`
    func visitVariableExpr(_ expression: VariableExpression) throws -> Any? {
        try environment.get(name: expression.name)
    }
    
    /// Visits an assignment expression in the AST.
    ///
    /// Assigns a value to a variable in the current environment. If the variable is not found in the current scope, the enclosing environment is searched.
    ///
    /// - Parameters:
    ///   - expression: The `AssignExpression` containing the variable name and the value to assign.
    /// - Returns: The evaluated value that was assigned to the variable.
    /// - Throws:
    ///   - `InterpreterError.missingOperand` if the value to be assigned is `nil`.
    ///   - `RuntimeError.undefinedVariable` if the variable is not defined in the current or enclosing scope.
    /// - SeeAlso: `Environment.assign(name:value:)`
    func visitAssignExpr(_ expression: AssignExpression) throws -> Any? {
        
        guard let value = expression.value else {
            throw InterpreterError.missingOperand(type: "assignment", line: expression.name.line)
        }
        
        let evaluatedValue = try evaluate(value)
        try environment.assign(name: expression.name, value: evaluatedValue)
        return evaluatedValue
    }
}

extension Interpreter: StatementVisitor {
    
    /// Visits a variable declaration statement in the AST.
    ///
    /// Declares a new variable in the current environment, optionally initializing it with a value.
    ///
    /// - Parameters:
    ///   - stmt: The `VariableStatement` representing the variable declaration.
    /// - Throws: Any error encountered while evaluating the initializer expression.
    /// - SeeAlso: `Environment.define(name:value:)`
    func visitVarStmt(_ stmt: VariableStatement) throws -> Any? {
        
        var value: Any? = nil
        
        if let expression = stmt.initializer {
            value = try evaluate(expression)
        }
        
        environment.define(name: stmt.name.lexeme, value: value)
        
        return value
    }
    
    /// Visits a print statement in the AST.
    ///
    /// Evaluates the expression and prints its string representation to the console.
    ///
    /// - Parameters:
    ///   - stmt: The `Print` statement to execute.
    /// - Throws: Any error encountered while evaluating the expression.
    /// - SeeAlso: `stringify(_:)`
    func visitPrintStmt(_ stmt: Print) throws -> Any? {
        let value = try evaluate(stmt.expression)
        let string = stringify(value)
        print(string)
        return string
    }
    
    /// Visits an expression statement in the AST.
    ///
    /// Evaluates the expression and discards its result. This is commonly used for standalone expressions with side effects.
    ///
    /// - Parameters:
    ///   - stmt: The `ExpressionStmt` to execute.
    /// - Throws: Any error encountered while evaluating the expression.
    func visitExpressionStmt(_ stmt: ExpressionStmt) throws -> Any? {
        try evaluate(stmt.expression)
    }
    
    func visitBlockStmt(_ stmt: BlockStatement) throws -> Any? {
        try executeBlock(
            statements: stmt.statements,
            environment: Environment(enclosing: environment)
        )
    }
}
