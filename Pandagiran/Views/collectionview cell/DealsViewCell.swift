

import UIKit
import Cosmos
import SkeletonView

class DealsViewCell: UICollectionViewCell {

    @IBOutlet weak var label_views_count: UILabel!
    @IBOutlet weak var view_brand: CardView!
    @IBOutlet weak var label_brand_name: UILabel!
    @IBOutlet weak var btn_share: CircularButton!
    @IBOutlet weak var btn_reminder: CircularButton!
    @IBOutlet weak var btn_wishlist: CircularButton!
    @IBOutlet weak var view_favourite: UIView!
    @IBOutlet weak var label_rating_count: UILabel!
    @IBOutlet weak var rating_bar: CosmosView!
    @IBOutlet weak var label_original_price: UILabel!
    @IBOutlet weak var label_discount_price: UILabel!
    @IBOutlet weak var label_brand_title: UILabel!
    @IBOutlet weak var iv_brand: UIImageView!
    @IBOutlet weak var label_deal_title: UILabel!
    @IBOutlet weak var label_percentage: UILabel!
    @IBOutlet weak var view_percentage: CardView!
    @IBOutlet weak var iv_favourite: UIImageView!
    @IBOutlet weak var iv_deal: UIImageView!
 
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    private func getStruckThroughText (text: String) -> NSMutableAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.red, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
    public func configureItemWithDeal (deal : Deal) {
        iv_deal.kf.setImage(with: URL(string: deal.deal_image_link!))
        iv_brand.kf.setImage(with: URL(string: deal.partner_logo!))
        label_brand_name.text = (deal.brand?.brand_name)!
        label_deal_title.text = deal.deal_title!
        label_brand_title.text = (deal.partner_id)!
        label_discount_price.text = "Rs \(Utils.formatDecimalNumber(number: deal.deal_sale_price!, decimal: 0))"
        label_original_price.attributedText = getStruckThroughText(text: "Rs \(Utils.formatDecimalNumber(number: deal.deal_price!, decimal: 0))")
        rating_bar.rating = (deal.impressions?.average_rating)!
        label_percentage.text = "\(Int(deal.deal_discount!))% Off"
        view_percentage.roundCorners([.topRight, .bottomRight], radius: 15.0)
        label_rating_count.text = "(\((deal.impressions?.average_rating_by_users_count)!))"
        
        label_views_count.text = "\((deal.impressions?.total_views)!) Views"
        
        
        if deal.is_liked! {
            iv_favourite.tintColor = UIColor.red
        } else {
            iv_favourite.tintColor = UIColor.groupTableViewBackground
        }
        
        if deal.is_in_wishlist! {
            btn_wishlist.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        } else {
            btn_wishlist.tintColor = UIColor.lightGray
        }
        
        if deal.deal_discount! == 0 {
            view_percentage.isHidden = true
            label_original_price.isHidden = true
        }
    }
    
}
