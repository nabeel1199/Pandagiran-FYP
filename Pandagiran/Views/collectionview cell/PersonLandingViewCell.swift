

import UIKit

class PersonLandingViewCell: UICollectionViewCell {

    @IBOutlet weak var label_person_name: UILabel!
    @IBOutlet weak var label_amount_desc: UILabel!
    @IBOutlet weak var btn_menu: UIButton!
    
    @IBOutlet weak var label_amount: UILabel!
    @IBOutlet weak var view_cell: CardView!
    @IBOutlet weak var bg_view: CardView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bg_view.backgroundColor = UIColor(patternImage: UIImage(named: "bg_card")!)
        
        label_person_name.regularFont(fontStyle: .bold, size: Style.dimen.SMALL_TEXT)
        label_amount_desc.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_amount.regularFont(fontStyle: .bold, size: Style.dimen.LARGE_TEXT)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let screenWidth = UIScreen.main.bounds.width
        let targetSize = CGSize(width: 200, height: 150)
        
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        
        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
//    public func configureWithItem (account: Account) {
//        let balance = account.openingbalance!
//        let title = account.title!
//        label_person_name.text = account.title!
//        label_amount.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: balance, decimal: LocalPrefs.getDecimalFormat()))"
//        
//        if balance == 0 {
//            label_amount_desc.text = "No Pendig debts"
//        } else if balance > 0 {
//            label_amount_desc.text = "\(title) owes you"
//        } else {
//            label_amount_desc.text = "You owe \(title)"
//        }
//    }

}
