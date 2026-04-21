
import Foundation
import CoreData


extension Hkb_goal_trx {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hkb_goal_trx> {
        return NSFetchRequest<Hkb_goal_trx>(entityName: "Hkb_goal_trx")
    }

    @NSManaged public var accountid: Int64
    @NSManaged public var active: Int32
    @NSManaged public var amount: Double
    @NSManaged public var goalid: Int64
    @NSManaged public var hkbvchid: Int64
    @NSManaged public var is_synced: Int32
    @NSManaged public var isdeposit: String?
    @NSManaged public var trxdate: String?
    @NSManaged public var trxday: String?
    @NSManaged public var trxmonth: String?
    @NSManaged public var trxyear: String?
    @NSManaged public var vchdescription: String?
    @NSManaged public var voucherId: Int64

}
