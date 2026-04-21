

import Foundation

class UserCurrency {
    var currencyFlag : String?
    var currency3dg : String?
    var currencyName : String?
    var currency2dg : String?
    var currencyPrecision : Int?
    var dialCode : Int64?
    var country3dg : String?
    
    init() {
        
    }
    
}
struct UserCurrencies: Codable {
    let currency_id : Int?
    let currency_name : String?
    let sort_order : Int?
    let country_iso_code_3dg : String?
    let iso_code_numeric : Int?
    let symbol : String?
    let last_denomination : String?
    let country_id : Int?
    let country_iso_code_2dg : String?
    let active : Int?
    let currency_precision : Int?
    let country_name : String?

    enum CodingKeys: String, CodingKey {

        case currency_id = "currency_id"
        case currency_name = "currency_name"
        case sort_order = "sort_order"
        case country_iso_code_3dg = "country_iso_code_3dg"
        case iso_code_numeric = "iso_code_numeric"
        case symbol = "symbol"
        case last_denomination = "last_denomination"
        case country_id = "country_id"
        case country_iso_code_2dg = "country_iso_code_2dg"
        case active = "active"
        case currency_precision = "currency_precision"
        case country_name = "country_name"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currency_id = try values.decodeIfPresent(Int.self, forKey: .currency_id)
        currency_name = try values.decodeIfPresent(String.self, forKey: .currency_name)
        sort_order = try values.decodeIfPresent(Int.self, forKey: .sort_order)
        country_iso_code_3dg = try values.decodeIfPresent(String.self, forKey: .country_iso_code_3dg)
        iso_code_numeric = try values.decodeIfPresent(Int.self, forKey: .iso_code_numeric)
        symbol = try values.decodeIfPresent(String.self, forKey: .symbol)
        last_denomination = try values.decodeIfPresent(String.self, forKey: .last_denomination)
        country_id = try values.decodeIfPresent(Int.self, forKey: .country_id)
        country_iso_code_2dg = try values.decodeIfPresent(String.self, forKey: .country_iso_code_2dg)
        active = try values.decodeIfPresent(Int.self, forKey: .active)
        currency_precision = try values.decodeIfPresent(Int.self, forKey: .currency_precision)
        country_name = try values.decodeIfPresent(String.self, forKey: .country_name)
    }

}
