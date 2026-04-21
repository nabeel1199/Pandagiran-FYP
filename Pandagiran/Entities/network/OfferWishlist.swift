

import Foundation

struct OfferWishlist : Decodable {
    
    public var id : String?
    public var flyer_offer_id : String?
    public var consumer_id : Int64?
    public var created_on : Int64?
    
    public var offer_meta : Deal?
    
}
