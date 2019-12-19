public struct DefaultJsonSyntaxHighlightingTheme: JsonSyntaxHighlightingTheme {
    
    public var whitespaceColor: Color = .jsonOperatorColor
    
    public var whitespaceFont: Font = .monospacedSystemFont(ofSize: 13, weight: .medium)
    
    public var operatorColor: Color = .jsonOperatorColor
    
    public var operatorFont: Font = .monospacedSystemFont(ofSize: 13, weight: .medium)
    
    public var numericValueColor: Color = .jsonNumberColor
    
    public var numericValueFont: Font = .monospacedSystemFont(ofSize: 13, weight: .medium)
    
    public var stringValueColor: Color = .jsonStringColor
    
    public var stringValueFont: Font = .monospacedSystemFont(ofSize: 13, weight: .medium)
    
    public var literalColor: Color = .jsonLiteralColor
    
    public var literalFont: Font = .monospacedSystemFont(ofSize: 13, weight: .bold)
}
