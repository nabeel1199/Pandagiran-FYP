
import UIKit

class NotificationViewCell: UITableViewCell {

    @IBOutlet weak var iv_notification: UIImageView!
    @IBOutlet weak var label_notification_title: UILabel!
    @IBOutlet weak var label_notification_content: UILabel!
    @IBOutlet weak var label_time: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
