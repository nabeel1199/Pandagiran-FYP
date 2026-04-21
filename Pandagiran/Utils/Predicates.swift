

import Foundation
import CoreData

class Predicates {
    
    static func accoundIdEquals (accountId : Int64) -> NSPredicate {
       
//        let predicate = NSPredicate(format : "account_id  == %li", [accountId: Int64.self])
        let predicate = NSPredicate(format : "account_id = %li" , accountId)
        return predicate
    }
    
    static func voucherIdEquals (voucher_Id : Int64) -> NSPredicate {
        let predicate = NSPredicate(format : "voucher_id = %li" , voucher_Id)
        return predicate
    }
    
    static func budgetIdEquals (budget_Id : Int64) -> NSPredicate {
        let predicate = NSPredicate(format : "budget_id = %li" , budget_Id)
        return predicate
    }
    
    static func monthEquals (month : String) -> NSPredicate {
        let predicate = NSPredicate(format : "month = %@" , month)
        return predicate
    }
    
    static func yearEquals (year : Int) -> NSPredicate {
        let predicate = NSPredicate(format : "vch_year = %i" , year)
        return predicate
    }
    
    static func categoryIdEquals (cateegoryId : Int64) -> NSPredicate {
        let predicate = NSPredicate(format : "category_id = %li" , cateegoryId)
        return predicate
    }
    
    static func categoryIDEquals (cateegoryId : Int64) -> NSPredicate {
        let predicate = NSPredicate(format : "categoryid = %li" , cateegoryId)
        return predicate
    }
    
    static func categoryIDEqual (cateegoryId : Int64) -> NSPredicate {
        let predicate = NSPredicate(format : "categoryId = %li" , cateegoryId)
        return predicate
    }
    
    static func eventIdEquals (eventId : Int64) -> NSPredicate {
        let predicate = NSPredicate(format : "eventid = %li" , eventId)
        return predicate
    }
    
    static func nameEquals (title : String) -> NSPredicate {
        let predicate = NSPredicate(format : "name = %@" , title)
        return predicate
    }
    
    static func titleEquals (title : String) -> NSPredicate {
        let predicate = NSPredicate(format : "title = %@" , title)
        return predicate
    }
    
    static func monthGreater (month : Int) -> NSPredicate {
        let predicate = NSPredicate(format : "month > %i" , month)
        return predicate
    }
    
    static func monthLesser (month : Int) -> NSPredicate {
        let predicate = NSPredicate(format : "month < %i" , month)
        return predicate
    }
    
    static func budgetCategory (categoryID : Int64) -> NSPredicate {
        let predicate = NSPredicate(format : "categoryid = %li" , categoryID)
        return predicate
    }
    
    static func budgetMonth (budgetMonth : Int) -> NSPredicate {
        let predicate = NSPredicate(format : "budgetmonth = %i" , budgetMonth)
        return predicate
    }
    
    static func budgetYear (budgetYear : Int) -> NSPredicate {
        let predicate = NSPredicate(format : "budgetyear = %i" , budgetYear)
        return predicate
    }
    
    static func budgetMonthGreater (budgetMonth : Int) -> NSPredicate {
        let predicate = NSPredicate(format : "budgetmonth > %i" , budgetMonth)
        return predicate
    }
    
    static func budgetMonthLesser (budgetMonth : Int) -> NSPredicate {
        let predicate = NSPredicate(format : "budgetmonth < %i" , budgetMonth)
        return predicate
    }
    
    static func activePredicate() -> NSPredicate {
        let predicate = NSPredicate(format : "active = %i" , 1)
        return predicate
    }
    
    static func isSynced() -> NSPredicate {
        let predicate = NSPredicate(format : "is_synced = %i" , 0)
        return predicate
    }
}
