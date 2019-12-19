import Foundation

internal class StringParser {
    
    internal var currentIndex: Int
    
    internal private(set) var string: NSString
    
    internal init(string: NSString) {
        self.string = string
        self.currentIndex = 0
    }
    
    // MARK: - Scanning
    
    @discardableResult
    internal func scanCharacter() -> (Character, NSRange)? {
        if currentIndex >= string.length {
            return nil
        }
        let range = NSRange(location: currentIndex, length: 1)
        let charString = string.substring(with: range)
        guard charString.count == 1 else {
            return nil
        }
        guard let char = charString.first else {
            return nil
        }
        currentIndex += charString.utf16.count
        return (char, range)
    }
    
    @discardableResult
    internal func scanCharacters(from set: CharacterSet) -> (String, NSRange)? {
        let indexBefore = currentIndex
        var resultRange = NSRange(location: indexBefore, length: 0)
        var result = ""
        while currentIndex < string.length {
            let range = NSRange(location: currentIndex, length: 1)
            let charString = string.substring(with: range)
            guard
                charString.count == 1,
                charString.unicodeScalars.allSatisfy({ set.contains($0) }),
                let char = charString.first
            else {
                resultRange.length = currentIndex - indexBefore
                return resultRange.length > 0 ? (result, resultRange) : nil
            }
            
            currentIndex += charString.utf16.count
            result.append(char)
        }
        
        resultRange.length = currentIndex - indexBefore
        return resultRange.length > 0 ? (result, resultRange) : nil
    }
    
    @discardableResult
    internal func scanUpToCharacters(from set: CharacterSet) -> (String, NSRange)? {
        let indexBefore = currentIndex
        var resultRange = NSRange(location: indexBefore, length: 0)
        var result = ""
        while currentIndex < string.length {
            let range = NSRange(location: currentIndex, length: 1)
            let charString = string.substring(with: range)
            guard
                charString.count == 1,
                !charString.unicodeScalars.allSatisfy { set.contains($0) },
                let char = charString.first
            else {
                resultRange.length = currentIndex - indexBefore
                return resultRange.length > 0 ? (result, resultRange) : nil
            }
            
            currentIndex += charString.utf16.count
            result.append(char)
        }
        
        resultRange.length = currentIndex - indexBefore
        return resultRange.length > 0 ? (result, resultRange) : nil
    }
    
    @discardableResult
    internal func scanString(_ searchString: String) -> NSRange? {
        let nsSearchStringLength = (searchString as NSString).length
        guard currentIndex + nsSearchStringLength <= string.length else { return nil }
        let searchRange = NSRange(location: currentIndex, length: nsSearchStringLength)
        let scannedString = string.substring(with: searchRange)
        guard scannedString == searchString else { return nil }
        currentIndex += nsSearchStringLength
        return searchRange
    }
    
    // MARK: - Peeking
    
    internal func peekNextCharacter() -> Character? {
        if currentIndex >= string.length {
            return nil
        }
        let range = NSRange(location: currentIndex, length: 1)
        let charString = string.substring(with: range)
        guard
            charString.count == 1,
            let char = charString.first
        else { return nil }
        return char
    }
    
    internal func peekNextCharacter(afterCharactersFrom characterSet: CharacterSet) -> Character? {
        var index = currentIndex
        while index < string.length {
            let range = NSRange(location: index, length: 1)
            let charString = string.substring(with: range)
            
            if charString.count != 1 || !charString.unicodeScalars.allSatisfy({ characterSet.contains($0) }) {
                break
            }
            
            index += charString.lengthOfBytes(using: .utf16)
        }
        
        if index >= string.length {
            return nil
        }
        let range = NSRange(location: index, length: 1)
        let charString = string.substring(with: range)
        guard
            charString.count == 1,
            let char = charString.first
        else { return nil }
        return char
    }
}
