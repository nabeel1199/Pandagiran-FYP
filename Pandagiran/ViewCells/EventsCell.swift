

import UIKit

class EventsCell: UICollectionViewCell {

    @IBOutlet weak var label_event_name: UILabel!
    @IBOutlet weak var iv_event_name: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        // Specify you want _full width_
        let targetSize = CGSize(width: label_event_name.intrinsicContentSize.width + 48, height: 40)
        
        // Calculate the size (height) using Auto Layout
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        
        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }

}
