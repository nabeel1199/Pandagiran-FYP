

import UIKit

class NavigationViewCell: UITableViewCell {
    
    @IBOutlet weak var label_sub_text: UILabel!
    @IBOutlet var label_nav_text: UILabel!
    @IBOutlet var navImage: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        label_nav_text.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
    }
    
}
