

import UIKit

class BudgetCellView: UITableViewCell {
    //UI Components
    @IBOutlet weak var label_left: UILabel!
    @IBOutlet weak var label_budget: UILabel!
    @IBOutlet weak var label_spent: UILabel!
    @IBOutlet weak var progress_view: UIProgressView!
    @IBOutlet weak var category_image: UIImageView!
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var category_title_height: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
