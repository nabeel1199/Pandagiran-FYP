

import UIKit

class LikedDealViewCell: UITableViewCell {

    @IBOutlet weak var label_partner_title: UILabel!
    @IBOutlet weak var iv_partner_logo: UIImageView!
    @IBOutlet weak var label_original_price: UILabel!
    @IBOutlet weak var label_sale_price: UILabel!
    @IBOutlet weak var label_deal_title: UILabel!
    @IBOutlet weak var label_brand_title: UILabel!
    @IBOutlet weak var iv_brand: UIImageView!
    @IBOutlet weak var iv_deal: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureDealWithItem (deal : Deal) {
        iv_deal.kf.setImage(with: URL(string: deal.deal_image_link!))
        iv_brand.kf.setImage(with: URL(string: (deal.brand?.brand_logo)!))
        iv_partner_logo.kf.setImage(with: URL(string: deal.partner_logo!))
        label_partner_title.text = deal.partner_id!
        label_deal_title.text = deal.deal_title!
        label_brand_title.text = (deal.brand?.brand_name)!
        label_original_price.attributedText = UIUtils.getStruckThroughText(text: "Rs \(Utils.formatDecimalNumber(number: deal.deal_price!, decimal: 0))")
        label_sale_price.text = "Rs \(Utils.formatDecimalNumber(number: deal.deal_sale_price!, decimal: 0))"
        
        if deal.deal_discount! == 0 {
            label_original_price.isHidden = true
        } else {
            label_original_price.isHidden = false
        }
    }
}
