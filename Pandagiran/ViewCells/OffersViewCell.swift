

import UIKit

class OffersViewCell: UICollectionViewCell {

    @IBOutlet weak var iv_offer: UIImageView!
    @IBOutlet weak var label_offer_title: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        setNeedsLayout()
//        layoutIfNeeded()
//        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
//        let screenWidth = UIScreen.main.bounds.width
//        let targetSize = CGSize(width: screenWidth / 3, height: 90)
//        
//        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
//        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
//        
//        // Assign the new size to the layout attributes
//        autoLayoutAttributes.frame = autoLayoutFrame
//        return autoLayoutAttributes
//    }

    
}
