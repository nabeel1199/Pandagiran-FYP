

import Foundation
import CoreData

class SyncUtils {
    
    static func fetchUnsyncedVouchers () -> Array<Hkb_voucher> {
        var arrayOfVouchers : Array<Hkb_voucher> = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_VOUCHER)
        let syncPredicate = NSPredicate(format : "is_synced = %i" , 0)
        fetchRequest.predicate = syncPredicate
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            
            for voucher in vouchers as! [Hkb_voucher] {
                arrayOfVouchers.append(voucher)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfVouchers
    }
    
    static func fetchUnsyncedBudgets () -> Array<Hkb_budget> {
        var arrayOfBUdgets : Array<Hkb_budget> = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_BUDGET)
        let syncPredicate = NSPredicate(format : "is_synced = %i" , 0)
        fetchRequest.predicate = syncPredicate
        
        do {
            let budgets = try DbController.getContext().fetch(fetchRequest)
            
            for budget in budgets as! [Hkb_budget] {
                arrayOfBUdgets.append(budget)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfBUdgets
    }
    
    static func fetchUnsyncedAccounts () -> Array<Hkb_account> {
        var arrayOfAccounts : Array<Hkb_account> = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_ACCOUNT)
        let syncPredicate = NSPredicate(format : "is_synced = %i" , 0)
        fetchRequest.predicate = syncPredicate
        
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest)
            
            for account in accounts as! [Hkb_account] {
                arrayOfAccounts.append(account)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfAccounts
    }
    
    static func fetchUnsyncedCategories () -> Array<Hkb_category> {
        var arrayOfCategories : Array<Hkb_category> = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_CATEGORY)
        let syncPredicate = NSPredicate(format : "is_synced = %i" , 0)
        fetchRequest.predicate = syncPredicate
        
        do {
            let categories = try DbController.getContext().fetch(fetchRequest)
            
            for category in categories as! [Hkb_category] {
                arrayOfCategories.append(category)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfCategories
    }
    
    static func fetchUnsyncedEvents () -> Array<Hkb_event> {
        var arrayOfEvents : Array<Hkb_event> = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_EVENT)
        let syncPredicate = NSPredicate(format : "is_synced = %i" , 0)
        fetchRequest.predicate = syncPredicate
        
        do {
            let events = try DbController.getContext().fetch(fetchRequest)
            
            for event in events as! [Hkb_event] {
                arrayOfEvents.append(event)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfEvents
    }
    
    static func fetchUnsyncedGoals () -> Array<Hkb_goal> {
        var arrayOfGoals : Array<Hkb_goal> = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_SAVING)
        let syncPredicate = NSPredicate(format : "is_synced = %i" , 0)
        fetchRequest.predicate = syncPredicate
        
        do {
            let savings = try DbController.getContext().fetch(fetchRequest)
            
            for saving in savings as! [Hkb_goal] {
                arrayOfGoals.append(saving)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfGoals
    }
    
    static func fetchUnsyncedGoalTrx () -> Array<Hkb_goal_trx> {
        var arrayOfGoalTrx : Array<Hkb_goal_trx> = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_SAVING_TRX)
        let syncPredicate = NSPredicate(format : "is_synced = %i" , 0)
        fetchRequest.predicate = syncPredicate
        
        do {
            let savings = try DbController.getContext().fetch(fetchRequest)
            
            for saving in savings as! [Hkb_goal_trx] {
                arrayOfGoalTrx.append(saving)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfGoalTrx
    }
}
