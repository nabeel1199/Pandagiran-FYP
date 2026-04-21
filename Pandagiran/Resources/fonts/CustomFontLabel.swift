

import Foundation


@IBDesignable
class CustomFontLabel: UILabel {
    private var colors = ["#FF3CB9AD" , "#FF1E576A"]
    
    

    
    @IBInspectable var labelType : Int = 1 {
        didSet {
            self.configure()
        }
    }
    
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
        if labelType == 0 {
            self.font = UIFont(name: "Montserrat", size: 16.0)
        } else if labelType == 1 {
            self.font = UIFont(name: "Montserrat", size: 16.0)
        } else {
            
        }
        
    
    }
}
