

import UIKit

class ReviewViewCell: UITableViewCell {

    @IBOutlet weak var label_review: UILabel!
    @IBOutlet weak var label_time_string: UILabel!
    @IBOutlet weak var label_user_name: UILabel!
    @IBOutlet weak var iv_user: TintedImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureReviewWithItem (review : Reviews) {
        label_user_name.text = review.consumer_name!
        label_review.text = review.comments!
    }
}
