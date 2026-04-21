
import Foundation
import CoreData


extension Hkb_account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hkb_account> {
        return NSFetchRequest<Hkb_account>(entityName: "Hkb_account")
    }

    @NSManaged public var accnature: String?
    @NSManaged public var account_currency: String?
    @NSManaged public var account_id: Int64
    @NSManaged public var acctype: String?
    @NSManaged public var active: Int16
    @NSManaged public var balance_amount: Double
    @NSManaged public var bank_name: String?
    @NSManaged public var boxcolor: String?
    @NSManaged public var boxicon: String?
    @NSManaged public var descr: String?
    @NSManaged public var flex1: String?
    @NSManaged public var flex2: String?
    @NSManaged public var glaccno: String?
    @NSManaged public var is_synced: Int32
    @NSManaged public var openingbalance: Double
    @NSManaged public var pin: String?
    @NSManaged public var title: String?
    @NSManaged public var user_id: Int64

}
