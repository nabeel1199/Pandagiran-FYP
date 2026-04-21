

import UIKit

class OfferDetailsViewCell2: UITableViewCell {

    @IBOutlet weak var iv_offer: UIImageView!
    @IBOutlet weak var label_offer_title: UILabel!
    @IBOutlet weak var label_offer_detail: UILabel!
    @IBOutlet weak var iv_product: UIImageView!
    @IBOutlet weak var label_product_name: UILabel!
    @IBOutlet weak var label_created_on: UILabel!
    @IBOutlet weak var label_product_type: UILabel!
    @IBOutlet weak var iv_product_type: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
