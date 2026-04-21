

import UIKit

class SavingDealViewCell: UICollectionViewCell {

    @IBOutlet weak var label_deal_title: UILabel!
    @IBOutlet weak var label_percent_off: UILabel!
    @IBOutlet weak var label_amount_before: UILabel!
    @IBOutlet weak var label_amount_now: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        label_percent_off.regularFont(fontStyle: .bold, size: Style.dimen.SMALL_TEXT)
        
        label_deal_title.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        
        label_amount_before.regularFont(fontStyle: .regular, size: Style.dimen.SMALL_TEXT)
        
        label_amount_now.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
    }

}
