

import UIKit

class TransferViewCell: UITableViewCell {

    @IBOutlet weak var cell_view: UIView!
    @IBOutlet weak var date_bg: UIView!
    @IBOutlet weak var date_bg_view: CardView!
    @IBOutlet weak var tv_account_from: UILabel!
    @IBOutlet weak var tv_account_to: UILabel!
    @IBOutlet var tv_day: UILabel!
    @IBOutlet var tv_date: UILabel!
    @IBOutlet weak var tv_description: UILabel!
    @IBOutlet weak var tv_amount_from: UILabel!
    @IBOutlet weak var tv_amount_to: UILabel!
    @IBOutlet weak var tv_year: UILabel!
    @IBOutlet weak var tv_account: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
