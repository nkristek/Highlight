import Foundation

public struct JsonTokenizer: Tokenizer {
    public typealias TToken = JsonToken
    
    public func tokenize(_ text: String) -> [JsonToken] {
        parseElement(StringParser(string: text as NSString))
    }
    
    // MARK: - Parsing
    
    private func parseElement(_ parser: StringParser) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        tokens.compactAppend(parseWhitespace(parser))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens += parseValue(parser)
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens.compactAppend(parseWhitespace(parser))
        return tokens
    }
    
    private func parseWhitespace(_ parser: StringParser) -> JsonToken? {
        if let (_, range) = parser.scanCharacters(from: .whitespacesAndNewlines) {
            return .whitespace(range)
        }
        return nil
    }
    
    private func parseValue(_ parser: StringParser) -> [JsonToken] {
        var range = NSRange(location: parser.currentIndex, length: 0)
        
        guard let nextCharacter = parser.peekNextCharacter() else {
            range.length = parser.currentIndex - range.location
            return [ .unknown(range, .expectedSymbol) ]
        }
        
        switch nextCharacter {
        case "{":
            return parseObject(parser)
        case "[":
            return parseArray(parser)
        case "\"":
            return [ parseString(parser) ]
        case "0"..."9", "-":
            return [ parseNumber(parser) ]
        case "t", "f", "n":
            return [ parseLiteral(parser) ]
        default:
            range.length = parser.currentIndex - range.location
            return [ .unknown(range, .unexpectedSymbol(description: "Expected the start of a value, got '\(nextCharacter)'")) ]
        }
    }
    
    private func parseObject(_ parser: StringParser) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        let openingCurlyBraceToken = parseSingleCharacterOperator(parser, expectedOperator: "{")
        tokens.append(openingCurlyBraceToken)
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        if parser.peekNextCharacter(afterCharactersFrom: .whitespacesAndNewlines) != "}" {
            tokens += parseMembers(parser, until: "}")
        } else {
            tokens.compactAppend(parseWhitespace(parser))
        }
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        let closingCurlyBraceToken = parseSingleCharacterOperator(parser, expectedOperator: "}")
        tokens.append(closingCurlyBraceToken)
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        return tokens
    }
    
    private func parseMembers(_ parser: StringParser, until terminator: Terminator) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        tokens += parseMember(parser)
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        while parser.peekNextCharacter() != terminator.endingCharacter {
            tokens.append(parseSingleCharacterOperator(parser, expectedOperator: ","))
            if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
                return tokens
            }
            
            tokens += parseMember(parser)
            if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
                return tokens
            }
        }
        return tokens
    }
    
    private func parseMember(_ parser: StringParser) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        tokens.compactAppend(parseWhitespace(parser))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens.append(parseString(parser))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens.compactAppend(parseWhitespace(parser))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens.append(parseSingleCharacterOperator(parser, expectedOperator: ":"))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens += parseElement(parser)
        return tokens
    }
    
    private func parseArray(_ parser: StringParser) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        tokens.append(parseSingleCharacterOperator(parser, expectedOperator: "["))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        if parser.peekNextCharacter(afterCharactersFrom: .whitespacesAndNewlines) != "]" {
            tokens += parseElements(parser, until: "]")
        } else {
            tokens.compactAppend(parseWhitespace(parser))
        }
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens.append(parseSingleCharacterOperator(parser, expectedOperator: "]"))
        return tokens
    }
    
    private func parseElements(_ parser: StringParser, until terminator: Terminator) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        tokens += parseElement(parser)
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        while parser.peekNextCharacter() != terminator.endingCharacter {
            tokens.append(parseSingleCharacterOperator(parser, expectedOperator: ","))
            if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
                return tokens
            }
            
            tokens += parseElement(parser)
            if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
                return tokens
            }
        }
        return tokens
    }
    
    private func parseString(_ parser: StringParser) -> JsonToken {
        var range = NSRange(location: parser.currentIndex, length: 0)
        
        let openingQuotationMarkPreview = parser.peekNextCharacter()
        if openingQuotationMarkPreview != "\"" {
            range.length = parser.currentIndex - range.location
            return .unknown(range, .invalidSymbol(expected: "\"", actual: openingQuotationMarkPreview))
        }
        guard parser.scanCharacter() != nil else {
            range.length = parser.currentIndex - range.location
            return .unknown(range, .expectedSymbol)
        }
        
        while true {
            guard parser.scanUpToCharacters(from: CharacterSet(charactersIn: "\"\\")) != nil else {
                range.length = parser.currentIndex - range.location
                return .unknown(range, .unenclosedQuotationMarks)
            }
            
            guard let nextCharacterPreview = parser.peekNextCharacter() else {
                range.length = parser.currentIndex - range.location
                return .unknown(range, .invalidSymbol(expected: "\"", actual: openingQuotationMarkPreview))
            }
            if nextCharacterPreview == "\"" {
                guard parser.scanCharacter() != nil else {
                    range.length = parser.currentIndex - range.location
                    return .unknown(range, .expectedSymbol)
                }
                break
            }
            if nextCharacterPreview == "\\" {
                guard parser.scanCharacter() != nil else {
                    range.length = parser.currentIndex - range.location
                    return .unknown(range, .expectedSymbol)
                }
                guard let (escapedCharacter, _) = parser.scanCharacter() else {
                    range.length = parser.currentIndex - range.location
                    return .unknown(range, .expectedSymbol)
                }
                switch escapedCharacter {
                case "\"", "\\", "/", "b", "f", "n", "r", "t":
                    break
                case "u":
                    let hex = Set<Character>(arrayLiteral:
                                             "0","1","2","3","4","5","6","7","8","9",
                                             "a","b","c","d","e","f",
                                             "A","B","C","D","E","F")
                    do {
                        try parseExpectedCharacter(parser, in: hex)
                        try parseExpectedCharacter(parser, in: hex)
                        try parseExpectedCharacter(parser, in: hex)
                        try parseExpectedCharacter(parser, in: hex)
                    } catch {
                        range.length = parser.currentIndex - range.location
                        return .unknown(range, error as? JsonTokenizerError ?? .unexpectedSymbol(description: "Error while parsing an escaped unicode symbol"))
                    }
                default:
                    range.length = parser.currentIndex - range.location
                    return .unknown(range, .unexpectedSymbol(description: "Escaped character can only be \" \\ / b f n r t u, got: \(String(escapedCharacter))"))
                }
            }
        }
        
        range.length = parser.currentIndex - range.location
        return .stringValue(range)
    }
    
    private func parseNumber(_ parser: StringParser) -> JsonToken {
        let indexBefore = parser.currentIndex
        do {
            try parseInteger(parser)
            try parseFraction(parser)
            try parseExponent(parser)
        } catch {
            let range = NSRange(location: indexBefore, length: parser.currentIndex - indexBefore)
            return .unknown(range, error as? JsonTokenizerError ?? .unexpectedSymbol(description: "Error while parsing a number"))
        }
        return .numericValue(NSRange(location: indexBefore, length: parser.currentIndex - indexBefore))
    }
    
    @discardableResult
    private func parseInteger(_ parser: StringParser) throws -> String {
        var integer = ""
        
        while true {
            guard let character = parser.peekNextCharacter() else {
                throw JsonTokenizerError.expectedSymbol
            }
            switch character {
            case "0":
                integer.append(character)
                parser.scanCharacter()
                if integer == "0" || integer == "-0" {
                    return integer
                }
            case "-":
                if !integer.isEmpty {
                    return integer
                }
                integer.append(character)
                parser.scanCharacter()
            case "1"..."9":
                integer.append(character)
                parser.scanCharacter()
            default:
                if integer.isEmpty {
                    throw JsonTokenizerError.unexpectedSymbol(description: "Expected digit, got: \(String(character))")
                }
                return integer
            }
        }
    }
    
    @discardableResult
    private func parseFraction(_ parser: StringParser) throws -> String {
        var fraction = ""
        
        if parser.peekNextCharacter() != "." {
            return fraction
        }
        guard let (dotCharacter, _) = parser.scanCharacter() else {
            throw JsonTokenizerError.expectedSymbol
        }
        fraction.append(dotCharacter)
        
        while true {
            guard let character = parser.peekNextCharacter() else {
                throw JsonTokenizerError.expectedSymbol
            }
            switch character {
            case "0"..."9":
                fraction.append(character)
                parser.scanCharacter()
            default:
                return fraction
            }
        }
    }
    
    @discardableResult
    private func parseExponent(_ parser: StringParser) throws -> String {
        var exponent = ""
        
        guard let eCharacterPreview = parser.peekNextCharacter() else {
            return exponent
        }
        if eCharacterPreview != "e" && eCharacterPreview != "E" {
            return exponent
        }
        exponent.append(eCharacterPreview)
        parser.scanCharacter()
        
        let signCharacterPreview = parser.peekNextCharacter()
        if signCharacterPreview == "+" || signCharacterPreview == "-" {
            exponent.append(signCharacterPreview!)
            parser.scanCharacter()
        }
        
        while true {
            guard let character = parser.peekNextCharacter() else {
                throw JsonTokenizerError.expectedSymbol
            }
            switch character {
            case "0"..."9":
                exponent.append(character)
                parser.scanCharacter()
            default:
                return exponent
            }
        }
    }
    
    private func parseLiteral(_ parser: StringParser) -> JsonToken {
        var range = NSRange(location: parser.currentIndex, length: 1)
        
        let firstCharacter = parser.peekNextCharacter()
        switch firstCharacter {
        case "t":
            guard parser.scanString("true") != nil else {
                range.length = parser.currentIndex - range.location
                return .unknown(range, .unexpectedSymbol(description: "Expected 'true'"))
            }
            range.length = parser.currentIndex - range.location
            return .literal(range)
        case "f":
            guard parser.scanString("false") != nil else {
                range.length = parser.currentIndex - range.location
                return .unknown(range, .unexpectedSymbol(description: "Expected 'false'"))
            }
            range.length = parser.currentIndex - range.location
            return .literal(range)
        case "n":
            guard parser.scanString("null") != nil else {
                range.length = parser.currentIndex - range.location
                return .unknown(range, .unexpectedSymbol(description: "Expected 'null'"))
            }
            range.length = parser.currentIndex - range.location
            return .literal(range)
        case nil:
            return .unknown(range, .expectedSymbol)
        default:
            return .unknown(range, .unexpectedSymbol(description: "Expected literal (true, false, null), got first character: \(String(firstCharacter!))"))
        }
    }
    
    // MARK: - Helper
    
    private func parseSingleCharacterOperator(_ parser: StringParser, expectedOperator: Character) -> JsonToken {
        var range = NSRange(location: parser.currentIndex, length: 0)
        do {
            try parseExpectedCharacter(parser, expectedCharacter: expectedOperator)
            range.length = parser.currentIndex - range.location
            return .operator(range)
        } catch {
            range.length = parser.currentIndex - range.location
            return .unknown(range, error as? JsonTokenizerError ?? JsonTokenizerError.invalidSymbol(expected: expectedOperator, actual: nil))
        }
    }
    
    @discardableResult
    private func parseExpectedCharacter(_ parser: StringParser, in characterSet: Set<Character>) throws -> Character {
        guard let (character, _) = parser.scanCharacter() else {
            throw JsonTokenizerError.expectedSymbol
        }
        guard characterSet.contains(character) else {
            throw JsonTokenizerError.unexpectedSymbol(description: "Character is not in the accepted character set (\(characterSet.description)), got: \(String(character))")
        }
        return character
    }
    
    @discardableResult
    private func parseExpectedCharacter(_ parser: StringParser, expectedCharacter: Character) throws -> Character {
        guard let (character, _) = parser.scanCharacter() else {
            throw JsonTokenizerError.invalidSymbol(expected: "\"", actual: nil)
        }
        if character != expectedCharacter {
            throw JsonTokenizerError.invalidSymbol(expected: expectedCharacter, actual: character)
        }
        return character
    }
}

fileprivate struct Terminator {
    public var endingCharacter: Character?
}

extension Terminator {
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
