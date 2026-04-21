

import UIKit

class FlyerViewCell: UICollectionViewCell {

    @IBOutlet weak var view_favourite: UIView!
    @IBOutlet weak var iv_favourite: UIImageView!
    @IBOutlet weak var iv_flyer: UIImageView!
    @IBOutlet weak var label_flyer_expiry: UILabel!
    @IBOutlet weak var label_flyer_title: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        view_favourite.isHidden = true
    }
    
    public func configureRetailerWithItem (retailer : Retailer) {
        iv_flyer.kf.setImage(with: URL(string: retailer.img))
        label_flyer_expiry.text = "\(retailer.flyers_count!) Flyer(s)"
        label_flyer_title.text = retailer.title
    }
}
