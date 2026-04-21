
import Foundation
import CoreData


extension Hkb_reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hkb_reminder> {
        return NSFetchRequest<Hkb_reminder>(entityName: "Hkb_reminder")
    }

    @NSManaged public var account_from: Int64
    @NSManaged public var accountid: Int64
    @NSManaged public var active: Int16
    @NSManaged public var amount: Double
    @NSManaged public var categoryId: Int64
    @NSManaged public var createdon: String?
    @NSManaged public var event_id: String?
    @NSManaged public var flex: String?
    @NSManaged public var flex1: String?
    @NSManaged public var flex2: String?
    @NSManaged public var isexpense: Int16
    @NSManaged public var recurring: String?
    @NSManaged public var reminderId: Int64
    @NSManaged public var rmdate: String?
    @NSManaged public var rmday: Int16
    @NSManaged public var rmhours: Int16
    @NSManaged public var rmminutes: Int16
    @NSManaged public var rmmonth: Int16
    @NSManaged public var rmtime: String?
    @NSManaged public var rmweek: Int16
    @NSManaged public var rmyear: Int16
    @NSManaged public var tags: String?
    @NSManaged public var title: String?
    @NSManaged public var vch_description: String?

}
