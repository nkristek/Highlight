#if canImport(UIKit)

import UIKit
public typealias Font = UIFont

#elseif canImport(AppKit)

import AppKit
public typealias Font = NSFont

#endif
