import Foundation

public struct JsonTokenizer: Tokenizer {
    public typealias TToken = JsonToken
    
    public init(behaviour: JsonTokenizerBehaviour) {
        self.behaviour = behaviour
    }
    
    public var behaviour: JsonTokenizerBehaviour
    
    public func tokenize(_ text: String) -> [JsonToken] {
        var scanner: StringScanner = StringParser(string: text as NSString)
        return parseElement(&scanner)
    }
    
    private func parseElement(_ scanner: inout StringScanner) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        tokens.compactAppend(parseWhitespace(&scanner))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens += parseValue(&scanner)
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens.compactAppend(parseWhitespace(&scanner))
        return tokens
    }
    
    private func parseWhitespace(_ scanner: inout StringScanner) -> JsonToken? {
        if let (_, range) = scanner.scanCharacters(from: .whitespacesAndNewlines) {
            return .whitespace(range)
        }
        return nil
    }
    
    private func parseValue(_ scanner: inout StringScanner) -> [JsonToken] {
        var range = NSRange(location: scanner.currentIndex, length: 0)
        
        guard let (nextCharacterPreview, _) = scanner.peekCharacter() else {
            return [ .unknown(range, .expectedSymbol) ]
        }
        
        switch nextCharacterPreview {
        case "{":
            return parseObject(&scanner)
        case "[":
            return parseArray(&scanner)
        case "\"":
            return [ parseString(&scanner) ]
        case "0"..."9", "-":
            return [ parseNumber(&scanner) ]
        case "t", "f", "n":
            return [ parseLiteral(&scanner) ]
        default:
            range.length = 1
            return [ .unknown(range, .unexpectedSymbol(description: "Expected the start of a value, got '\(nextCharacterPreview)'")) ]
        }
    }
    
    private func parseObject(_ scanner: inout StringScanner) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        let openingCurlyBraceToken = parseOperator(&scanner, operator: "{")
        tokens.append(openingCurlyBraceToken)
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        if let (characterAfterWhitespacePreview, _) = scanner.peekCharacter(afterCharactersFrom: .whitespacesAndNewlines), characterAfterWhitespacePreview != "}" {
            tokens += parseMembers(&scanner, until: "}")
        } else {
            tokens.compactAppend(parseWhitespace(&scanner))
        }
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        let closingCurlyBraceToken = parseOperator(&scanner, operator: "}")
        tokens.append(closingCurlyBraceToken)
        return tokens
    }
    
    private func parseMembers(_ scanner: inout StringScanner, until terminator: Terminator) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        tokens += parseMember(&scanner)
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        while let (nextCharacterPreview, _) = scanner.peekCharacter(), nextCharacterPreview != terminator.endingCharacter {
            tokens.append(parseOperator(&scanner, operator: ","))
            if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
                return tokens
            }
            
            tokens += parseMember(&scanner)
            if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
                return tokens
            }
        }
        
        return tokens
    }
    
    private func parseMember(_ scanner: inout StringScanner) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        tokens.compactAppend(parseWhitespace(&scanner))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens.append(parseMemberKey(&scanner))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens.compactAppend(parseWhitespace(&scanner))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens.append(parseOperator(&scanner, operator: ":"))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens += parseElement(&scanner)
        return tokens
    }
    
    private func parseArray(_ scanner: inout StringScanner) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        tokens.append(parseOperator(&scanner, operator: "["))
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        if let (nextCharacterPreview, _) = scanner.peekCharacter(afterCharactersFrom: .whitespacesAndNewlines), nextCharacterPreview != "]" {
            tokens += parseElements(&scanner, until: "]")
        } else {
            tokens.compactAppend(parseWhitespace(&scanner))
        }
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        tokens.append(parseOperator(&scanner, operator: "]"))
        return tokens
    }
    
    private func parseElements(_ scanner: inout StringScanner, until terminator: Terminator) -> [JsonToken] {
        var tokens = [JsonToken]()
        
        tokens += parseElement(&scanner)
        if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
            return tokens
        }
        
        while let (nextCharacterPreview, _) = scanner.peekCharacter(), nextCharacterPreview != terminator.endingCharacter {
            tokens.append(parseOperator(&scanner, operator: ","))
            if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
                return tokens
            }
            
            tokens += parseElement(&scanner)
            if let lastToken = tokens.last, case JsonToken.unknown(_, _) = lastToken {
                return tokens
            }
        }
        return tokens
    }

    private func parseMemberKey(_ scanner: inout StringScanner) -> JsonToken {
        let token = parseString(&scanner)
        if case .stringValue(let range) = token {
            return .memberKey(range)
        }
        return token
    }
    
    private func parseString(_ scanner: inout StringScanner) -> JsonToken {
        var range = NSRange(location: scanner.currentIndex, length: 0)
        
        guard scanner.scanCharacter("\"") != nil else {
            range.length = 1
            if let (nextCharacter, _) = scanner.peekCharacter() {
                return .unknown(range, .invalidSymbol(expected: "\"", actual: nextCharacter))
            }
            return .unknown(range, .invalidSymbol(expected: "\"", actual: nil))
        }
        
        while !scanner.isAtEnd {
            scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "\"\\"))
            
            guard let (nextCharacter, _) = scanner.scanCharacter() else {
                range.length = scanner.currentIndex - range.location
                return .unknown(range, .unenclosedQuotationMarks)
            }
            if nextCharacter == "\"" {
                break
            } else if nextCharacter == "\\" {
                // next character should be escaped
                guard let (escapedCharacter, _) = scanner.scanCharacter() else {
                    range.length = scanner.currentIndex - range.location
                    return .unknown(range, .expectedSymbol)
                }
                switch escapedCharacter {
                case "\"", "\\", "/", "b", "f", "n", "r", "t":
                    break
                case "u":
                    let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
                    guard
                        scanner.scanCharacter(from: hexCharacterSet) != nil,
                        scanner.scanCharacter(from: hexCharacterSet) != nil,
                        scanner.scanCharacter(from: hexCharacterSet) != nil,
                        scanner.scanCharacter(from: hexCharacterSet) != nil
                    else {
                        range.length = scanner.currentIndex - range.location
                        return .unknown(range, .unexpectedSymbol(description: "Error while parsing an escaped unicode symbol"))
                    }
                default:
                    range.length = scanner.currentIndex - range.location
                    return .unknown(range, .unexpectedSymbol(description: "Escaped character can only be \" \\ / b f n r t u, got: \(String(escapedCharacter))"))
                }
            } else {
                range.length = scanner.currentIndex - range.location
                return .unknown(range, .unenclosedQuotationMarks)
            }
        }
        
        range.length = scanner.currentIndex - range.location
        return .stringValue(range)
    }
    
    private func parseNumber(_ scanner: inout StringScanner) -> JsonToken {
        let indexBefore = scanner.currentIndex
        do {
            try parseInteger(&scanner)
            try parseFraction(&scanner)
            try parseExponent(&scanner)
        } catch {
            let range = NSRange(location: indexBefore, length: scanner.currentIndex - indexBefore)
            return .unknown(range, error as? JsonTokenizerError ?? .unexpectedSymbol(description: "Error while parsing a number"))
        }
        return .numericValue(NSRange(location: indexBefore, length: scanner.currentIndex - indexBefore))
    }
    
    @discardableResult
    private func parseInteger(_ scanner: inout StringScanner) throws -> String {
        var integer = ""
        
        while true {
            guard let (characterPreview, _) = scanner.peekCharacter() else {
                throw JsonTokenizerError.expectedSymbol
            }
            switch characterPreview {
            case "0":
                integer.append(characterPreview)
                scanner.scanCharacter()
                if integer == "0" || integer == "-0" {
                    return integer
                }
            case "-":
                if !integer.isEmpty {
                    return integer
                }
                integer.append(characterPreview)
                scanner.scanCharacter()
            case "1"..."9":
                integer.append(characterPreview)
                scanner.scanCharacter()
            default:
                if integer.isEmpty {
                    throw JsonTokenizerError.unexpectedSymbol(description: "Expected digit, got: \(String(characterPreview))")
                }
                return integer
            }
        }
    }
    
    @discardableResult
    private func parseFraction(_ scanner: inout StringScanner) throws -> String {
        var fraction = ""
        
        guard scanner.scanCharacter(".") != nil else {
            return fraction
        }
        fraction.append(".")
        
        while true {
            guard let (characterPreview, _) = scanner.peekCharacter() else {
                throw JsonTokenizerError.expectedSymbol
            }
            switch characterPreview {
            case "0"..."9":
                fraction.append(characterPreview)
                scanner.scanCharacter()
            default:
                return fraction
            }
        }
    }
    
    @discardableResult
    private func parseExponent(_ scanner: inout StringScanner) throws -> String {
        var exponent = ""
        
        guard let (eCharacter, _) = scanner.scanCharacter(from: CharacterSet(charactersIn: "eE")) else {
            return exponent
        }
        exponent.append(eCharacter)
        
        if let (signCharacter, _) = scanner.scanCharacter(from: CharacterSet(charactersIn: "+-")) {
            exponent.append(signCharacter)
        }
        
        while true {
            guard let (characterPreview, _) = scanner.peekCharacter() else {
                throw JsonTokenizerError.expectedSymbol
            }
            switch characterPreview {
            case "0"..."9":
                exponent.append(characterPreview)
                scanner.scanCharacter()
            default:
                return exponent
            }
        }
    }
    
    private func parseLiteral(_ scanner: inout StringScanner) -> JsonToken {
        if let range = scanner.scanString("true") {
            return .literal(range)
        } else if let range = scanner.scanString("false") {
            return .literal(range)
        } else if let range = scanner.scanString("null") {
            return .literal(range)
        } else {
            return .unknown(NSRange(location: scanner.currentIndex, length: 0), .unexpectedSymbol(description: "Expected literal like 'true', 'false' or 'null'"))
        }
    }
    
    private func parseOperator(_ scanner: inout StringScanner, operator: Character) -> JsonToken {
        guard let range = scanner.scanCharacter(`operator`) else {
            return .unknown(NSRange(location: scanner.currentIndex, length: 0), .invalidSymbol(expected: `operator`, actual: nil))
        }
        return .operator(range)
    }
}
