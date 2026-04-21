

import Foundation

extension UILabel {
    
    func regularFont(fontStyle: Font.FontStyle, size: CGFloat) {
        self.font = UIFont(name: "\(Style.font.REGULAR_FONT)-\(fontStyle.rawValue)", size: size)
    }
    
    func headingFont(fontStyle: Font.FontStyle, size: CGFloat) {
        self.font = UIFont(name: "\(Style.font.HEADING_FONT)-\(fontStyle.rawValue)", size: size)
    }
}

extension UIButton {
    
    func regularFont(fontStyle: Font.FontStyle, size: CGFloat) {
        self.titleLabel?.font = UIFont(name: "\(Style.font.REGULAR_FONT)-\(fontStyle.rawValue)", size: size)
    }
    
    func headingFont(fontStyle: Font.FontStyle, size: CGFloat) {
        self.titleLabel?.font = UIFont(name: "\(Style.font.HEADING_FONT)-\(fontStyle.rawValue)", size: size)
    }
}

extension UITextField {
    func regularFont(fontStyle: Font.FontStyle, size: CGFloat) {
        self.font = UIFont(name: "\(Style.font.REGULAR_FONT)-\(fontStyle.rawValue)", size: size)
    }
}

extension UIColor {
    // converts hex code into UIColor
    func hexCode (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        
        // Swift 4.2 and above
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        
        // Swift 4.1 and below
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
}
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}
extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
    var html2String: String {
        html2AttributedString?.string ?? ""
    }
}

