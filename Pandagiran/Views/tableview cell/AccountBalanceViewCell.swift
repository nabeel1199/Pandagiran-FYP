
import UIKit

class AccountBalanceViewCell: UITableViewCell {

    @IBOutlet weak var btn_menu: UIButton!
    @IBOutlet weak var label_inactive: UILabel!
    @IBOutlet weak var tv_account_title: UILabel!
    
    @IBOutlet weak var tv_account_balance: UILabel!
    
    @IBOutlet weak var image_account: UIImageView!
    @IBOutlet weak var btn_edit_account: UIButton!
    @IBOutlet weak var btn_activities: UIButton!
    @IBOutlet weak var btn_pin_account: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
