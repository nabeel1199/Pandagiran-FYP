

import Foundation

struct Impression : Encodable , Decodable {
    
    public var total_likes : Int?
    public var total_views : Int?
    public var average_rating  : Double?
    public var average_rating_by_users_count : Int?
    
}


