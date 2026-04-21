
import Foundation
import CoreData


extension Hkb_category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hkb_category> {
        return NSFetchRequest<Hkb_category>(entityName: "Hkb_category")
    }

    @NSManaged public var active: Int16
    @NSManaged public var balance_amount: Double
    @NSManaged public var box_color: String?
    @NSManaged public var box_icon: String?
    @NSManaged public var budget_amount: Double
    @NSManaged public var categoryId: Int64
    @NSManaged public var cattype: String?
    @NSManaged public var descr: String?
    @NSManaged public var flex1: String?
    @NSManaged public var flex2: String?
    @NSManaged public var glaccno: String?
    @NSManaged public var is_expense: Int16
    @NSManaged public var is_synced: Int32
    @NSManaged public var parent_category_id: Int64
    @NSManaged public var tags: String?
    @NSManaged public var title: String?
    @NSManaged public var user_id: Int64

}
