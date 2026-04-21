

import UIKit

class MonthsViewCell: UICollectionViewCell {

    @IBOutlet var label_month: UILabel!
    @IBOutlet var month_label: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label_month.font = UIFont.systemFont(ofSize: 13.0)
    }
}
