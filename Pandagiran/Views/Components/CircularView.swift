

import UIKit

class CircularView: UIView {
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 2
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.3


    
    override func layoutSubviews() {
        layer.cornerRadius = layer.frame.size.height/2
        layer.cornerRadius = layer.frame.size.width / 2
        //        view.clipsToBounds = true
        
        //        layer.borderColor = (UIColor.black as! CGColor)
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
        
       
    }
}
