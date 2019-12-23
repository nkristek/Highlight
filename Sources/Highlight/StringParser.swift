import Foundation

internal struct StringParser: StringScanner {
    
    internal var currentIndex: Int
    
    internal var isAtEnd: Bool {
        currentIndex >= string.length
    }
    
    internal private(set) var string: NSString
    
    internal init(string: NSString) {
        self.string = string
        self.currentIndex = 0
    }
    
    @discardableResult
    internal mutating func scanCharacter() -> (Character, NSRange)? {
        guard let (nextCharacterPreview, nextCharacterRange) = peekCharacter() else { return nil }
        currentIndex += nextCharacterRange.length
        return (nextCharacterPreview, nextCharacterRange)
    }
    
    @discardableResult
    internal mutating func scanCharacter(_ character: Character) -> NSRange? {
        guard let characterRange = peekCharacter(character) else { return nil }
        currentIndex += characterRange.length
        return characterRange
    }
    
    @discardableResult
    internal mutating func scanCharacter(from set: CharacterSet) -> (Character, NSRange)? {
        guard let (characterPreview, characterRange) = peekCharacter(from: set) else { return nil }
        currentIndex += characterRange.length
        return (characterPreview, characterRange)
    }
    
    @discardableResult
    internal mutating func scanCharacters(from set: CharacterSet) -> (String, NSRange)? {
        guard let (charactersPreview, charactersRange) = peekCharacters(from: set) else { return nil }
        currentIndex += charactersRange.length
        return (charactersPreview, charactersRange)
    }
    
    @discardableResult
    internal mutating func scanCharacters(until terminator: Terminator) -> (String, NSRange)? {
        guard let (charactersPreview, charactersRange) = peekCharacters(until: terminator) else { return nil }
        currentIndex += charactersRange.length
        return (charactersPreview, charactersRange)
    }
    
    @discardableResult
    internal mutating func scanUpToCharacters(from set: CharacterSet) -> (String, NSRange)? {
        guard let (charactersPreview, charactersRange) = peekUpToCharacters(from: set) else { return nil }
        currentIndex += charactersRange.length
        return (charactersPreview, charactersRange)
    }
    
    @discardableResult
    internal mutating func scanString(_ searchString: String) -> NSRange? {
        guard let stringRange = peekString(searchString) else { return nil }
        currentIndex += stringRange.length
        return stringRange
    }
    
    internal func peekCharacter() -> (Character, NSRange)? {
        guard !isAtEnd else { return nil }
        let rangeOfNextCharacter = string.rangeOfComposedCharacterSequence(at: currentIndex)
        let charString = string.substring(with: rangeOfNextCharacter)
        guard
            charString.count == 1,
            let char = charString.first
        else { return nil }
        return (char, rangeOfNextCharacter)
    }
    
    internal func peekCharacter(_ character: Character) -> NSRange? {
        guard !isAtEnd else { return nil }
        let rangeOfNextCharacter = string.rangeOfComposedCharacterSequence(at: currentIndex)
        let charString = string.substring(with: rangeOfNextCharacter)
        guard
            charString.count == 1,
            let char = charString.first,
            char == character
        else { return nil }
        return rangeOfNextCharacter
    }
    
    internal func peekCharacter(from set: CharacterSet) -> (Character, NSRange)? {
        guard !isAtEnd else { return nil }
        let rangeOfNextCharacter = string.rangeOfComposedCharacterSequence(at: currentIndex)
        let charString = string.substring(with: rangeOfNextCharacter)
        guard
            charString.count == 1,
            let char = charString.first,
            char.unicodeScalars.allSatisfy({ set.contains($0) })
        else { return nil }
        return (char, rangeOfNextCharacter)
    }
    
    internal func peekCharacters(from set: CharacterSet) -> (String, NSRange)? {
        guard !isAtEnd else { return nil }
        let indexBefore = currentIndex
        var result = ""
        var index = currentIndex
        
        while index < string.length {
            let rangeOfNextCharacter = string.rangeOfComposedCharacterSequence(at: index)
            let charString = string.substring(with: rangeOfNextCharacter)
            guard
                charString.count == 1,
                let char = charString.first,
                char.unicodeScalars.allSatisfy({ set.contains($0) })
            else { break }
            index += rangeOfNextCharacter.length
            result.append(char)
        }
        
        return index > indexBefore ? (result, NSRange(location: indexBefore, length: index - indexBefore)) : nil
    }
    
    func peekCharacters(until terminator: Terminator) -> (String, NSRange)? {
        guard !isAtEnd else { return nil }
        let indexBefore = currentIndex
        var result = ""
        var index = currentIndex
        
        while index < string.length {
            let rangeOfNextCharacter = string.rangeOfComposedCharacterSequence(at: index)
            let charString = string.substring(with: rangeOfNextCharacter)
            guard
                charString.count == 1,
                let char = charString.first,
                char != terminator.endingCharacter
            else { break }
            index += rangeOfNextCharacter.length
            result.append(char)
        }
        
        return index > indexBefore ? (result, NSRange(location: indexBefore, length: index - indexBefore)) : nil
    }
    
    internal func peekUpToCharacters(from set: CharacterSet) -> (String, NSRange)? {
        guard !isAtEnd else { return nil }
        let indexBefore = currentIndex
        var result = ""
        var index = currentIndex
        
        while index < string.length {
            let rangeOfNextCharacter = string.rangeOfComposedCharacterSequence(at: index)
            let charString = string.substring(with: rangeOfNextCharacter)
            guard
                charString.count == 1,
                let char = charString.first,
                !char.unicodeScalars.allSatisfy({ set.contains($0) })
                else { break }
            index += rangeOfNextCharacter.length
            result.append(char)
        }
        
        return index > indexBefore ? (result, NSRange(location: indexBefore, length: index - indexBefore)) : nil
    }
    
    internal func peekString(_ searchString: String) -> NSRange? {
        let nsSearchStringLength = (searchString as NSString).length
        guard currentIndex + nsSearchStringLength <= string.length else { return nil }
        let searchRange = NSRange(location: currentIndex, length: nsSearchStringLength)
        let scannedString = string.substring(with: searchRange)
        guard scannedString == searchString else { return nil }
        return searchRange
    }
    
    internal func peekCharacter(afterCharactersFrom set: CharacterSet) -> (Character, NSRange)? {
        guard
            let (_, rangeOfExcludedCharacters) = peekCharacters(from: set),
            rangeOfExcludedCharacters.location + rangeOfExcludedCharacters.length < string.length
        else { return nil }
        let rangeOfNextCharacter = string.rangeOfComposedCharacterSequence(at: rangeOfExcludedCharacters.location + rangeOfExcludedCharacters.length)
        let charString = string.substring(with: rangeOfNextCharacter)
        guard
            charString.count == 1,
            let char = charString.first
        else { return nil }
        return (char, rangeOfNextCharacter)
    }
}
