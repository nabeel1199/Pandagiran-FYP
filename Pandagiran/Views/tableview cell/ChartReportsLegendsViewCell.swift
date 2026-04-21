

import UIKit

class ChartReportsLegendsViewCell: UITableViewCell {
    
    @IBOutlet weak var category_color: UIView!
    @IBOutlet weak var category_title: UILabel!
    @IBOutlet weak var label_amount_spent: UILabel!
    @IBOutlet weak var label_percentage_spent: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
