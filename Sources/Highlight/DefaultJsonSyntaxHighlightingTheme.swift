import Foundation
import CoreGraphics

public struct DefaultJsonSyntaxHighlightingTheme: JsonSyntaxHighlightingTheme {
    
    public init(fontSize size: CGFloat = 13) {
        whitespaceFont = .monospacedSystemFont(ofSize: size, weight: .medium)
        operatorFont = .monospacedSystemFont(ofSize: size, weight: .medium)
        numericValueFont = .monospacedSystemFont(ofSize: size, weight: .medium)
        stringValueFont = .monospacedSystemFont(ofSize: size, weight: .medium)
        literalFont = .monospacedSystemFont(ofSize: size, weight: .bold)
        unknownFont = .monospacedSystemFont(ofSize: size, weight: .medium)
    }

    public var memberKeyColor: Color = .jsonMemberKeyColor
    
    public var whitespaceColor: Color = .jsonOperatorColor
    
    public var whitespaceFont: Font
    
    public var operatorColor: Color = .jsonOperatorColor
    
    public var operatorFont: Font
    
    public var numericValueColor: Color = .jsonNumberColor
    
    public var numericValueFont: Font
    
    public var stringValueColor: Color = .jsonStringColor
    
    public var stringValueFont: Font
    
    public var literalColor: Color = .jsonLiteralColor
    
    public var literalFont: Font
    
    public var unknownColor: Color = .jsonOperatorColor
    
    public var unknownFont: Font
}
