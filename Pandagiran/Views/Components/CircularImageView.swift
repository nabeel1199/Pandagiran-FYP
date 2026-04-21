

import Foundation

@IBDesignable class CircularImageView : UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var borderColor = UIColor.black
    @IBInspectable var circularBorder: Bool = false
    
    override func prepareForInterfaceBuilder() {
        self.configure()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    private func configure() {
        layer.masksToBounds = false
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = self.frame.size.height/2
        clipsToBounds = true
        
        if circularBorder {
            layer.borderColor = UIColor.groupTableViewBackground.cgColor
            layer.borderWidth = 1.0
            
        }

    }
}
