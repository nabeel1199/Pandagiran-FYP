
import Foundation
import CoreData


extension Hkb_event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hkb_event> {
        return NSFetchRequest<Hkb_event>(entityName: "Hkb_event")
    }

    @NSManaged public var active: Int16
    @NSManaged public var desc: String?
    @NSManaged public var enddate: String?
    @NSManaged public var eventid: Int64
    @NSManaged public var is_synced: Int32
    @NSManaged public var name: String?
    @NSManaged public var startdate: String?

}
