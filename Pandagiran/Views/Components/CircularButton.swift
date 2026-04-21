

import Foundation

@IBDesignable class CircularButton : UIButton {
    
    
    
    override func prepareForInterfaceBuilder() {
        self.configure()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configure()
    }
    
    @IBInspectable override var tintColor: UIColor! {
        didSet {
            self.configure()
        }
    }
    
    private func configure() {
        layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
//        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor
    }
    
    
    
}

