

import Foundation
import CoreData

struct SavingTrxResponseData : Codable {
    let accountid : Int64?
    let active : Int32?
    let trxyear : Int?
    let goalid : Int64?
    let trxdate : String?
    let flex3 : String?
    let trxday : Int?
    let voucherId : Int64?
    let trxmonth : Int?
    let flex1 : String?
    let vchdescription : String?
    let flex4 : String?
    let amount : String?
//    let isdeposit : Int?
    let hkbvchid : Int64?
    let flex2 : String?


    enum CodingKeys: String, CodingKey {

        case accountid = "accountid"
        case active = "active"
        case trxyear = "trxyear"
        case goalid = "goalid"
        case trxdate = "trxdate"
        case flex3 = "flex3"
        case trxday = "trxday"
        case voucherId = "voucherId"
        case trxmonth = "trxmonth"
        case flex1 = "flex1"
        case vchdescription = "vchdescription"
        case flex4 = "flex4"
        case amount = "amount"
//        case isdeposit = "isdeposit"
        case hkbvchid = "hkbvchid"
        case flex2 = "flex2"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        accountid = try values.decodeIfPresent(Int64.self, forKey: .accountid)
        active = try values.decodeIfPresent(Int32.self, forKey: .active)
        trxyear = try values.decodeIfPresent(Int.self, forKey: .trxyear)
        goalid = try values.decodeIfPresent(Int64.self, forKey: .goalid)
        trxdate = try values.decodeIfPresent(String.self, forKey: .trxdate)
        flex3 = try values.decodeIfPresent(String.self, forKey: .flex3)
        trxday = try values.decodeIfPresent(Int.self, forKey: .trxday)
        voucherId = try values.decodeIfPresent(Int64.self, forKey: .voucherId)
        trxmonth = try values.decodeIfPresent(Int.self, forKey: .trxmonth)
        flex1 = try values.decodeIfPresent(String.self, forKey: .flex1)
        vchdescription = try values.decodeIfPresent(String.self, forKey: .vchdescription)
        flex4 = try values.decodeIfPresent(String.self, forKey: .flex4)
        amount = try values.decodeIfPresent(String.self, forKey: .amount)
//        isdeposit = try values.decodeIfPresent(Int.self, forKey: .isdeposit)
        hkbvchid = try values.decodeIfPresent(Int64.self, forKey: .hkbvchid)
        flex2 = try values.decodeIfPresent(String.self, forKey: .flex2)
        self.maptoDBModel()
    }

}
extension SavingTrxResponseData{
    func maptoDBModel(){
        
        var savingTrx : Hkb_goal_trx = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_SAVING_TRX, into: DbController.getContext()) as! Hkb_goal_trx
//        var savingTrx: Hkb_goal_trx?
        savingTrx.accountid = self.accountid ?? 0
        savingTrx.active = self.active ?? 0
        savingTrx.trxyear = String(self.trxyear ?? 0)
        savingTrx.goalid = self.goalid ?? 0
        savingTrx.trxdate = self.trxdate
        savingTrx.trxday = String(self.trxday ?? 0)
        savingTrx.voucherId = self.voucherId ?? 0
        savingTrx.trxmonth = String(self.trxmonth ?? 0)
        savingTrx.vchdescription = self.vchdescription
        savingTrx.amount = Double(self.amount ?? "0.0")!
//        savingTrx?.isdeposit = String(self.isdeposit ?? 0)
        savingTrx.hkbvchid = self.hkbvchid ?? 0
        savingTrx.is_synced = 1
        DbController.saveContext()
        LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
        LocalPrefs.setSavingTrxTotal(count: LocalPrefs.getSavingTrxTotal() - 1)
        LocalPrefs.setSyncSavingTrxTotalCount(count: LocalPrefs.getSyncSavingTrxTotalCount() + 1)
    }
}
