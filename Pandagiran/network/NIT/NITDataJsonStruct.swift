

import Foundation
struct Nit : Codable {
    let data : [NITData]?
    let meta : Meta?

    enum CodingKeys: String, CodingKey {

        case data = "data"
        case meta = "meta"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([NITData].self, forKey: .data)
        meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
    }

}
struct NITData : Codable {
    let id : Int?
    let attributes : Attributes?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case attributes = "attributes"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        attributes = try values.decodeIfPresent(Attributes.self, forKey: .attributes)
    }

}
struct Meta : Codable {
    let pagination : Pagination?

    enum CodingKeys: String, CodingKey {

        case pagination = "pagination"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pagination = try values.decodeIfPresent(Pagination.self, forKey: .pagination)
    }

}
struct Pagination : Codable {
    let page : Int?
    let pageSize : Int?
    let pageCount : Int?
    let total : Int?

    enum CodingKeys: String, CodingKey {

        case page = "page"
        case pageSize = "pageSize"
        case pageCount = "pageCount"
        case total = "total"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        page = try values.decodeIfPresent(Int.self, forKey: .page)
        pageSize = try values.decodeIfPresent(Int.self, forKey: .pageSize)
        pageCount = try values.decodeIfPresent(Int.self, forKey: .pageCount)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
    }

}
class Attributes : Codable {
    let name : String?
    let partnerImage : PartnerImage?
    let investment_plans : Investment_plans?
    let createdAt : String?
    let updatedAt : String?
    let publishedAt : String?
    let url : String?
    let createdBy : String?
    let updatedBy : String?
    let formats : Formats?

    enum CodingKeys: String, CodingKey {

        case name = "Name"
        case partnerImage = "PartnerImage"
        case investment_plans = "investment_plans"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case publishedAt = "publishedAt"
        case createdBy = "createdBy"
        case updatedBy = "updatedBy"
        case formats = "formats"
        case url = "url"
    }

   required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        partnerImage = try values.decodeIfPresent(PartnerImage.self, forKey: .partnerImage)
        investment_plans = try values.decodeIfPresent(Investment_plans.self, forKey: .investment_plans)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        publishedAt = try values.decodeIfPresent(String.self, forKey: .publishedAt)
        createdBy = try values.decodeIfPresent(String.self, forKey: .createdBy)
        updatedBy = try values.decodeIfPresent(String.self, forKey: .updatedBy)
       formats = try values.decodeIfPresent(Formats.self, forKey: .formats)
       url = try values.decodeIfPresent(String.self, forKey: .url)
    }

}
struct PartnerImage : Codable {
    let id : String?
    let data : NITData?

    enum CodingKeys: String, CodingKey {

        case data = "data"
        case id = "id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent(NITData.self, forKey: .data)
        id = try values.decodeIfPresent(String.self, forKey: .id)

    }

}

struct Formats : Codable {
    let thumbnail : Thumbnail?
    let small : Small?
    
    enum CodingKeys: String, CodingKey {

        case thumbnail = "thumbnail"
        case small = "small"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        thumbnail = try values.decodeIfPresent(Thumbnail.self, forKey: .thumbnail)
        small = try values.decodeIfPresent(Small.self, forKey: .small)

    }
}

struct Thumbnail : Codable {
    let name : String?
    let hash : String?
    let ext : String?
    let path : String?
    let mime : String?
    let size : Double?
    let url : String?
    let height : Int?
    let width : Int?
    
    enum CodingKeys: String, CodingKey {

        case name = "Name"
        case hash = "hash"
        case ext = "ext"
        case mime = "mime"
        case size = "size"
        case url = "url"
        case height = "height"
        case width = "widh"
        case path = "path"
    }

   init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        hash = try values.decodeIfPresent(String.self, forKey: .hash)
        ext = try values.decodeIfPresent(String.self, forKey: .ext)
        mime = try values.decodeIfPresent(String.self, forKey: .mime)
        size = try values.decodeIfPresent(Double.self, forKey: .size)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        height = try values.decodeIfPresent(Int.self, forKey: .height)
        width = try values.decodeIfPresent(Int.self, forKey: .width)
       path = try values.decodeIfPresent(String.self, forKey: .path)
    }

    
                                       
}

struct Small : Codable {
    let name : String?
    let hash : String?
    let ext : String?
    let path : String?
    let mime : String?
    let size : Double?
    let url : String?
    let height : Int?
    let width : Int?
    
    enum CodingKeys: String, CodingKey {

        case name = "Name"
        case hash = "hash"
        case ext = "ext"
        case mime = "mime"
        case size = "size"
        case url = "url"
        case height = "height"
        case width = "widh"
        case path = "path"
    }

   init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        hash = try values.decodeIfPresent(String.self, forKey: .hash)
        ext = try values.decodeIfPresent(String.self, forKey: .ext)
        mime = try values.decodeIfPresent(String.self, forKey: .mime)
        size = try values.decodeIfPresent(Double.self, forKey: .size)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        height = try values.decodeIfPresent(Int.self, forKey: .height)
        width = try values.decodeIfPresent(Int.self, forKey: .width)
       path = try values.decodeIfPresent(String.self, forKey: .path)
    }
    
    
}



