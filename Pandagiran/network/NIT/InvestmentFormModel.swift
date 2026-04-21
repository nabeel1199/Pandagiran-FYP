

import Foundation

struct InvestmentFormModel : Codable{
    
    let data : [AttributeData]?
    let meta : Meta?

    enum CodingKeys: String, CodingKey {

        case data = "data"
        case meta = "meta"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([AttributeData].self, forKey: .data)
        meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
    }
}

struct AttributeData : Codable {
    let id : Int?
    let attributes : FormAttributes?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case attributes = "attributes"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        attributes = try values.decodeIfPresent(FormAttributes.self, forKey: .attributes)
    }

}


class FormAttributes : Codable {
    let createdAt : String?
    let updatedAt : String?
    let publishedAt : String?
    let textField : [TextField]?
    let select : [Select]?
    let investment_plan : Investment_plan_form?
    let responses : Responses?

    enum CodingKeys: String, CodingKey {

        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case publishedAt = "publishedAt"
        case textField = "TextField"
        case select = "Select"
        case investment_plan = "investment_plan"
        case responses = "responses"
    }

   required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        publishedAt = try values.decodeIfPresent(String.self, forKey: .publishedAt)
        textField = try values.decodeIfPresent([TextField].self, forKey: .textField)
        select = try values.decodeIfPresent([Select].self, forKey: .select)
        investment_plan = try values.decodeIfPresent(Investment_plan_form.self, forKey: .investment_plan)
        responses = try values.decodeIfPresent(Responses.self, forKey: .responses)
    }

}
struct Investment_plan_form : Codable {
    let data : InvestmentData?

    enum CodingKeys: String, CodingKey {

        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent(InvestmentData.self, forKey: .data)
    }

}

struct TextField : Codable {
    let id : Int?
    let label : String?
    let type : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case label = "Label"
        case type = "Type"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }

}
struct Values : Codable {
    let value : String?
    let label : String?

    enum CodingKeys: String, CodingKey {

        case value = "value"
        case label = "label"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        value = try values.decodeIfPresent(String.self, forKey: .value)
        label = try values.decodeIfPresent(String.self, forKey: .label)
    }

}
struct Responses : Codable {
    let data : [ResponseData]?

    enum CodingKeys: String, CodingKey {

        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([ResponseData].self, forKey: .data)
    }

}
struct Select : Codable {
    let id : Int?
    let label : String?
    let type : String?
    let values : [Values]?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case label = "Label"
        case type = "Type"
        case values = "Values"
    }

    init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)
        id = try data.decodeIfPresent(Int.self, forKey: .id)
        label = try data.decodeIfPresent(String.self, forKey: .label)
        type = try data.decodeIfPresent(String.self, forKey: .type)
        values = try data.decodeIfPresent([Values].self, forKey: .values)
    }

}

struct InvestmentData : Codable {
    let id : Int?
    let attributes : InvestmentPlanData?
    
    enum CodingKeys: String, CodingKey {

        case id = "id"
        case attributes = "attributes"
        
    }
    init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)
        id = try data.decodeIfPresent(Int.self, forKey: .id)
        attributes = try data.decodeIfPresent(InvestmentPlanData.self, forKey: .attributes)
    }
    
}

struct InvestmentPlanData : Codable {
    let title : String?
    let content : String?
    let createdAt : String?
    let updatedAt : String?
    let publishedAt : String?

    enum CodingKeys: String, CodingKey {

        case title = "Title"
        case content = "Content"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case publishedAt = "publishedAt"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        content = try values.decodeIfPresent(String.self, forKey: .content)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        publishedAt = try values.decodeIfPresent(String.self, forKey: .publishedAt)

}
}

struct ResponseData : Codable {
    let id : Int?
    let attributes : UserAttribute?
    
    enum CodingKeys: String, CodingKey {

        case id = "id"
        case attributes = "attributes"
        
    }
    init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)
        id = try data.decodeIfPresent(Int.self, forKey: .id)
        attributes = try data.decodeIfPresent(UserAttribute.self, forKey: .attributes)
    }
    
    
}

struct UserAttribute : Codable {
    let name : String?
    let email : String?
    let phone : String?
    let CNIC : String?
    let city : String?
    let createdAt : String?
    let updatedAt : String?
    let publishedAt : String?
    
    enum CodingKeys: String, CodingKey {

        case name = "Name"
        case email = "Email"
        case phone = "Phone"
        case CNIC = "CNIC"
        case city = "City"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case publishedAt = "publishedAt"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        CNIC = try values.decodeIfPresent(String.self, forKey: .CNIC)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        publishedAt = try values.decodeIfPresent(String.self, forKey: .publishedAt)

}
    
    
}
