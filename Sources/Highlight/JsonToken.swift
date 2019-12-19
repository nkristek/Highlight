import Foundation

/// A specific part of JSON data with the associated value and location in the original data
public enum JsonToken {
    /// Whitespace
    case whitespace(NSRange)
    
    /// Operator like '{', '[' or ':'
    case `operator`(NSRange)
    
    /// String
    case stringValue(NSRange)
    
    /// Number
    case numericValue(NSRange)
    
    /// Literal like 'true', 'false' or 'null'
    case literal(NSRange)
    
    /// This will contain the range after the parsing failed with the associated error
    case unknown(NSRange, JsonTokenizerError)
}
