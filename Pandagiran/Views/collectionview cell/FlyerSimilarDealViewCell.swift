

import UIKit

class FlyerSimilarDealViewCell: UICollectionViewCell {

    @IBOutlet weak var view_extended: UIView!
    @IBOutlet weak var btn_reminder: CircularButton!
    @IBOutlet weak var btn_add_wishlist: CircularButton!
    @IBOutlet weak var btn_share: CircularButton!
    @IBOutlet weak var label_original_price: UILabel!
    @IBOutlet weak var label_discounted_price: UILabel!
    @IBOutlet weak var iv_retailer: UIImageView!
    @IBOutlet weak var label_retailer_title: UILabel!
    @IBOutlet weak var label_views_count: UILabel!
    @IBOutlet weak var label_deal_title: UILabel!
    @IBOutlet weak var iv_deal: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        view_extended.backgroundColor = UIColor(patternImage: UIImage(named: "flyer_deal_bg")!)
    }

    public func configureDealWithItem (deal : FlyerDeal) {
        iv_deal.kf.setImage(with: URL(string: deal.img))
        iv_retailer.kf.setImage(with: URL(string: (deal.retailer?.img)!))
        label_deal_title.text = deal.title
        label_views_count.text = "\(deal.total_views) Views"
        label_retailer_title.text = (deal.retailer?.title)!
        
        label_discounted_price.text = "Rs \(Utils.formatDecimalNumber(number: deal.sale_price, decimal: 0))"
        let attributeString =  NSMutableAttributedString(string: "Rs \(Utils.formatDecimalNumber(number: deal.original_price, decimal: 0))")
        attributeString.addAttribute(.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        label_original_price.attributedText = attributeString
        
        print("WISHLIST : " , deal.is_in_wishlist)
        if let isInWishlist = deal.is_in_wishlist {
            if isInWishlist {
                btn_add_wishlist.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            } else {
                btn_add_wishlist.tintColor = UIColor.lightGray
            }
        }
       
    }
}
