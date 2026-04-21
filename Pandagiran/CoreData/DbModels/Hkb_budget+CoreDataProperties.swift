
import Foundation
import CoreData


extension Hkb_budget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hkb_budget> {
        return NSFetchRequest<Hkb_budget>(entityName: "Hkb_budget")
    }

    @NSManaged public var budget_id: Int64
    @NSManaged public var budgetmonth: Int16
    @NSManaged public var budgetvalue: Double
    @NSManaged public var budgetyear: Int16
    @NSManaged public var categoryid: Int64
    @NSManaged public var is_synced: Int32
    @NSManaged public var active: Int32

}
