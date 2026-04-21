

import Foundation
import CoreData

struct TransactionResponseData : Codable {
    let created_on : String?
    let vch_image : String?
    let account_id : Int64?
    let vch_no : Int64?
    let vch_date : String?
    let fcrate : Float64?
    let travelmode : Int16?
    let vchtrxplace : String?
    let updated_on : String?
    let travelmodeplace : String?
    let accountname : String?
    let vch_type : String?
    let tag : String?
    let categroryname : String?
    let ref_no : Int64?
    let fcamount : Int?
    let vch_description : String?
    let vchcurrency : String?
    let category_id : Int64?
    let travelmodelocation : String?
    let vch_day : Int16?
    let month : Int16?
    let active : Int16?
    let vch_year : Int16?
    let vch_amount : String?
    let fccurrency : String?
    let voucher_id : Int64?
    let eventname : String?
    let eventid : Int64?
    let use_case : String?

 
//    let ref_no : String?
//    let travelmodelocation : String?
//    let vch_year : Int?
//    let fcamount : Int?
//    let accountname : String?
//    let tag : String?
//    let vch_image : String?
//    let voucher_id : Int?
//    let travelmodeplace : String?
//    let eventid : Int?
//    let account_id : Int64?
//    let vch_date : String?
//    let vch_amount : String?
//    let vchcurrency : String?
//    let active : Int?
//    let month : Int?
//    let vch_description : String?
//    let vch_day : Int?
//    let category_id : Int?
//    let eventname : String?
//    let vch_type : String?
//    let use_case : String?
//    let vchtrxplace : String?
//    let fccurrency : String?
//    let travelmode : Int?
//    let fcrate : Int?
//    let vch_no : Int64?
//    let updated_on : String?
//    let categroryname : String?
//    let created_on : String?

    enum CodingKeys: String, CodingKey {

        case ref_no = "ref_no"
        case travelmodelocation = "travelmodelocation"
        case vch_year = "vch_year"
        case fcamount = "fcamount"
        case accountname = "accountname"
        case tag = "tag"
        case vch_image = "vch_image"
        case voucher_id = "voucher_id"
        case travelmodeplace = "travelmodeplace"
        case eventid = "eventid"
        case account_id = "account_id"
        case vch_date = "vch_date"
        case vch_amount = "vch_amount"
        case vchcurrency = "vchcurrency"
        case active = "active"
        case month = "month"
        case vch_description = "vch_description"
        case vch_day = "vch_day"
        case category_id = "category_id"
        case eventname = "eventname"
        case vch_type = "vch_type"
        case use_case = "use_case"
        case vchtrxplace = "vchtrxplace"
        case fccurrency = "fccurrency"
        case travelmode = "travelmode"
        case fcrate = "fcrate"
        case vch_no = "vch_no"
        case updated_on = "updated_on"
        case categroryname = "categroryname"
        case created_on = "created_on"
//        travelmode
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        created_on = try values.decodeIfPresent(String.self, forKey: .created_on)
        vch_image = try values.decodeIfPresent(String.self, forKey: .vch_image)
        account_id = try values.decodeIfPresent(Int64.self, forKey: .account_id)
        vch_no = try values.decodeIfPresent(Int64.self, forKey: .vch_no)
        vch_date = try values.decodeIfPresent(String.self, forKey: .vch_date)
        fcrate = try values.decodeIfPresent(Float64.self, forKey: .fcrate)
        travelmode = try values.decodeIfPresent(Int16.self, forKey: .travelmode)
        vchtrxplace = try values.decodeIfPresent(String.self, forKey: .vchtrxplace)
        updated_on = try values.decodeIfPresent(String.self, forKey: .updated_on)
        travelmodeplace = try values.decodeIfPresent(String.self, forKey: .travelmodeplace)
        accountname = try values.decodeIfPresent(String.self, forKey: .accountname)
        vch_type = try values.decodeIfPresent(String.self, forKey: .vch_type)
        tag = try values.decodeIfPresent(String.self, forKey: .tag)
        categroryname = try values.decodeIfPresent(String.self, forKey: .categroryname)
        ref_no = try values.decodeIfPresent(Int64.self, forKey: .ref_no)
        fcamount = try values.decodeIfPresent(Int.self, forKey: .fcamount)
        vch_description = try values.decodeIfPresent(String.self, forKey: .vch_description)
        vchcurrency = try values.decodeIfPresent(String.self, forKey: .vchcurrency)
        category_id = try values.decodeIfPresent(Int64.self, forKey: .category_id)
        travelmodelocation = try values.decodeIfPresent(String.self, forKey: .travelmodelocation)
        vch_day = try values.decodeIfPresent(Int16.self, forKey: .vch_day)
        month = try values.decodeIfPresent(Int16.self, forKey: .month)
        active = try values.decodeIfPresent(Int16.self, forKey: .active)
        vch_year = try values.decodeIfPresent(Int16.self, forKey: .vch_year)
        vch_amount = try values.decodeIfPresent(String.self, forKey: .vch_amount)
        fccurrency = try values.decodeIfPresent(String.self, forKey: .fccurrency)
        voucher_id = try values.decodeIfPresent(Int64.self, forKey: .voucher_id)
        eventname = try values.decodeIfPresent(String.self, forKey: .eventname)
        eventid = try values.decodeIfPresent(Int64.self, forKey: .eventid)
        use_case = try values.decodeIfPresent(String.self, forKey: .use_case)
        self.maptoDBModel()
    }

}
extension TransactionResponseData{
    func maptoDBModel(){
        if QueryUtils.fetchExistingVoucher(account_id:  self.account_id ?? 0, voucher_id: self.voucher_id ?? 0) {
            LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
            LocalPrefs.setTransactionTotal(count: LocalPrefs.getTransactionTotal() - 1)
            LocalPrefs.setSyncTransactionTotalCount(count: LocalPrefs.getSyncTransactionTotalCount() + 1)
        } else {
            var transaction : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
//            var transaction: Hkb_voucher?
            
            transaction.created_on = self.created_on ?? ""
            transaction.vch_image = self.vch_image ?? ""
            transaction.account_id = self.account_id ?? 0
            transaction.vch_no = String(self.vch_no ?? 0)
            transaction.vch_date = self.vch_date
            transaction.fcrate = String(self.fcrate ?? 0.0)
            transaction.travelmode = self.travelmode ?? 0
            transaction.vchtrxplace = self.vchtrxplace ?? ""
            transaction.updated_on = self.updated_on ?? ""
            transaction.travelmodeplace = self.travelmodeplace ?? ""
            transaction.accountname = self.accountname ?? ""
            transaction.vch_type = self.vch_type ?? ""
            transaction.tag = self.tag ?? ""
            transaction.categoryname = self.categroryname ?? ""
            transaction.ref_no = String(self.ref_no ?? 0)
            transaction.fcamount = Double(self.fcamount ?? 0)
            transaction.vch_description = self.vch_description ?? ""
            transaction.vchcurrency = self.vchcurrency ?? ""
            transaction.category_id = self.category_id ?? 0
            transaction.travlemodelocation = self.travelmodelocation ?? ""
            transaction.vch_day = self.vch_day ?? 0
            transaction.month = self.month ?? 0
            transaction.active = self.active ?? 0
            transaction.vch_year = self.vch_year ?? 0
            transaction.vch_amount = Double(self.vch_amount ?? "0.0")!
            transaction.fccurrency = self.fccurrency ?? ""
            transaction.voucher_id = self.voucher_id ?? 0
            transaction.eventname = self.eventname ?? ""
            transaction.eventid = self.eventid ?? 0
            transaction.use_case = self.use_case ?? ""
            transaction.is_synced = 1
            print(transaction)
            DbController.saveContext()
            LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
            LocalPrefs.setTransactionTotal(count: LocalPrefs.getTransactionTotal() - 1)
            LocalPrefs.setSyncTransactionTotalCount(count: LocalPrefs.getSyncTransactionTotalCount() + 1)
        }
    }
}
