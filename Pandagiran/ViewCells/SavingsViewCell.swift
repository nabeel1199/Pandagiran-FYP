

import UIKit

class SavingsViewCell: UITableViewCell {
    
    @IBOutlet weak var iv_image: UIImageView!
    @IBOutlet weak var label_saving_title: UILabel!
    @IBOutlet weak var progress_view: UIProgressView!
    @IBOutlet weak var label_goal_amount: UILabel!
    @IBOutlet weak var label_saved_amount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
