

import Foundation
import UIKit

class GradientButton: UIButton {
    private var colors = ["#FF000000" , "#FFFFFFFF"]
    
    @IBInspectable var isBorderVisible : Bool = false
    @IBInspectable var borderWith : CGFloat = 2
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.configure()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        self.configure()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configure()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.configure()
    }
    
    
    private func configure() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.cornerRadius
        
        if isBorderVisible {
            self.layer.borderWidth = self.borderWith
            self.layer.borderColor = self.borderColor.cgColor
        }
    }
}
