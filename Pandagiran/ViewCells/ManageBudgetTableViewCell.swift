

import UIKit

class ManageBudgetTableViewCell: UITableViewCell {

    @IBOutlet weak var label_category_title: UILabel!
    @IBOutlet weak var label_budget_detail: UILabel!
    @IBOutlet weak var iv_category_image: UIImageView!
    @IBOutlet weak var btn_menu: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
