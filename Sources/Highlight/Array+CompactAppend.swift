import Foundation

internal extension Array {
    mutating func compactAppend(_ element: Element?) {
        if let element = element {
            append(element)
        }
    }
}
