//
//  Opcode.swift
//  
//
//  Created by Michael Borgmann on 14/12/2023.
//

import Foundation

/// A protocol representing an opcode used in a virtual machine.
///
/// Conforming types must provide a name property.
public protocol Opcode: RawRepresentable where RawValue == UInt8 {
    
    /// The name of the opcode.
    var name: String { get }
}

/// An enumeration of opcodes for the SCUMM virtual machine.
///
/// Each case corresponds to a specific operation or instruction in the SCUMM bytecode.
public enum ScummOpcode: UInt8, CaseIterable, Opcode {
    
    /// Represents a breakpoint instruction.
    case breakHere  = 0x80
    
    /// Represents an expression instruction.
    case expression = 0xac
    
    /// The name of the opcode.
    public var name: String {
        return "OP_" + String(describing: self).lowercased()
    }
}

/// An enumeration of opcodes for the Mojo virtual machine.
///
/// Each case corresponds to a specific operation or instruction in the Mojo bytecode.
public enum MojoOpcode: UInt8, CaseIterable, Opcode {
    
    /// Represents an addition operation.
    case add            = 0xf0
    
    /// Represents a subtraction operation.
    case subtract       = 0xf1
    
    /// Represents a multiplication operation.
    case multiply       = 0xf2
    
    /// Represents a division operation.
    case divide         = 0xf3
    
    /// Represents a return instruction.
    case `return`       = 0xf4
    
    /// Represents a constant instruction.
    case constant       = 0xf5
    
    /// Represents a negation operation.
    case negate         = 0xf6
    
    /// Represents a logical NOT operation.
    case not            = 0xf7
    
    /// Represents a `nil` literal.
    case `nil`          = 0xf8
    
    /// Represents a `true` literal.
    case `true`         = 0xf9
    
    /// Represents a `false` literal.
    case `false`        = 0xfa
    
    /// Represents an equality comparison operation.
    case equal          = 0xfb
    
    /// Represents a greater-than comparison operation.
    case greater        = 0xfc
    
    /// Represents a less-than comparison operation.
    case less           = 0xfd
    
    /// Represents a print instruction.
    case print          = 0xfe
    
    /// Represents a pop operation (removes an item from the stack).
    case pop            = 0xff
    
    /// Represents a global variable instruction.
    case defineGlobal   = 0xef
    
    /// Represents an instruction to get a global variable's value.
    case getGlobal      = 0xee
    
    /// Represents an instruction to set a global variable's value.
    case setGlobal      = 0xed
    
    /// Represents an instruction to retrieve the value of a local variable.
    case getLocal       = 0xec
    
    /// Represents an instruction to assign a value to a local variable.
    case setLocal       = 0xeb
    
    /// The name of the opcode.
    public var name: String {
        return "OP_" + String(describing: self).lowercased()
    }
}
