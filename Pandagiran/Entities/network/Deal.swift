
import Foundation

struct Deal : Encodable , Decodable {
    
    public var deal_id : String?
    public var partner_logo : String?
    public var deal_partner_id : String?
    public var partner_id : String?
    public var deal_title : String?
    public var deal_description : String?
    public var deal_image_link : String?
    public var deal_link : String?
    public var deal_sale_price : Double?
    public var deal_price : Double?
    public var deal_discount : Double?
    public var deal_expiry : Int64?
    public var is_in_wishlist : Bool?
    public var is_liked : Bool?
    
    public var brand : Brand?
    public var impressions : Impression?
    public var category : DealCategory?
    
}


