

import UIKit

class AddAccountViewCell: UICollectionViewCell {

    @IBOutlet weak var label_add: UILabel!
    @IBOutlet weak var label_account: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        label_add.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_account.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
    }

    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let screenWidth = UIScreen.main.bounds.width
        let targetSize = CGSize(width: 100, height: 150)
        
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        
        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}
