

import Foundation

class Style {
    static let color = Color()
    static let font = Font()
    static let dimen = Dimensions()
}

struct Color {
    // theme colors
//    let PRIMARY_COLOR = "#39afa7"
//    let SECONDARY_COLOR = "#2a7c8a"
    let PRIMARY_COLOR = "#3e4040"//"#39afa7"
    let SECONDARY_COLOR = "#0a0a0a"//"#2a7c8a"
    
    // views colors
    let DARK_GRAY = "#555c64"
    let LIGHT_GRAY = "#a5a9ae"
    let BLACK_LIGHT = "#202833"
    
    // text colors
    let DARK_TEXT = "#555c64"
    let LIGHT_TEXT = "#a5a9ae"
    let THEME_TEXT = "2a7c8a"
    let BLACK_TEXT = "#202833"
}

struct Font {
    let HEADING_FONT = "Montserrat"
    let REGULAR_FONT = "Lato"
    
    enum FontStyle: String {
        case bold = "Bold"
        case regular = "Regular"
    }
    
    public func getFont (fontName: String, withStyle fontStyle: FontStyle) -> String {
        return "\(fontName)-\(fontStyle)"
    }
}

struct Dimensions {
    // text sizes
    let XL_TEXT: CGFloat = 32.0
    let LARGE_TEXT: CGFloat = 22.0
    let REGULAR_TEXT: CGFloat = 14.0
    let HEADING_TEXT: CGFloat = 16.0
    let SMALL_TEXT: CGFloat = 12.0
    let XS_TEXT: CGFloat = 10.0
}
