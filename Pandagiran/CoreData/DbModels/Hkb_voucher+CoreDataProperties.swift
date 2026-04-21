
import Foundation
import CoreData


extension Hkb_voucher {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hkb_voucher> {
        return NSFetchRequest<Hkb_voucher>(entityName: "Hkb_voucher")
    }

    @NSManaged public var account_id: Int64
    @NSManaged public var accountname: String?
    @NSManaged public var active: Int16
    @NSManaged public var category_id: Int64
    @NSManaged public var categoryname: String?
    @NSManaged public var created_on: String?
    @NSManaged public var eventid: Int64
    @NSManaged public var eventname: String?
    @NSManaged public var fcamount: Double
    @NSManaged public var fccurrency: String?
    @NSManaged public var fcrate: String?
    @NSManaged public var flex1: String?
    @NSManaged public var flex2: String?
    @NSManaged public var flex3: String?
    @NSManaged public var flex4: String?
    @NSManaged public var flex5: String?
    @NSManaged public var flex6: String?
    @NSManaged public var flex7: String?
    @NSManaged public var flex8: String?
    @NSManaged public var flex9: String?
    @NSManaged public var flex10: String?
    @NSManaged public var is_synced: Int32
    @NSManaged public var month: Int16
    @NSManaged public var no_serial: Int16
    @NSManaged public var party_id: Int64
    @NSManaged public var ref_no: String?
    @NSManaged public var tag: String?
    @NSManaged public var travelmode: Int16
    @NSManaged public var travelmodeplace: String?
    @NSManaged public var travlemodelocation: String?
    @NSManaged public var updated_on: String?
    @NSManaged public var use_case: String?
    @NSManaged public var user_id: Int64
    @NSManaged public var vch_amount: Double
    @NSManaged public var vch_date: String?
    @NSManaged public var vch_day: Int16
    @NSManaged public var vch_description: String?
    @NSManaged public var vch_image: String?
    @NSManaged public var vch_no: String?
    @NSManaged public var vch_type: String?
    @NSManaged public var vch_year: Int16
    @NSManaged public var vchcurrency: String?
    @NSManaged public var vchtrxplace: String?
    @NSManaged public var voucher_id: Int64

}
