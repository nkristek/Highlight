import Foundation

internal protocol StringScanner {
    var currentIndex: Int { get }
    
    var isAtEnd: Bool { get }
    
    var string: NSString { get }
    
    @discardableResult
    mutating func scanCharacter() -> (Character, NSRange)?
    
    @discardableResult
    mutating func scanCharacter(_ character: Character) -> NSRange?
    
    @discardableResult
    mutating func scanCharacter(from set: CharacterSet) -> (Character, NSRange)?
    
    @discardableResult
    mutating func scanCharacters(from set: CharacterSet) -> (String, NSRange)?
    
    @discardableResult
    mutating func scanCharacters(until terminator: Terminator) -> (String, NSRange)?
    
    @discardableResult
    mutating func scanUpToCharacters(from set: CharacterSet) -> (String, NSRange)?
    
    @discardableResult
    mutating func scanString(_ string: String) -> NSRange?
    
    func peekCharacter() -> (Character, NSRange)?
    
    func peekCharacter(_ character: Character) -> NSRange?
    
    func peekCharacter(from set: CharacterSet) -> (Character, NSRange)?
    
    func peekCharacters(from set: CharacterSet) -> (String, NSRange)?
    
    func peekCharacters(until terminator: Terminator) -> (String, NSRange)?
    
    func peekUpToCharacters(from set: CharacterSet) -> (String, NSRange)?
    
    func peekString(_ string: String) -> NSRange?
    
    func peekCharacter(afterCharactersFrom characterSet: CharacterSet) -> (Character, NSRange)?
}
