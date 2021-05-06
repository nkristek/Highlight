internal extension Color {
    class var jsonOperatorColor: Color {
        Color { (style: UserInterfaceStyle) -> Color in
            switch style {
            case .dark:
                return Color(hue: 0, saturation: 0, brightness: 1, alpha: 0.85)
            default:
                return Color(hue: 0, saturation: 0, brightness: 0, alpha: 0.85)
            }
        }
    }
    
    class var jsonNumberColor: Color {
        Color { (style: UserInterfaceStyle) -> Color in
            switch style {
            case .dark:
                return Color(hue: 50/360, saturation: 0.49, brightness: 0.81, alpha: 1)
            default:
                return Color(hue: 248/360, saturation: 1, brightness: 0.81, alpha: 1)
            }
        }
    }
    
    class var jsonStringColor: Color {
        Color { (style: UserInterfaceStyle) -> Color in
            switch style {
            case .dark:
                return Color(hue: 5/360, saturation: 0.63, brightness: 0.99, alpha: 1)
            default:
                return Color(hue: 1/360, saturation: 0.89, brightness: 0.77, alpha: 1)
            }
        }
    }
    
    class var jsonLiteralColor: Color {
        Color { (style: UserInterfaceStyle) -> Color in
            switch style {
            case .dark:
                return Color(hue: 334/360, saturation: 0.62, brightness: 0.99, alpha: 1)
            default:
                return Color(hue: 304/360, saturation: 0.77, brightness: 0.61, alpha: 1)
            }
        }
    }

    class var jsonMemberKeyColor: Color {
        Color { (style: UserInterfaceStyle) -> Color in
            switch style {
            case .dark:
                return Color(hue: 234/360, saturation: 0.62, brightness: 0.99, alpha: 1)
            default:
                return Color(hue: 204/360, saturation: 0.77, brightness: 0.61, alpha: 1)
            }
        }
    }
}
