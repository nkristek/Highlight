import Foundation

public protocol Tokenizer {
    associatedtype TToken
    
    func tokenize(_ text: String) -> [TToken]
}
