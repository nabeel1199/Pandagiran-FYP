
import Foundation
import CoreData


extension Hkb_goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hkb_goal> {
        return NSFetchRequest<Hkb_goal>(entityName: "Hkb_goal")
    }

    @NSManaged public var active: Int16
    @NSManaged public var actualenddate: String?
    @NSManaged public var amount: Double
    @NSManaged public var createdon: String?
    @NSManaged public var currency: String?
    @NSManaged public var flex1: String?
    @NSManaged public var flex2: String?
    @NSManaged public var goaldescription: String?
    @NSManaged public var goalId: Int64
    @NSManaged public var goalType: String?
    @NSManaged public var is_synced: Int32
    @NSManaged public var tags: String?
    @NSManaged public var targetenddate: String?
    @NSManaged public var title: String?

}
