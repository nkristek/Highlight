#if canImport(UIKit)

import UIKit
public typealias Color = UIColor

internal extension UIColor {
    convenience init(dynamicProvider: @escaping (UserInterfaceStyle) -> Color) {
        self.init { traitCollection -> Color in
            dynamicProvider(traitCollection.userInterfaceStyle == .dark ? .dark : .light)
        }
    }
}

#elseif canImport(AppKit)

import AppKit
public typealias Color = NSColor

fileprivate extension NSAppearance {
    var isDark: Bool {
        bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
}

internal extension Color {
    convenience init(dynamicProvider: @escaping (UserInterfaceStyle) -> Color) {
        self.init(name: nil) { appearance -> Color in
            dynamicProvider(appearance.isDark ? .dark : .light)
        }
    }
}

#endif

internal enum UserInterfaceStyle {
    case light
    case dark
}
