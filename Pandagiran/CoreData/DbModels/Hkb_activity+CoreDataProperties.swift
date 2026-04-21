
import Foundation
import CoreData


extension Hkb_activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hkb_activity> {
        return NSFetchRequest<Hkb_activity>(entityName: "Hkb_activity")
    }

    @NSManaged public var activitydatetime: String?
    @NSManaged public var apilevel: String?
    @NSManaged public var appversion: String?
    @NSManaged public var branchid: String?
    @NSManaged public var devicemodel: String?
    @NSManaged public var devicename: String?
    @NSManaged public var deviceversion: String?
    @NSManaged public var hkappcodeversion: String?
    @NSManaged public var iosversion: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?

}
