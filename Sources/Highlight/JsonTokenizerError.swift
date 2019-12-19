import Foundation

public enum JsonTokenizerError: Error {
    case invalidSymbol(expected: Character?, actual: Character?)
    case expectedSymbol
    case unexpectedSymbol(description: String)
    case unenclosedQuotationMarks
    case invalidProperty
}
