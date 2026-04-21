
import Foundation
import CoreData


public class Hkb_voucher: NSManagedObject {
    enum CodingKeys: String, CodingKey {
        case account_id = "account_id"
        case accountname = "accountname"
        case role
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Hkb_voucher", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.account_id = try container.decodeIfPresent(Int64.self, forKey: Hkb_voucher.CodingKeys(rawValue: "account_id")!)!
        self.accountname = try container.decodeIfPresent(String.self, forKey: Hkb_voucher.CodingKeys(rawValue: "accountname")!)
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    
    }
}

public extension CodingUserInfoKey {
    // Helper property to retrieve the context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
