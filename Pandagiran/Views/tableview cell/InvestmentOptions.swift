

import UIKit

class InvestmentOptions: UITableViewCell {
    
    @IBOutlet weak var investmentImg: UIImageView!
    @IBOutlet weak var investmentLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
