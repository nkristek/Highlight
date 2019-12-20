/// Provides colors and fonts for displaying highlighted JSON data
public protocol JsonSyntaxHighlightingTheme {
    
    // MARK: - Whitespace
    
    /// The color for whitespace
    var whitespaceColor: Color { get }
    
    /// The font for whitespace
    var whitespaceFont: Font { get }
    
    // MARK: - Operators
    
    /// The color for operators like '{', '[' or ':'
    var operatorColor: Color { get }
    
    /// The font for operators like '{', '[' or ':'
    var operatorFont: Font { get }
    
    // MARK: - Numeric values
    
    /// The color for numbers
    var numericValueColor: Color { get }
    
    /// The color for numbers
    var numericValueFont: Font { get }
    
    // MARK: - String values
    
    /// The color for string values
    var stringValueColor: Color { get }
    
    /// The font for string values
    var stringValueFont: Font { get }
    
    // MARK: - Literals
    
    /// The color for literals like 'true', 'false' or 'null'
    var literalColor: Color { get }
    
    /// The font for literals like 'true', 'false' or 'null'
    var literalFont: Font { get }
    
    /// The color for text which could not be parsed correctly
    var unknownColor: Color { get }
    
    /// The font for text which could not be parsed correctly
    var unknownFont: Font { get }
}
