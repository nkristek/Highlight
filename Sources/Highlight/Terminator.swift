import Foundation

internal struct Terminator {
    public var endingCharacter: Character?
}

internal extension Terminator {
    static var end: Terminator {
        return Terminator(endingCharacter: nil)
    }
}

extension Terminator: ExpressibleByUnicodeScalarLiteral {
    typealias UnicodeScalarLiteralType = Character
    
    init(unicodeScalarLiteral value: Character) {
        self.init(endingCharacter: value)
    }
}
