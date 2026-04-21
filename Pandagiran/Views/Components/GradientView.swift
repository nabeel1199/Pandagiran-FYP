

import Foundation



@IBDesignable class GradientView : UIView {
    
    private var colors = ["#FF000000" , "#FFFFFFFF"]
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.configure()
        }
    }
    
    @IBInspectable var isGradient : Bool = false {
        didSet {
            
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
        self.configure()
    }

    
    private func configure() {
       
        
        if isGradient {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = self.bounds
            gradient.colors = [Utils.hexStringToUIColor(hex: colors[0]).cgColor, Utils.hexStringToUIColor(hex: colors[1]).cgColor]
            //        gradient.locations = [0.3 , 1.0]
            gradient.startPoint = CGPoint(x: 0.0, y: 0)
            gradient.endPoint = CGPoint(x: 1.0, y: 0)
            self.layer.insertSublayer(gradient, at: 0)
            self.clipsToBounds = true
        } else {
            self.backgroundColor = UIColor.black
        }
        
        // corner radius
        self.layer.cornerRadius = self.cornerRadius
        
    }
}
