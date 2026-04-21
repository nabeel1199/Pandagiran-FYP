

import Foundation

struct Retailer : Encodable, Decodable {
    
    public var phone : String
    public var title : String
    public var id : String
    public var flyers_count : Int?
    public var img : String
    public var address : String
    public var email : String
}


