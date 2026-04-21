

import UIKit

class FlyerOfferViewCell: UITableViewCell {

 
    @IBOutlet weak var view_extended: UIView!
    @IBOutlet weak var label_price: UILabel!
    @IBOutlet weak var label_expiry: UILabel!
    @IBOutlet weak var label_retailer_title: UILabel!
    @IBOutlet weak var label_offer_title: UILabel!
    @IBOutlet weak var iv_flyer: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view_extended.backgroundColor = UIColor(patternImage: UIImage(named: "flyer_deal_bg")!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    
    public func configureDealWithItem (deal: FlyerDeal) {

        let retailer = deal.retailer!
        let flyer = deal.flyer!
        let expiryDateInt = flyer.expiry!
        let expiryDate = Date(timeIntervalSince1970: TimeInterval(expiryDateInt / 1000))
        
        label_expiry.text = Utils.currentDateUserFormat(date: expiryDate)
        iv_flyer.kf.setImage(with: URL(string: deal.img))
        label_offer_title.text = deal.title
        label_retailer_title.text = retailer.title
        label_price.text = "Rs \(Utils.formatDecimalNumber(number: deal.sale_price, decimal: 0))"
        
    }
    
    public func configureFlyerDealWishlist (wishlist : FlyerWishlist) {
        let flyerDeal = wishlist.offer_meta!
        let retailer = (wishlist.offer_meta?.retailer)!
        
        if let expiryDate = flyerDeal.flyer?.expiry {
            let date = Date.init(timeIntervalSince1970: TimeInterval(expiryDate / 1000))
            label_expiry.text = "EXPIRY : \(Utils.currentDateUserFormat(date: date))"
        }
        
        iv_flyer.kf.setImage(with: URL(string: flyerDeal.img))
        label_retailer_title.text = retailer.title
        label_offer_title.text = flyerDeal.title
//        label_percentage_off.text = "\(flyerDeal.discount_percentage)% Off"
        label_price.text = "Rs \(Utils.formatDecimalNumber(number: flyerDeal.sale_price, decimal: 0))"
    }
    
    
}
