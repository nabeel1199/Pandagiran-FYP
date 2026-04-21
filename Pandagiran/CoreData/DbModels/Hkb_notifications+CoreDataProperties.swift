
import Foundation
import CoreData


extension Hkb_notifications {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hkb_notifications> {
        return NSFetchRequest<Hkb_notifications>(entityName: "Hkb_notifications")
    }

    @NSManaged public var buttontext: String?
    @NSManaged public var categoryId: Int64
    @NSManaged public var codetype: Int32
    @NSManaged public var createdOn: String?
    @NSManaged public var day: String?
    @NSManaged public var expirydate: String?
    @NSManaged public var flex1: String?
    @NSManaged public var flex2: String?
    @NSManaged public var flex3: String?
    @NSManaged public var imageurl: String?
    @NSManaged public var isRead: Int16
    @NSManaged public var message: String?
    @NSManaged public var month: String?
    @NSManaged public var notification_id: Int32
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var url: String?
    @NSManaged public var year: String?

}
