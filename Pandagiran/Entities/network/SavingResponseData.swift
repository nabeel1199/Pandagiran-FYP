

import Foundation
import CoreData

struct SavingResponseData : Codable {
    let goalId : Int?
    let amount : String?
    let icon : String?
    let targetenddate : String?
    let actualenddate : String?
    let goaldescription : String?
    let flex2 : String?
    let flex1 : String?
    let title : String?
    let active : Int?
    let tags : String?
    let createdon : String?
    let currency : String?

    enum CodingKeys: String, CodingKey {

        case goalId = "goalId"
        case amount = "amount"
        case icon = "icon"
        case targetenddate = "targetenddate"
        case actualenddate = "actualenddate"
        case goaldescription = "goaldescription"
        case flex2 = "flex2"
        case flex1 = "flex1"
        case title = "title"
        case active = "active"
        case tags = "tags"
        case createdon = "createdon"
        case currency = "currency"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        goalId = try values.decodeIfPresent(Int.self, forKey: .goalId)
        amount = try values.decodeIfPresent(String.self, forKey: .amount)
        icon = try values.decodeIfPresent(String.self, forKey: .icon)
        targetenddate = try values.decodeIfPresent(String.self, forKey: .targetenddate)
        actualenddate = try values.decodeIfPresent(String.self, forKey: .actualenddate)
        goaldescription = try values.decodeIfPresent(String.self, forKey: .goaldescription)
        flex2 = try values.decodeIfPresent(String.self, forKey: .flex2)
        flex1 = try values.decodeIfPresent(String.self, forKey: .flex1)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        active = try values.decodeIfPresent(Int.self, forKey: .active)
        tags = try values.decodeIfPresent(String.self, forKey: .tags)
        createdon = try values.decodeIfPresent(String.self, forKey: .createdon)
        currency = try values.decodeIfPresent(String.self, forKey: .currency)
        self.maptoDBModel()
    }

}
extension SavingResponseData {
    func maptoDBModel(){
        
        var goal : Hkb_goal = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_SAVING, into: DbController.getContext()) as! Hkb_goal
//        var goal: Hkb_goal?
        goal.goalId = Int64(self.goalId ?? 0)
        goal.amount = Double(self.amount ?? "0.0")!
        goal.targetenddate = self.targetenddate ?? ""
        goal.goaldescription = self.goaldescription ?? ""
        if self.actualenddate != nil {
            goal.actualenddate = self.actualenddate ?? "Not End"
        }
        
        goal.flex1 = self.flex1 ?? ""
        goal.flex2 = self.flex2 ?? ""
        goal.title = self.title ?? ""
        goal.active = Int16(self.active ?? 0)
        goal.tags = self.tags
        goal.createdon = self.createdon ?? ""
        goal.currency = self.currency ?? ""
        goal.is_synced = 1
        DbController.saveContext()
        LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
        LocalPrefs.setSavingsTotal(count: LocalPrefs.getSavingsTotal() - 1)
        LocalPrefs.setSyncSavingTotalCount(count: LocalPrefs.getSyncSavingTotalCount() + 1)
    }
}
