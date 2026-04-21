

import UIKit

class VoucherAccountViewCell: UITableViewCell {
    @IBOutlet weak var accountImage: UIImageView!
    @IBOutlet weak var bgView: CircularView!
    @IBOutlet weak var accountTitle: UILabel!
    @IBOutlet weak var label_balance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
