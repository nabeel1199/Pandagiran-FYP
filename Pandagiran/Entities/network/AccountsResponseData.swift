

import Foundation
import CoreData

struct AccountsResponseData : Codable {
    let openingbalance : String?
    let flex2 : String?
    let account_id : Int64?
    let title : String?
    let flex4 : String?
    let accnature : String?
    let flex3 : String?
    let glaccno : String?
    let boxcolor : String?
    let boxicon : String?
    let descr : String?
    let flex5 : String?
    let active : Int?
    let flex1 : String?
    let bank_name : String?
    let flex6 : String?
    let acctype : String?

    enum CodingKeys: String, CodingKey {

        case openingbalance = "openingbalance"
        case flex2 = "flex2"
        case account_id = "account_id"
        case title = "title"
        case flex4 = "flex4"
        case accnature = "accnature"
        case flex3 = "flex3"
        case glaccno = "glaccno"
        case boxcolor = "boxcolor"
        case boxicon = "boxicon"
        case descr = "descr"
        case flex5 = "flex5"
        case active = "active"
        case flex1 = "flex1"
        case bank_name = "bank_name"
        case flex6 = "flex6"
        case acctype = "acctype"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        openingbalance = try values.decodeIfPresent(String.self, forKey: .openingbalance)
        flex2 = try values.decodeIfPresent(String.self, forKey: .flex2)
        account_id = try values.decodeIfPresent(Int64.self, forKey: .account_id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        flex4 = try values.decodeIfPresent(String.self, forKey: .flex4)
        accnature = try values.decodeIfPresent(String.self, forKey: .accnature)
        flex3 = try values.decodeIfPresent(String.self, forKey: .flex3)
        glaccno = try values.decodeIfPresent(String.self, forKey: .glaccno)
        boxcolor = try values.decodeIfPresent(String.self, forKey: .boxcolor)
        boxicon = try values.decodeIfPresent(String.self, forKey: .boxicon)
        descr = try values.decodeIfPresent(String.self, forKey: .descr)
        flex5 = try values.decodeIfPresent(String.self, forKey: .flex5)
        active = try values.decodeIfPresent(Int.self, forKey: .active)
        flex1 = try values.decodeIfPresent(String.self, forKey: .flex1)
        bank_name = try values.decodeIfPresent(String.self, forKey: .bank_name)
        flex6 = try values.decodeIfPresent(String.self, forKey: .flex6)
        acctype = try values.decodeIfPresent(String.self, forKey: .acctype)
        maptoDBModel()
    }

}

extension AccountsResponseData{
    func maptoDBModel(){
        if QueryUtils.fetchExistingAccount(account_id: self.account_id ?? 0, title: self.title ?? ""){
            LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
            LocalPrefs.setAccountsTotalCount(count: LocalPrefs.getAccountsTotalCount() - 1)
            LocalPrefs.setSyncAccountsTotalCount(count: LocalPrefs.getSyncAccountsTotalCount() + 1)
        } else {
            var account : Hkb_account = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_ACCOUNT, into: DbController.getContext()) as! Hkb_account
//            var account: Hkb_account?
            account.openingbalance = Double(self.openingbalance ?? "0.0")!
            account.flex2 = self.flex2 ?? ""
            account.account_id = Int64(self.account_id ?? 0)
            account.title = self.title ?? ""
            account.accnature = self.accnature ?? ""
            account.glaccno = self.glaccno ?? ""
            account.boxcolor = self.boxcolor ?? ""
            account.boxicon = self.boxicon ?? ""
            account.descr = self.descr ?? ""
            account.active = Int16(self.active ?? 0)
            account.flex1 = self.flex1 ?? ""
            account.bank_name = self.bank_name ?? ""
            account.acctype = self.acctype ?? ""
            account.is_synced = 1
            DbController.saveContext()
            LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
            LocalPrefs.setAccountsTotalCount(count: LocalPrefs.getAccountsTotalCount() - 1)
            LocalPrefs.setSyncAccountsTotalCount(count: LocalPrefs.getSyncAccountsTotalCount() + 1)
        }
    }
}
