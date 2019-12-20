import Foundation

/// A syntax highlighter which supports highlighting JSON data
open class JsonSyntaxHighlightProvider: SyntaxHighlightProvider {
    
    /// A static instance of this provider
    public static let shared: JsonSyntaxHighlightProvider = JsonSyntaxHighlightProvider()
    
    /// Initialize an instance of the `JsonSyntaxHighlightProvider` class  with a theme
    public init(theme: JsonSyntaxHighlightingTheme? = nil) {
        self.theme = theme ?? DefaultJsonSyntaxHighlightingTheme()
    }
    
    /// The theme which will be used to highlight the JSON data
    open var theme: JsonSyntaxHighlightingTheme
    
    /// Modify the given `NSMutableAttributedString` to be highlighted according to the syntax.
    ///
    /// - parameters:
    ///   - attributedText:      The `NSMutableAttributedString` that should be highlighted.
    ///   - syntaxIdentifier:        The syntax that should be used to highlight the given `String`
    open func highlight(_ attributedText: NSMutableAttributedString, as syntax: Syntax) {
        guard case .json = syntax else {
            debugPrint("Highlighting '\(syntax)' is not supported. Supported ones are: 'json'")
            return
        }
        
        attributedText.addAttributes([ .foregroundColor : theme.unknownColor, .font : theme.unknownFont ], range: NSRange(location: 0, length: attributedText.length))
        
        let theme = self.theme

        let tokenizer = JsonTokenizer()
        let tokens = tokenizer.tokenize(attributedText.string)
        for token in tokens {
            switch token {
            case .whitespace(let range):
                attributedText.setAttributes([ .foregroundColor : theme.whitespaceColor, .font : theme.whitespaceFont], range: range)
            case .operator(let range):
                attributedText.setAttributes([ .foregroundColor : theme.operatorColor, .font : theme.operatorFont ], range: range)
            case .stringValue(let range):
                attributedText.setAttributes([ .foregroundColor : theme.stringValueColor, .font : theme.stringValueFont ], range: range)
            case .numericValue(let range):
                attributedText.setAttributes([ .foregroundColor : theme.numericValueColor, .font : theme.numericValueFont ], range: range)
            case .literal(let range):
                attributedText.setAttributes([ .foregroundColor : theme.literalColor, .font : theme.literalFont ], range: range)
            case .unknown(_, _):
                return
            }

        }
    }
}




