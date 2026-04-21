

import Foundation

struct FlyerDeal : Encodable, Decodable {
    
    public var id : String
    public var flyer_id : String
    public var title : String
    public var category : String
    public var img : String
    public var price : Double
    public var discount : Double
    public var original_price : Double
    public var sale_price : Double
    public var discount_percentage : Double
    public var bounds : String
    public var total_views : Int
    public var total_rating : Int
    public var is_in_wishlist : Bool?
    public var is_liked : Bool?
    
    
    public var retailer : Retailer?
    public var flyer : Flyer?
    
}

