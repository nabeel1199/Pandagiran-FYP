

import UIKit

class WishlistViewCell: UITableViewCell {

    @IBOutlet weak var label_price: UILabel!
    @IBOutlet weak var label_percentage_off: UILabel!
    @IBOutlet weak var view_percentage_off: CardView!
    @IBOutlet weak var label_expiry: UILabel!
    @IBOutlet weak var label_retailer: UILabel!
    @IBOutlet weak var label_deal_title: UILabel!
    @IBOutlet weak var iv_deal: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
//    public func configureWishlistWithItem (wishlist : Wishlist) {
//        if let wishTitle = wishlist.offer_meta?.title {
//            label_deal_title.text = wishTitle
//        }
//
//        if let retailerTitle = wishlist.offer_meta?.retailer?.title {
//            label_retailer.text = retailerTitle
//        }
//
//        if let expiryDate = wishlist.offer_meta?.flyer?.expiry {
//            let expiryDateInt = Int64(expiryDate)
//
//            let date = Date.init(timeIntervalSince1970: TimeInterval(expiryDateInt! / 1000))
//            print("EXPIRY : " , date)
//            label_expiry.text = "EXPIRY : \(Utils.currentDateUserFormat(date: date))"
//        }
//
//        if let image = wishlist.offer_meta?.img {
//            iv_deal.kf.setImage(with: URL(string: image))
//        }
//
//        if let percentageOff = wishlist.offer_meta?.discount_percentage {
//            if percentageOff > 0 {
//                view_percentage_off.isHidden = false
//                label_percentage_off.text = "\(percentageOff)% Off"
//                label_price.text = "-Rs \(wishlist.offer_meta!.sale_price)"
//            } else {
//                view_percentage_off.isHidden = true
//                label_price.text = "-Rs \(wishlist.offer_meta!.original_price)"
//            }
//        }
//    }
    
    
    public func configureFlyerWishlistWithItem (flyer : FlyerWishlist) {
        let flyerDeal = flyer.offer_meta!
        let retailer = (flyer.offer_meta?.retailer)!
        
        if let expiryDate = flyerDeal.flyer?.expiry {
            let date = Date.init(timeIntervalSince1970: TimeInterval(expiryDate / 1000))
            label_expiry.text = "EXPIRY : \(Utils.currentDateUserFormat(date: date))"
        }
        
        iv_deal.kf.setImage(with: URL(string: flyerDeal.img))
        label_retailer.text = retailer.title
        label_deal_title.text = flyerDeal.title
        label_percentage_off.text = "\(Int(flyerDeal.discount_percentage))% Off"
        label_price.text = "Rs \(Utils.formatDecimalNumber(number: flyerDeal.sale_price, decimal: 0))"
    }
    
    
    public func configureOfferWishlistWithItem (offer : OfferWishlist) {
        let offerDeal = offer.offer_meta!
        let brand = (offer.offer_meta?.brand)!
        
        label_expiry.isHidden = true
        
        if let expiryDate = offerDeal.deal_expiry {
            let expiryDateInt = Int64(expiryDate)
            let date = Date.init(timeIntervalSince1970: TimeInterval(expiryDateInt / 1000))
            label_expiry.text = "EXPIRY : \(Utils.currentDateUserFormat(date: date))"
        }
        
        iv_deal.kf.setImage(with: URL(string: offerDeal.deal_image_link!))
        label_retailer.text = brand.brand_name!
        label_deal_title.text = offerDeal.deal_title!
        label_percentage_off.text = "\(Int(offerDeal.deal_discount!))% Off"
        label_price.text = "Rs \(Utils.formatDecimalNumber(number: offerDeal.deal_sale_price!, decimal: 0))"
    }
}
