//
//  GenerateMojoTests.swift
//  
//
//  Created by Michael Borgmann on 15/01/2024.
//

import XCTest
@testable import ScummCompiler

final class GenerateMojoTests: XCTestCase {
    
    var codeGenerator: GenerateMojo?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        codeGenerator = GenerateMojo(with: Chunk())
    }
    
    override func tearDownWithError() throws {
        codeGenerator = nil
        try super.tearDownWithError()
    }
    
    func testGenerateMojo_Addition() throws {
        
        let additionExpression = BinaryExpression(
            left: LiteralExpression(value: 10),
            operatorToken: Token(type: .plus, lexeme: "+", line: 1),
            right: LiteralExpression(value: 20)
        )
        let statement = ExpressionStmt(expression: additionExpression)
        
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf5, 1, 0xf0, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 6))
    }
    
    func testGenerateMojo_Subtraction() throws {
        
        let subtractionExpression = BinaryExpression(
            left: LiteralExpression(value: 30),
            operatorToken: Token(type: .minus, lexeme: "-", line: 1),
            right: LiteralExpression(value: 10)
        )
        let statement = ExpressionStmt(expression: subtractionExpression)
        
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf5, 1, 0xf1, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 6))
    }
    
    func testGenerateMojo_Multiplication() throws {
        
        let multiplicationExpression = BinaryExpression(
            left: LiteralExpression(value: 5),
            operatorToken: Token(type: .star, lexeme: "*", line: 1),
            right: LiteralExpression(value: 4)
        )
        let statement = ExpressionStmt(expression: multiplicationExpression)
        
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf5, 1, 0xf2, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 6))
    }
    
    func testGenerateMojo_Division() throws {
        
        let divisionExpression = BinaryExpression(
            left: LiteralExpression(value: 25),
            operatorToken: Token(type: .slash, lexeme: "/", line: 1),
            right: LiteralExpression(value: 5)
        )
        let statement = ExpressionStmt(expression: divisionExpression)
        
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf5, 1, 0xf3, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 6))
    }
    
    func testGenerateMojo_UnaryNegation() throws {
        
        let negationExpression = UnaryExpression(
            operatorToken: Token(type: .minus, lexeme: "-", line: 1),
            right: LiteralExpression(value: 8)
        )
        let statement = ExpressionStmt(expression: negationExpression)
        
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])

        
        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf6, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 4))
    }
    
    func testGenerateMojo_TrueLiteral() throws {
        
        let expression = LiteralExpression(value: true, token: Token(type: .true, lexeme: "true", line: 4))
        let statement = ExpressionStmt(expression: expression)
        
        codeGenerator = GenerateMojo(with: Chunk())
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [0xf9, 0xff])
        XCTAssertEqual(chunk?.lines, [4, 4])
    }
    
    func testGenerateMojo_FalseLiteral() throws {
        
        let expression = LiteralExpression(value: false, token: Token(type: .false, lexeme: "false", line: 2))
        let statement = ExpressionStmt(expression: expression)
        
        codeGenerator = GenerateMojo(with: Chunk())
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [0xfa, 0xff])
        XCTAssertEqual(chunk?.lines, [2, 2])
    }
    
    func testGenerateMojo_NilLiteral() throws {
        
        let token = Token(type: .nil, lexeme: "nil", line: 2)
        let expression = LiteralExpression(value: nil, token: token)
        let statement = ExpressionStmt(expression: expression)
        
        codeGenerator = GenerateMojo(with: Chunk())
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [0xf8, 0xff])
        XCTAssertEqual(chunk?.lines, [2, 2])
    }
    
    func testGenerateMojo_NotTrue() throws {
        
        let notTrue = UnaryExpression(
            operatorToken: Token(type: .bang, lexeme: "!", line: 1),
            right: LiteralExpression(value: true)
        )
        let statement = ExpressionStmt(expression: notTrue)
        
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [0xf9, 0xf7, 0xff])
        XCTAssertEqual(chunk?.lines, [1, 1, 1])
    }
    
    func testGenerateMojo_Equality() throws {
        
        let equalityExpression = BinaryExpression(
            left: LiteralExpression(value: 10),
            operatorToken: Token(type: .equalEqual, lexeme: "==", line: 1),
            right: LiteralExpression(value: 10)
        )
        let statement = ExpressionStmt(expression: equalityExpression)

        let chunk = try codeGenerator?.generateByteCode(statements: [statement])

        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf5, 1, 0xfb, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 6))
    }
    
    func testGenerateMojo_GreaterThan() throws {
        
        let greaterThanExpression = BinaryExpression(
            left: LiteralExpression(value: 10),
            operatorToken: Token(type: .greater, lexeme: ">", line: 1),
            right: LiteralExpression(value: 5)
        )
        let statement = ExpressionStmt(expression: greaterThanExpression)

        let chunk = try codeGenerator?.generateByteCode(statements: [statement])

        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf5, 1, 0xfc, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 6))
    }
    
    func testGenerateMojo_LessThan() throws {
        
        let lessThanExpression = BinaryExpression(
            left: LiteralExpression(value: 5),
            operatorToken: Token(type: .less, lexeme: "<", line: 1),
            right: LiteralExpression(value: 10)
        )
        let statement = ExpressionStmt(expression: lessThanExpression)

        let chunk = try codeGenerator?.generateByteCode(statements: [statement])

        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf5, 1, 0xfd, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 6))
    }
    
    func testGenerateMojo_Equality_Int() throws {
        
        let equalityExpression = BinaryExpression(
            left: LiteralExpression(value: 10),
            operatorToken: Token(type: .equalEqual, lexeme: "==", line: 1),
            right: LiteralExpression(value: 10)
        )
        let statement = ExpressionStmt(expression: equalityExpression)

        let chunk = try codeGenerator?.generateByteCode(statements: [statement])

        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf5, 1, 0xfb, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 6))
    }

    func testGenerateMojo_Equality_Boolean() throws {
        
        let equalityExpression = BinaryExpression(
            left: LiteralExpression(value: true),
            operatorToken: Token(type: .equalEqual, lexeme: "==", line: 1),
            right: LiteralExpression(value: true)
        )
        let statement = ExpressionStmt(expression: equalityExpression)

        let chunk = try codeGenerator?.generateByteCode(statements: [statement])

        XCTAssertEqual(chunk?.code, [0xf9, 0xf9, 0xfb, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 4))
    }

    func testGenerateMojo_Equality_BooleanFalse() throws {
        
        let equalityExpression = BinaryExpression(
            left: LiteralExpression(value: false),
            operatorToken: Token(type: .equalEqual, lexeme: "==", line: 1),
            right: LiteralExpression(value: false)
        )
        let statement = ExpressionStmt(expression: equalityExpression)

        let chunk = try codeGenerator?.generateByteCode(statements: [statement])

        XCTAssertEqual(chunk?.code, [0xfa, 0xfa, 0xfb, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 4))
    }

    func testGenerateMojo_Equality_Nil() throws {
        
        let equalityExpression = BinaryExpression(
            left: LiteralExpression(value: nil),
            operatorToken: Token(type: .equalEqual, lexeme: "==", line: 1),
            right: LiteralExpression(value: nil)
        )
        let statement = ExpressionStmt(expression: equalityExpression)

        let chunk = try codeGenerator?.generateByteCode(statements: [statement])

        XCTAssertEqual(chunk?.code, [0xf8, 0xf8, 0xfb, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 4))
    }

    func testGenerateMojo_Equality_IntAndNil() throws {
        
        let equalityExpression = BinaryExpression(
            left: LiteralExpression(value: 10),
            operatorToken: Token(type: .equalEqual, lexeme: "==", line: 1),
            right: LiteralExpression(value: nil)
        )
        let statement = ExpressionStmt(expression: equalityExpression)

        let chunk = try codeGenerator?.generateByteCode(statements: [statement])

        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf8, 0xfb, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 1, count: 5))
    }
    
    func testGenerateMojo_StringLiteral() throws {
        
        let stringExpression = LiteralExpression(value: "Hello, World!", token: Token(type: .string, lexeme: "\"Hello, World!\"", line: 1))
        let statement = ExpressionStmt(expression: stringExpression)
        
        codeGenerator = GenerateMojo(with: Chunk())
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xff])
        XCTAssertEqual(chunk?.lines, [1, 1, 1])
    }
    
    func testGenerateMojo_ConcatenateStringLiterals() throws {
        
        let concatenationExpression = BinaryExpression(
            left: LiteralExpression(value: "Hello", token: Token(type: .string, lexeme: "\"Hello\"", line: 5)),
            operatorToken: Token(type: .plus, lexeme: "+", line: 5),
            right: LiteralExpression(value: " World!", token: Token(type: .string, lexeme: "\" World!\"", line: 5))
        )
        let statement = ExpressionStmt(expression: concatenationExpression)
        
        codeGenerator = GenerateMojo(with: Chunk())
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf5, 1, 0xf0, 0xff])
        XCTAssertEqual(chunk?.lines, [5, 5, 5, 5, 5, 5])
    }
    
    func testGenerateMojo_Equality_String() throws {
        
        let equalityExpression = BinaryExpression(
            left: LiteralExpression(value: "Hello", token: Token(type: .string, lexeme: "\"Hello\"", line: 2)),
            operatorToken: Token(type: .equalEqual, lexeme: "==", line: 1),
            right: LiteralExpression(value: " World!", token: Token(type: .string, lexeme: "\" World!\"", line: 2))
        )
        let statement = ExpressionStmt(expression: equalityExpression)

        let chunk = try codeGenerator?.generateByteCode(statements: [statement])

        XCTAssertEqual(chunk?.code, [0xf5, 0, 0xf5, 1, 0xfb, 0xff])
        XCTAssertEqual(chunk?.lines, Array(repeating: 2, count: 6))
    }
        
    func testGenerateMojo_VisitVariableExpr() throws {
        
        let token = Token(type: .identifier, lexeme: "myVar", line: 1)
        let variableExpression = VariableExpression(name: token)
        let statement = ExpressionStmt(expression: variableExpression)

        codeGenerator = GenerateMojo(with: Chunk())
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [MojoOpcode.getGlobal.rawValue, 0, MojoOpcode.pop.rawValue])
        XCTAssertEqual(chunk?.lines, [1, 1, 1])
    }
    
    func testGenerateMojo_VisitAssignExpr() throws {
        
        let assignExpression = AssignExpression(
            name: Token(type: .identifier, lexeme: "myVar", line: 1),
            value: LiteralExpression(value: 10)
        )
        let statement = ExpressionStmt(expression: assignExpression)

        codeGenerator = GenerateMojo(with: Chunk())
        let chunk = try codeGenerator?.generateByteCode(statements: [statement])
        
        XCTAssertEqual(chunk?.code, [MojoOpcode.constant.rawValue, 0, MojoOpcode.setGlobal.rawValue, 1, MojoOpcode.pop.rawValue])
        XCTAssertEqual(chunk?.lines, [1, 1, 1, 1, 1])
    }
    
    func testGenerateMojo_VisitPrintStmt() throws {
        
        let token = Token(type: .string, lexeme: "Hello, World!", line: 1)
        let printExpression = LiteralExpression(value: "Hello, World!", token: token)
        let printStmt = Print(expression: printExpression)
        
        codeGenerator = GenerateMojo(with: Chunk())
        let chunk = try codeGenerator?.generateByteCode(statements: [printStmt])
        
        XCTAssertEqual(chunk?.code, [MojoOpcode.constant.rawValue, 0, MojoOpcode.print.rawValue])
        XCTAssertEqual(chunk?.lines, [1, 1, 1])
    }
    
    func testGenerateMojo_VisitVarStmt() throws {
        
        let token = Token(type: .identifier, lexeme: "myVar", line: 1)
        let initializer = LiteralExpression(value: 42)
        let varStmt = VariableStatement(name: token, initializer: initializer)
        
        codeGenerator = GenerateMojo(with: Chunk())
        let chunk = try codeGenerator?.generateByteCode(statements: [varStmt])
        
        XCTAssertEqual(chunk?.code, [
            MojoOpcode.constant.rawValue, 1, MojoOpcode.defineGlobal.rawValue, 0
        ])
        XCTAssertEqual(chunk?.lines, [1, 1, 1, 1])
    }
    
    func testGenerateMojo_SetVariable() throws {
        
        let define = Token(type: .identifier, lexeme: "myVar", line: 1)
        let initializer = LiteralExpression(value: 42, token: define)
        let varStmt = VariableStatement(name: define, initializer: initializer)
        let assign = Token(type: .identifier, lexeme: "myVar", line: 2)
        let assignStmt = ExpressionStmt(expression: AssignExpression(name: assign, value: LiteralExpression(value: 23, token: assign)))
        
        codeGenerator = GenerateMojo(with: Chunk())
        let chunk = try codeGenerator?.generateByteCode(statements: [varStmt, assignStmt])
        
        XCTAssertEqual(chunk?.code, [
            MojoOpcode.constant.rawValue, 1, MojoOpcode.defineGlobal.rawValue, 0,
            MojoOpcode.constant.rawValue, 2, MojoOpcode.setGlobal.rawValue, 3, MojoOpcode.pop.rawValue
        ])
        XCTAssertEqual(chunk?.lines, [1, 1, 1, 1, 2, 2, 2, 2, 2])
    }
    
    func testGenerateMojo_GetVariable() throws {
        
        let define = Token(type: .identifier, lexeme: "myVar", line: 1)
        let initializer = LiteralExpression(value: 42, token: define)
        let varStmt = VariableStatement(name: define, initializer: initializer)
        let variable = Token(type: .identifier, lexeme: "myVar", line: 2)
        let printStmt = Print(expression: VariableExpression(name: variable))
        
        codeGenerator = GenerateMojo(with: Chunk())
        let chunk = try codeGenerator?.generateByteCode(statements: [varStmt, printStmt])
        
        XCTAssertEqual(chunk?.code, [
            MojoOpcode.constant.rawValue, 1, MojoOpcode.defineGlobal.rawValue, 0,
            MojoOpcode.getGlobal.rawValue, 2, MojoOpcode.print.rawValue
        ])
        XCTAssertEqual(chunk?.lines, [1, 1, 1, 1, 2, 2, 2])
    }
    
    func testBeginScopeIncrementsScopeDepth() {
        
        XCTAssertEqual(codeGenerator?.scopeDepth, 0)
        
        codeGenerator?.beginScope()
        
        XCTAssertEqual(codeGenerator?.scopeDepth, 1)
    }
    
    func testEndScopeDecreasesScopeDepth() throws {
        
        codeGenerator?.beginScope()
        
        try codeGenerator?.endScope()
        
        XCTAssertEqual(codeGenerator?.scopeDepth, 0)
    }
    
    func testLocalsAreProperlyManagedAcrossScopeTransitions() throws {
        
        let token1 = Token(type: .identifier, lexeme: "var1", line: 1)
        codeGenerator?.locals.append(BaseCodeGenerator.Local(name: token1, depth: codeGenerator?.scopeDepth))
        
        XCTAssertEqual(codeGenerator?.locals.count, 1)
        
        codeGenerator?.beginScope()
        let token2 = Token(type: .identifier, lexeme: "var2", line: 1)
        codeGenerator?.locals.append(BaseCodeGenerator.Local(name: token2, depth: codeGenerator?.scopeDepth))
        
        XCTAssertEqual(codeGenerator?.locals.count, 2)
        
        codeGenerator?.line = token2.line
        try codeGenerator?.endScope()
        
        XCTAssertEqual(codeGenerator?.locals.count, 1)
        XCTAssertEqual(codeGenerator?.locals.last?.name.lexeme, "var1")
    }
    
    func testVisitBlockStmtManagesScope() throws {
        
        let blockStmt = BlockStatement(statements: [/* some test statements */])
        
        XCTAssertEqual(codeGenerator?.scopeDepth, 0)
        
        try codeGenerator?.visitBlockStmt(blockStmt)
        
        XCTAssertEqual(codeGenerator?.scopeDepth, 0) // final scope depth
    }
    
    func testVisitBlockStmtExecutesStatements() throws {
        
        let define = Token(type: .identifier, lexeme: "myVar", line: 1)
        let initializer = LiteralExpression(value: 42, token: define)
        let varStmt = VariableStatement(name: define, initializer: initializer)
        let blockStmt = BlockStatement(statements: [varStmt])
        
        XCTAssertEqual(codeGenerator?.locals.count, 0)
        
        try? codeGenerator?.visitBlockStmt(blockStmt)
        
        XCTAssertEqual(codeGenerator?.locals.count, 0)
        XCTAssertEqual(codeGenerator?.scopeDepth, 0)
    }
    
    func testLocalVariableDeclaration() throws {
        
        let define = Token(type: .identifier, lexeme: "localVar", line: 1)
        let varStmt = VariableStatement(name: define, initializer: nil)
        
        XCTAssertEqual(codeGenerator?.locals.count, 0)
        
        try codeGenerator?.handleLocalVariableDeclaration(statement: varStmt)
        
        XCTAssertEqual(codeGenerator?.locals.count, 1)
        XCTAssertEqual(codeGenerator?.locals.last?.name.lexeme, "localVar")
        XCTAssertEqual(codeGenerator?.locals.last?.depth, codeGenerator?.scopeDepth)
    }
    
    func testLocalVariableInitialization() throws {
        
        let token = Token(type: .identifier, lexeme: "localVar", line: 1)
        let initializer = LiteralExpression(value: 42)
        let varStmt = VariableStatement(name: token, initializer: initializer)
        codeGenerator?.line = token.line

        try codeGenerator?.handleLocalVariableDeclaration(statement: varStmt)
        
        XCTAssertEqual(codeGenerator?.locals.count, 1)
        XCTAssertEqual(codeGenerator?.locals.last?.name.lexeme, "localVar")
        XCTAssertEqual(codeGenerator?.locals.last?.depth, codeGenerator?.scopeDepth)
    }
    
    func testLocalVariableRedeclarationThrowsError() throws {
        
        let define = Token(type: .identifier, lexeme: "duplicateVar", line: 1)
        let varStmt1 = VariableStatement(name: define, initializer: nil)
        let varStmt2 = VariableStatement(name: define, initializer: nil)

        try codeGenerator?.handleLocalVariableDeclaration(statement: varStmt1)
        
        XCTAssertThrowsError(try codeGenerator?.handleLocalVariableDeclaration(statement: varStmt2)) { error in
            guard let compilerError = error as? CompilerError else {
                return XCTFail("Expected CompilerError.variableRedeclaration")
            }
            if case .variableRedeclaration(let name) = compilerError {
                XCTAssertEqual(name, "duplicateVar")
            } else {
                XCTFail("Incorrect error type")
            }
        }
    }
    
    func testLocalVariableScopeIsolation() throws {
        
        let tokenOuter = Token(type: .identifier, lexeme: "outerVar", line: 1)
        let varStmtOuter = VariableStatement(name: tokenOuter, initializer: nil)

        let tokenInner = Token(type: .identifier, lexeme: "innerVar", line: 2)
        let varStmtInner = VariableStatement(name: tokenInner, initializer: nil)

        try codeGenerator?.handleLocalVariableDeclaration(statement: varStmtOuter)
        
        codeGenerator?.beginScope()
        try codeGenerator?.handleLocalVariableDeclaration(statement: varStmtInner)
        XCTAssertEqual(codeGenerator?.locals.count, 2)

        codeGenerator?.line = tokenInner.line
        try? codeGenerator?.endScope()

        XCTAssertFalse(codeGenerator!.locals.contains { $0.name.lexeme == "innerVar" })
    }
    
    func testLocalVariableShadowing() throws {
        
        let outerToken = Token(type: .identifier, lexeme: "a", line: 1)
        let outerVarStmt = VariableStatement(name: outerToken, initializer: LiteralExpression(value: "outer"))
        
        let innerToken = Token(type: .identifier, lexeme: "a", line: 2)
        let innerVarStmt = VariableStatement(name: innerToken, initializer: LiteralExpression(value: "inner"))
        
        codeGenerator?.line = outerToken.line
        try codeGenerator?.handleLocalVariableDeclaration(statement: outerVarStmt)
        XCTAssertEqual(codeGenerator?.locals.count, 1)
        XCTAssertEqual(codeGenerator?.locals.last?.name.lexeme, "a")
        
        codeGenerator?.beginScope()
        
        codeGenerator?.line = innerToken.line
        try codeGenerator?.handleLocalVariableDeclaration(statement: innerVarStmt)
        XCTAssertEqual(codeGenerator?.locals.count, 2)
        XCTAssertEqual(codeGenerator?.locals.last?.name.lexeme, "a")
        
        try? codeGenerator?.endScope()
        
        XCTAssertEqual(codeGenerator?.locals.count, 1)
        XCTAssertEqual(codeGenerator?.locals.last?.name.lexeme, "a")
    }
    
    func testVisitVariableExpr_LocalVariable() throws {
        
        let token = Token(type: .identifier, lexeme: "localVar", line: 1)
        let varStmt = VariableStatement(name: token, initializer: LiteralExpression(value: 42))
        
        codeGenerator?.line = token.line
        try codeGenerator?.handleLocalVariableDeclaration(statement: varStmt)
        
        let varExpr = VariableExpression(name: token)
        
        XCTAssertNoThrow(try codeGenerator?.visitVariableExpr(varExpr))
    }
    
    func testVisitVariableExpr_GlobalVariable() throws {
        
        let token = Token(type: .identifier, lexeme: "globalVar", line: 1)
        let varStmt = VariableStatement(name: token, initializer: LiteralExpression(value: 42))
        
        codeGenerator?.line = token.line
        try codeGenerator?.handleGlobalVariableDeclaration(statement: varStmt)
        
        let varExpr = VariableExpression(name: token)
        
        XCTAssertNoThrow(try codeGenerator?.visitVariableExpr(varExpr))
    }
    
    func testVisitVariableExpr_AccessInOwnInitializer() throws {
        
        let token = Token(type: .identifier, lexeme: "localVar", line: 1)
        let varStmt = VariableStatement(name: token, initializer: VariableExpression(name: token))
        
        XCTAssertThrowsError(try codeGenerator?.handleLocalVariableDeclaration(statement: varStmt)) { error in
            guard let compilerError = error as? CompilerError else {
                return XCTFail("Expected CompilerError.variableAccessInOwnInitializer")
            }
            if case .variableAccessInOwnInitializer(let name) = compilerError {
                XCTAssertEqual(name, "localVar")
            } else {
                XCTFail("Incorrect error type")
            }
        }
    }
    
    func testVisitAssignExpr_LocalVariable() throws {
        
        let token = Token(type: .identifier, lexeme: "localVar", line: 1)
        let varStmt = VariableStatement(name: token, initializer: LiteralExpression(value: 42))
        
        codeGenerator?.line = token.line
        try codeGenerator?.handleLocalVariableDeclaration(statement: varStmt)
        
        let assignExpr = AssignExpression(name: token, value: LiteralExpression(value: 100))
        
        XCTAssertNoThrow(try codeGenerator?.visitAssignExpr(assignExpr))
    }
    
    func testVisitAssignExpr_GlobalVariable() throws {
        
        let token = Token(type: .identifier, lexeme: "globalVar", line: 1)
        let varStmt = VariableStatement(name: token, initializer: LiteralExpression(value: 42))
        
        codeGenerator?.line = token.line
        try codeGenerator?.handleGlobalVariableDeclaration(statement: varStmt)
        
        let assignExpr = AssignExpression(name: token, value: LiteralExpression(value: 100))
        
        XCTAssertNoThrow(try codeGenerator?.visitAssignExpr(assignExpr))
    }
    
    func testVisitAssignExpr_MissingOperand() throws {
        
        let token = Token(type: .identifier, lexeme: "localVar", line: 1)
        let varStmt = VariableStatement(name: token, initializer: LiteralExpression(value: 42))
        
        codeGenerator?.line = token.line
        try codeGenerator?.handleLocalVariableDeclaration(statement: varStmt)
        
        let assignExpr = AssignExpression(name: token, value: nil)
        
        XCTAssertThrowsError(try codeGenerator?.visitAssignExpr(assignExpr)) { error in
            guard let compilerError = error as? CompilerError else {
                return XCTFail("Expected CompilerError.missingOperand")
            }
            if case .missingOperand(let type, let line) = compilerError {
                XCTAssertEqual(type, "assignment")
                XCTAssertEqual(line, 1)
            } else {
                XCTFail("Incorrect error type")
            }
        }
    }
}
