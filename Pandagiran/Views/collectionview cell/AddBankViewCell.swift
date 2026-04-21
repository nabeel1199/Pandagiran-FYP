

import UIKit

class AddBankViewCell: UICollectionViewCell {

    @IBOutlet weak var bg_view: UIView!
    @IBOutlet weak var iv_bank: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    public func configureBankWithItem (bank: Bank) {
        let cellImage = UIImage(named: bank.bank_icon!)
        iv_bank.image = cellImage
    }
}
