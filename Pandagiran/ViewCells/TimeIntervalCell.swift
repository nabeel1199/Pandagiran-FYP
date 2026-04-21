

import UIKit

class TimeIntervalCell: UITableViewCell {
    @IBOutlet weak var label_interval: UILabel!
    @IBOutlet weak var iv_checked: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureEventsWithItem (event: Hkb_event) {
        label_interval.text = event.name!
    }
    
}
