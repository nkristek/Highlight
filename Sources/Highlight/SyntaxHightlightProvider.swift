import Foundation

/// A provider for coloring/formatting text according to a specific syntax
public protocol SyntaxHighlightProvider {
    
    /// Create an attributed string from the given `String` which contains the highlighted text.
    ///
    /// - parameters:
    ///   - text:      The `String` that should be highlighted.
    ///   - syntaxIdentifier:        The syntax that should be used to highlight the given `String`
    func highlight(_ text: String, as syntax: Syntax) -> NSAttributedString
    
    /// Modify the given `NSMutableAttributedString` to be highlighted according to the syntax.
    ///
    /// - parameters:
    ///   - attributedText:      The `NSMutableAttributedString` that should be highlighted.
    ///   - syntaxIdentifier:        The syntax that should be used to highlight the given `String`
    func highlight(_ attributedText: NSMutableAttributedString, as syntax: Syntax)
}

public extension SyntaxHighlightProvider {
    func highlight(_ text: String, as syntax: Syntax) -> NSAttributedString {
        let result = NSMutableAttributedString(string: text)
        highlight(result, as: syntax)
        return result
    }
}
