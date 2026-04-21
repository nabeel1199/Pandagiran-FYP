

import Foundation
import CoreData

struct BudgetsResponseData : Codable {
    let categoryid : Int64?
    let budgetmonth : Int?
    let active : Int?
    let budgetyear : Int?
    let budget_id : Int64?
    let budgetvalue : String?

    enum CodingKeys: String, CodingKey {

        case categoryid = "categoryid"
        case budgetmonth = "budgetmonth"
        case active = "active"
        case budgetyear = "budgetyear"
        case budget_id = "budget_id"
        case budgetvalue = "budgetvalue"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        categoryid = try values.decodeIfPresent(Int64.self, forKey: .categoryid)
        budgetmonth = try values.decodeIfPresent(Int.self, forKey: .budgetmonth)
        active = try values.decodeIfPresent(Int.self, forKey: .active)
        budgetyear = try values.decodeIfPresent(Int.self, forKey: .budgetyear)
        budget_id = try values.decodeIfPresent(Int64.self, forKey: .budget_id)
        budgetvalue = try values.decodeIfPresent(String.self, forKey: .budgetvalue)
        self.maptoDBModel()
    }

}
extension BudgetsResponseData{
    func maptoDBModel(){
        if QueryUtils.fetchExistingBudget(budget_id: self.budget_id ?? 0, category_id: self.categoryid ?? 0){
            LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
            LocalPrefs.setBudgetsTotal(count: LocalPrefs.getBudgetsTotal() - 1)
            LocalPrefs.setSyncBudgetsTotalCount(count: LocalPrefs.getSyncBudgetsTotalCount() + 1)
        } else {
            var budget : Hkb_budget = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_BUDGET, into: DbController.getContext()) as! Hkb_budget

            budget.categoryid = Int64(self.categoryid ?? 0)
            budget.budgetmonth = Int16(self.budgetmonth ?? 0)
            budget.budgetyear = Int16(self.budgetyear ?? 0)
            budget.budget_id = Int64(self.budget_id ?? 0)
            budget.budgetvalue = Double(self.budgetvalue ?? "0")!
            budget.is_synced = 1
            budget.active = Int32(self.active ?? 0)
            DbController.saveContext()
            LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
            LocalPrefs.setBudgetsTotal(count: LocalPrefs.getBudgetsTotal() - 1)
            LocalPrefs.setSyncBudgetsTotalCount(count: LocalPrefs.getSyncBudgetsTotalCount() + 1)
        }
    }
}
