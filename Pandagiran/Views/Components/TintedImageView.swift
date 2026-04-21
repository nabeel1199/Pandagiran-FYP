

import Foundation

@IBDesignable class TintedImageView: UIImageView {
    
    
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
        self.image = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
    }
}
