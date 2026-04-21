

import Foundation
//MARK: - Partner, Investment_form, Investment_plan are all investmentData type struct

struct Investment_plan : Codable {
    let data : [ivestmentData]?
    
    enum CodingKeys: String, CodingKey {
        
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([ivestmentData].self, forKey: .data)
    }
    
}
struct ivestmentData : Codable {
    var id : Int?
    let attributes : InformationAttributes?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case attributes = "attributes"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        attributes = try values.decodeIfPresent(InformationAttributes.self, forKey: .attributes)
    }
    
}
class InformationAttributes : Codable {
    let title : String?
    let content : String?
    let partner : Partner?
    let investment_form : Investment_form?
    let createdAt : String?
    let updatedAt : String?
    let publishedAt : String?
    let createdBy : String?
    let updatedBy : String?
    let logo : Logo?
    
    enum CodingKeys: String, CodingKey {
        
        case title = "Title"
        case content = "Content"
        case partner = "partner"
        case investment_form = "investment_form"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case publishedAt = "publishedAt"
        case createdBy = "createdBy"
        case updatedBy = "updatedBy"
        case logo = "logo"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        content = try values.decodeIfPresent(String.self, forKey: .content)
        partner = try values.decodeIfPresent(Partner.self, forKey: .partner)
        investment_form = try values.decodeIfPresent(Investment_form.self, forKey: .investment_form)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        publishedAt = try values.decodeIfPresent(String.self, forKey: .publishedAt)
        createdBy = try values.decodeIfPresent(String.self, forKey: .createdBy)
        updatedBy = try values.decodeIfPresent(String.self, forKey: .updatedBy)
        logo = try values.decodeIfPresent(Logo.self, forKey: .logo)
        
    }
    
}
struct Permissions : Codable {
    let data : [ivestmentData]?
    
    enum CodingKeys: String, CodingKey {
        
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([ivestmentData].self, forKey: .data)
    }
    
}
struct Users : Codable {
    let data : [ivestmentData]?
    
    enum CodingKeys: String, CodingKey {
        
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([ivestmentData].self, forKey: .data)
    }
    
}
struct Partner : Codable {
    let data : ivestmentData?
    
    enum CodingKeys: String, CodingKey {
        
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent(ivestmentData.self, forKey: .data)
    }
    
}
struct Role : Codable {
    let data : ivestmentData?
    
    enum CodingKeys: String, CodingKey {
        
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent(ivestmentData.self, forKey: .data)
    }
    
}
struct Investment_form : Codable {
    let data : [ivestmentData]?
    
    enum CodingKeys: String, CodingKey {
        
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([ivestmentData].self, forKey: .data)
    }
    
}
struct Investment_plans : Codable {
    let data : [ivestmentData]?
    
    enum CodingKeys: String, CodingKey {
        
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([ivestmentData].self, forKey: .data)
    }
    
}
struct Related : Codable {
    let data : [ivestmentData]?
    
    enum CodingKeys: String, CodingKey {
        
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([ivestmentData].self, forKey: .data)
    }
    
}
struct Roles : Codable {
    let data : [ivestmentData]?
    
    enum CodingKeys: String, CodingKey {
        
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([ivestmentData].self, forKey: .data)
    }
    
}

struct Logo: Codable {
    let data: LogoData?
    
    enum CodingKeys: String, CodingKey {
        
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent(LogoData.self, forKey: .data)
    }
}

// MARK: - DataClass
class LogoData: Codable {
    let id: Int?
    let attributes: LogoAttributes?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case attributes = "attributes"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        attributes = try values.decodeIfPresent(LogoAttributes.self, forKey: .attributes)
    }
    
}

struct LogoAttributes: Codable {
    let name, alternativeText, caption: String?
    let width, height: Int?
    let hash, ext, mime: String?
    let size: Double?
    let url: String?
    let previewURL: String?
    let createdAt, updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case alternativeText = "alternativeText"
        case caption = "caption"
        case width =  "width"
        case height = "height"
        case hash = "hash"
        case ext = "ext"
        case mime = "mime"
        case size = "size"
        case url = "url"
        case previewURL = "previewUrl"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        alternativeText = try values.decodeIfPresent(String.self, forKey: .alternativeText)
        caption = try values.decodeIfPresent(String.self, forKey: .caption)
        width = try values.decodeIfPresent(Int.self, forKey: .width)
        height = try values.decodeIfPresent(Int.self, forKey: .height)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        hash = try values.decodeIfPresent(String.self, forKey: .hash)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        ext = try values.decodeIfPresent(String.self, forKey: .ext)
        mime = try values.decodeIfPresent(String.self, forKey: .mime)
        size = try values.decodeIfPresent(Double.self, forKey: .size)
        previewURL = try values.decodeIfPresent(String.self, forKey: .previewURL)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        
    }
    
}










