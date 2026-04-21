

import Foundation
import CoreData

struct ConstantCategoryData : Codable {
    let active : Int?
    let categoryId : Int64?
    let is_expense : Int?
    let budgetamount : String?
    let cattype : String?
    let parent_category_id : Int?
    let title : String?
    let box_color : String?
    let box_icon : String?

    enum CodingKeys: String, CodingKey {

        case active = "active"
        case categoryId = "categoryId"
        case is_expense = "is_expense"
        case budgetamount = "budgetamount"
        case cattype = "cattype"
        case parent_category_id = "parent_category_id"
        case title = "title"
        case box_color = "box_color"
        case box_icon = "box_icon"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        active = try values.decodeIfPresent(Int.self, forKey: .active)
        categoryId = try values.decodeIfPresent(Int64.self, forKey: .categoryId)
        is_expense = try values.decodeIfPresent(Int.self, forKey: .is_expense)
        budgetamount = try values.decodeIfPresent(String.self, forKey: .budgetamount)
        cattype = try values.decodeIfPresent(String.self, forKey: .cattype)
        parent_category_id = try values.decodeIfPresent(Int.self, forKey: .parent_category_id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        box_color = try values.decodeIfPresent(String.self, forKey: .box_color)
        box_icon = try values.decodeIfPresent(String.self, forKey: .box_icon)
        self.maptoDBModel()
    }

}
extension ConstantCategoryData {
    func maptoDBModel(){
//        if QueryUtils.fetchExistingCategory(category_id: self.categoryId ?? 0, category_title: self.title ?? ""){
//            LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
//            LocalPrefs.setCategoriesTotal(count: LocalPrefs.getCategoriesTotal() - 1)
//            LocalPrefs.setSyncCategoriesTotalCount(count: LocalPrefs.getSyncCategoriesTotalCount() + 1)
//        } else {
            var category : Hkb_category = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_CATEGORY, into: DbController.getContext()) as! Hkb_category
//            var category: Hkb_category?
            category.categoryId = Int64(self.categoryId ?? 0)
            category.parent_category_id = Int64(self.parent_category_id ?? 0)
            category.active = Int16(self.active ?? 0)
            category.is_expense = Int16(self.is_expense ?? 0)
            category.budgetAmount = Double(self.budgetamount ?? "0.0")!
            category.budget_amount = Double(self.budgetamount ?? "0.0")!
            category.cattype = self.cattype ?? ""
            category.title = self.title ?? ""
            category.is_synced = 1
            category.box_color = self.box_color ?? ""
            category.box_icon = self.box_icon ?? ""
            DbController.saveContext()
//            LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
//            LocalPrefs.setCategoriesTotal(count: LocalPrefs.getCategoriesTotal() - 1)
//            LocalPrefs.setSyncCategoriesTotalCount(count: LocalPrefs.getSyncCategoriesTotalCount() + 1)
//        }
    }
}
