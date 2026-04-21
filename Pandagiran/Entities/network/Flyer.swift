

import Foundation


struct Flyer : Decodable, Encodable {
    
    public var id : String?
    public var title : String?
    public var img : String?
    public var start_date : String?
    public var end_date : String?
    public var total_pages : Int?
    public var expiry : Int64?
}
