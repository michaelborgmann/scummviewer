//
//  DecentParserTests.swift
//  
//
//  Created by Michael Borgmann on 07/01/2024.
//

import XCTest
@testable import ScummCompiler

class DecentParserTests: XCTestCase {
    
    class MockVisitor: ExpressionVisitor {
        
        var visitedExpressions: [ScummCompiler.Expression] = []
        
        func visitBinaryExpr(_ expression: BinaryExpression) throws {
            visitedExpressions.append(expression)
        }
        
        func visitGroupingExpr(_ expression: GroupingExpession) throws {
            visitedExpressions.append(expression)
        }
        
        func visitLiteralExpr(_ expression: LiteralExpression) throws {
            visitedExpressions.append(expression)
        }
        
        func visitUnaryExpr(_ expression: UnaryExpression) throws {
            visitedExpressions.append(expression)
        }
        
        func visitVariableExpr(_ expression: ScummCompiler.VariableExpression) throws -> () {
            visitedExpressions.append(expression)
        }
        
        func visitAssignExpr(_ expression: ScummCompiler.AssignExpression) throws -> () {
            visitedExpressions.append(expression)
        }
    }
    
    func testParseExpression() throws {
        
        let source = "1 + 2 * 3"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if
            let addition = abstractSyntaxTree as? BinaryExpression,
            let augend = addition.left as? LiteralExpression,
            let multiplication = addition.right as? BinaryExpression,
            let multiplicand = multiplication.left as? LiteralExpression,
            let multiplier = multiplication.right as? LiteralExpression
        {
            XCTAssertEqual(augend.value as? Int, 1)
            XCTAssertEqual(addition.operatorToken.type, .plus)
            XCTAssertEqual(multiplication.operatorToken.type, .star)
            XCTAssertEqual(multiplicand.value as? Int, 2)
            XCTAssertEqual(multiplier.value as? Int, 3)
            
        } else {
            XCTFail("Cannot unwrap expression")
        }
    }
    
    func testParseComplexExpression() throws {
        
        let source = "(-1 + 2) * 3 - -4"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if
            let subtraction = abstractSyntaxTree as? BinaryExpression,
            let multiplication = subtraction.left as? BinaryExpression,
            let grouping = multiplication.left as? GroupingExpession,
            let addition = grouping.expression as? BinaryExpression,
            let negation1 = addition.left as? UnaryExpression,
            let literal1 = negation1.right as? LiteralExpression,
            let literal2 = addition.right as? LiteralExpression,
            let multiplier = multiplication.right as? LiteralExpression,
            let negation2 = subtraction.right as? UnaryExpression,
            let literal3 = negation2.right as? LiteralExpression
        {
            XCTAssertEqual(literal1.value as? Int, 1)
            XCTAssertEqual(negation1.operatorToken.type, .minus)
            XCTAssertEqual(literal2.value as? Int, 2)
            XCTAssertEqual(addition.operatorToken.type, .plus)
            XCTAssertEqual(literal3.value as? Int, 4)
            XCTAssertEqual(negation2.operatorToken.type, .minus)
            XCTAssertEqual(multiplier.value as? Int, 3)
            XCTAssertNotNil(grouping.expression)
            XCTAssertEqual(multiplication.operatorToken.type, .star)
            XCTAssertEqual(subtraction.operatorToken.type, .minus)
            
        } else {
            XCTFail("Cannot unwrap expression")
        }
    }
    
    func testParseEqualEquality() throws {
        
        let source = "true"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if let boolean = abstractSyntaxTree as? LiteralExpression {
            XCTAssertEqual(boolean.value as? Bool, true)
        } else {
            XCTFail("Not true")
        }
    }
    
    func testParseFalse() throws {
        
        let source = "false"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if let boolean = abstractSyntaxTree as? LiteralExpression {
            XCTAssertEqual(boolean.value as? Bool, false)
        } else {
            XCTFail("Boolean not false")
        }
    }
    
    func testParseTrue() throws {
        
        let source = "true"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if let boolean = abstractSyntaxTree as? LiteralExpression {
            XCTAssertEqual(boolean.value as? Bool, true)
        } else {
            XCTFail("Boolean not true")
        }
    }
    
    func testParseNil() throws {
        
        let source = "nil"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if let literal = abstractSyntaxTree as? LiteralExpression {
            XCTAssertNil(literal.value)
            
        } else {
            XCTFail("Not nil")
        }
    }
    
    func testParseNotTrue() throws {
        
        let source = "!true"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if
            let notOperator = abstractSyntaxTree as? UnaryExpression,
            let boolLiteral = notOperator.right as? LiteralExpression
        {
            XCTAssertEqual(notOperator.operatorToken.type, .bang)
            XCTAssertEqual(boolLiteral.value as? Bool, true)
        } else {
            XCTFail("Boolean not true")
        }
    }
    
    func testParseNumber() throws {
        
        let source = "12345"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if let literal = abstractSyntaxTree as? LiteralExpression {
            XCTAssertEqual(literal.value as? Int, 12345)
        } else {
            XCTFail("Not a number literal")
        }
    }
    
    func testParseNegativeNumber() throws {
        
        let source = "-123"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if let unary = abstractSyntaxTree as? UnaryExpression,
           let literal = unary.right as? LiteralExpression {
            XCTAssertEqual(unary.operatorToken.type, .minus)
            XCTAssertEqual(literal.value as? Int, 123)
        } else {
            XCTFail("Not a negative number literal")
        }
    }
    
    func testParseStringLiteral() throws {
        
        let source = "\"Hello, World!\""
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if let literal = abstractSyntaxTree as? LiteralExpression {
            XCTAssertEqual(literal.value as? String, "\"Hello, World!\"")
        } else {
            XCTFail("Not a string literal")
        }
    }
    
    func testParseStringConcatenation() throws {
        
        let source = "\"Hello\" + \" World!\""
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if let binary = abstractSyntaxTree as? BinaryExpression,
           let left = binary.left as? LiteralExpression,
           let right = binary.right as? LiteralExpression {
            XCTAssertEqual(binary.operatorToken.type, .plus)
            XCTAssertEqual(left.value as? String, "\"Hello\"")
            XCTAssertEqual(right.value as? String, "\" World!\"")
        } else {
            XCTFail("Not a string concatenation expression")
        }
    }
    
    func testParseStringEquality() throws {
        
        let source = "\"Hello\" == \"World!\""
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        let abstractSyntaxTree: ScummCompiler.Expression = try parser.parse()
        
        let mockVisitor = MockVisitor()
        try abstractSyntaxTree.accept(visitor: mockVisitor)
        
        XCTAssertEqual(mockVisitor.visitedExpressions.count, 1)
        
        if let binary = abstractSyntaxTree as? BinaryExpression,
           let left = binary.left as? LiteralExpression,
           let right = binary.right as? LiteralExpression {
            XCTAssertEqual(binary.operatorToken.type, .equalEqual)
            XCTAssertEqual(left.value as? String, "\"Hello\"")
            XCTAssertEqual(right.value as? String, "\"World!\"")
        } else {
            XCTFail("Not a string equality expression")
        }
    }
    
    func testParseVariableDeclaration() throws {
        
        let source = "var x = 10;"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        let statements: [ScummCompiler.Statement] = try parser.parse()
        
        XCTAssertEqual(statements.count, 1)
        if let variableStmt = statements.first as? VariableStatement {
            XCTAssertEqual(variableStmt.name.lexeme, "x")
            if let initializer = variableStmt.initializer as? LiteralExpression {
                XCTAssertEqual(initializer.value as? Int, 10)
            } else {
                XCTFail("Variable initialization is incorrect")
            }
        } else {
            XCTFail("Expected variable declaration statement")
        }
    }
    
    func testParseValidAssignment() throws {
        
        let source = "var x = 10; x = 20;"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        let statements: [ScummCompiler.Statement] = try parser.parse()
        
        XCTAssertEqual(statements.count, 2)
        
        if let firstStatement = statements.first as? VariableStatement {
            XCTAssertEqual(firstStatement.name.lexeme, "x")
            if let initializer = firstStatement.initializer as? LiteralExpression {
                XCTAssertEqual(initializer.value as? Int, 10)
            }
        }
        
        if let secondStatement = statements.last as? ExpressionStmt,
           let assignment = secondStatement.expression as? AssignExpression {
            XCTAssertEqual(assignment.name.lexeme, "x")
            if let value = assignment.value as? LiteralExpression {
                XCTAssertEqual(value.value as? Int, 20)
            }
        }
    }
    
    func testParseSynchronization() throws {
        
        let source = "10 = x; print \"synced\";"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        let statements: [ScummCompiler.Statement] = try parser.parse()
        
        XCTAssertEqual(statements.count, 1)
    }
    
    func testParserWithErrorRecovery() {
        
        let source = "var x = 5 + ;"
        
        let scanner = Scanner(source: source)
        let tokens = try! scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        do {
            let statements: [ScummCompiler.Statement] = try parser.parse()
            XCTAssertNotNil(statements, "Parsing should succeed even with syntax errors.")
        } catch {
            XCTFail("Unexpected error during parsing: \(error)")
        }
    }
    
    func testParseInvalidAssignment() throws {
        
        let source = "10 = x;"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        let statements: [ScummCompiler.Statement] = try parser.parse()
        
        XCTAssertEqual(statements.count, 0)
        XCTAssertEqual(parser.collectedErrors?.count, 1)
        if let error = parser.collectedErrors?.first as? ParserError {
            XCTAssertEqual(error, ParserError.invalidAssignment(line: 1))
        } else {
            XCTFail("Expected ParserError.invalidAssignment")
        }
    }
    
    func testParseMissingSemicolon() throws {
        
        let source = "var x = 10"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        let statements: [ScummCompiler.Statement] = try parser.parse()
        
        XCTAssertEqual(statements.count, 0)
        XCTAssertEqual(parser.collectedErrors?.count, 1)
        if let error = parser.collectedErrors?.first as? ParserError {
            XCTAssertEqual(error, .missingSemicolon(line: 1))
        } else {
            XCTFail("Expected ParserError.missingSemicolon")
        }
    }
    
    func testParseMissingVariableName() throws {
        
        let source = "var = 10;"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        let statements: [ScummCompiler.Statement] = try parser.parse()
        
        XCTAssertEqual(statements.count, 0)
        XCTAssertEqual(parser.collectedErrors?.count, 1)
        if let error = parser.collectedErrors?.first as? ParserError {
            XCTAssertEqual(error, .missingVariable(line: 1))
        } else {
            XCTFail("Expected ParserError.missingVariable")
        }
    }
    
    func testEmptyBlock() throws {
        
        let source = "{}"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        let statements: [ScummCompiler.Statement] = try parser.parse()
        
        XCTAssertEqual(statements.count, 1, "Expected a single block statement.")
        XCTAssertTrue(statements.first is BlockStatement, "Expected statement to be a BlockStatement.")
        
        if let blockStmt = statements.first as? BlockStatement {
            XCTAssertTrue(blockStmt.statements.isEmpty, "Expected block to have no inner statements.")
        }
    }
    
    func testBlockWithOneStatement() throws {
        
        let source = "{ var a = 10; }"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        let statements: [ScummCompiler.Statement] = try parser.parse()
        
        XCTAssertEqual(statements.count, 1, "Expected a single block statement.")
        
        if let blockStmt = statements.first as? BlockStatement {
            XCTAssertEqual(blockStmt.statements.count, 1, "Expected one statement inside the block.")
            
            if let varStmt = blockStmt.statements.first as? VariableStatement {
                XCTAssertEqual(varStmt.name.lexeme, "a", "Variable name should be 'a'.")
            } else {
                XCTFail("Expected first statement to be a VariableStatement.")
            }
        } else {
            XCTFail("Expected statement to be a BlockStatement.")
        }
    }
    
    func testBlockWithMultipleStatements() throws {
        let source = """
        {
            var a = 10;
            var b = 20;
        }
        """
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        let statements: [ScummCompiler.Statement] = try parser.parse()
        
        XCTAssertEqual(statements.count, 1, "Expected a single block statement.")
        
        if let blockStmt = statements.first as? BlockStatement {
            XCTAssertEqual(blockStmt.statements.count, 2, "Expected two statements inside the block.")
            
            XCTAssertTrue(blockStmt.statements[0] is VariableStatement, "Expected first statement to be a VariableStatement.")
            XCTAssertTrue(blockStmt.statements[1] is VariableStatement, "Expected second statement to be a VariableStatement.")
        } else {
            XCTFail("Expected statement to be a BlockStatement.")
        }
    }
    
    func testNestedBlocks() throws {
        let source = """
        {
            var a = 10;
            {
                var b = 20;
            }
        }
        """
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        let statements: [ScummCompiler.Statement] = try parser.parse()
        
        XCTAssertEqual(statements.count, 1, "Expected a single outer block statement.")
        
        if let outerBlock = statements.first as? BlockStatement {
            XCTAssertEqual(outerBlock.statements.count, 2, "Expected two statements in the outer block.")
            
            XCTAssertTrue(outerBlock.statements[0] is VariableStatement, "Expected first statement to be a VariableStatement.")
            
            if let innerBlock = outerBlock.statements[1] as? BlockStatement {
                XCTAssertEqual(innerBlock.statements.count, 1, "Expected one statement inside the nested block.")
                XCTAssertTrue(innerBlock.statements[0] is VariableStatement, "Expected nested block to contain a VariableStatement.")
            } else {
                XCTFail("Expected second statement to be a nested BlockStatement.")
            }
        } else {
            XCTFail("Expected statement to be an outer BlockStatement.")
        }
    }
    
    func testUnclosedBlockThrowsError() throws {
        
        let source = "{ var a = 10;"
        
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanAllTokens()
        let parser = DecentParser(tokens: tokens)
        
        
        let _: [ScummCompiler.Statement] = try parser.parse()
        
        XCTAssertEqual(parser.collectedErrors?.count, 1)
        XCTAssertTrue(parser.collectedErrors?.first is ParserError)
    }
}
