
import Foundation
import CoreData

class SavingDbUtils {
    
    static func fetchRunningSavings (type : String) -> Array<Hkb_goal> {
        var arrayOfGoals : Array<Hkb_goal> = []
        let activePredicate = Predicates.activePredicate()
        let isRunningPredicate = NSPredicate(format : "actualenddate == nil")
        let isFinishedPreicate = NSPredicate(format : "actualenddate != nil")
//        let isFinishedPreicate = NSPredicate(format : "actualenddate != nil")
        var andPredicate = NSCompoundPredicate()
        
        if type == "Running" {
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [activePredicate , isRunningPredicate])
        } else {
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [activePredicate , isFinishedPreicate])
        }
        
        
        let fetchRequest : NSFetchRequest<Hkb_goal> = Hkb_goal.fetchRequest()
        fetchRequest.predicate = andPredicate
        
        do {
            let goals = try DbController.getContext().fetch(fetchRequest)
            
            for goal in goals as [Hkb_goal] {
                
                print(goal)
                arrayOfGoals.append(goal)
                    
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfGoals
    }
    
    static func getSavingCategory () -> Hkb_category {
        var hkb_category : Hkb_category?
        let savingPredicate = NSPredicate(format : "title = %@" , "Savings")
        
        let fetchRequest : NSFetchRequest<Hkb_category> = Hkb_category.fetchRequest()
        fetchRequest.predicate = savingPredicate
        fetchRequest.fetchLimit = 1
        
        do {
            let categories = try DbController.getContext().fetch(fetchRequest)
            
            if let category = categories.first as? Hkb_category {
                hkb_category = category
            }
        } catch {
            print("Error : " , error)
        }
        
        return hkb_category!
    }
    
    static func fetchSavingTransactions (goalId : Int64) -> Array<Hkb_goal_trx> {
        var vchArray : Array<Hkb_goal_trx> = []
        let activePredicate = Predicates.activePredicate()
        let goalIdPredicate = NSPredicate(format : "goalid = %li" , goalId)
        let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [activePredicate , goalIdPredicate])
        
        let fetchRequest : NSFetchRequest<Hkb_goal_trx> = Hkb_goal_trx.fetchRequest()
        fetchRequest.predicate = andPredicate
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            
            for voucher in vouchers as [Hkb_goal_trx] {
                vchArray.append(voucher)
            }
        } catch {
            print("Error : " , error)
        }
        
        return vchArray
    }
    
    static func fetchSavedAmount (goalId : Int) -> Double {
        var sum : Double = 0
        let amountExpr = NSExpression(forKeyPath: "amount")
        let sumExpr = NSExpression(forFunction: "sum:", arguments: [amountExpr])
        let sumDescr = NSExpressionDescription()
        sumDescr.expression = sumExpr
        sumDescr.name = "sum"
        sumDescr.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_SAVING_TRX)
        fetchRequest.propertiesToFetch = [sumDescr]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        let activePredicate = Predicates.activePredicate()
        let goalIdPredicate = NSPredicate(format : "goalid = %li" , goalId)
        
        if goalId == 0 {
            fetchRequest.predicate = activePredicate
        } else {
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [ activePredicate , goalIdPredicate ])
            fetchRequest.predicate = andPredicate
        }

        
        
        let results = try! DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
        
        for value in results {
            sum += value["sum"] as! Double
            print("Sum is : " , sum)
        }
        
        return sum
    }
    
    static func fetchTotalSavingsAmount () -> Double {
        var sum : Double = 0
        let amountExpr = NSExpression(forKeyPath: "amount")
        let sumExpr = NSExpression(forFunction: "sum:", arguments: [amountExpr])
        let sumDescr = NSExpressionDescription()
        sumDescr.expression = sumExpr
        sumDescr.name = "sum"
        sumDescr.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_SAVING)
        fetchRequest.propertiesToFetch = [sumDescr]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        let activePredicate = Predicates.activePredicate()
    
        fetchRequest.predicate = activePredicate
      
        
        let results = try! DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
        
        for value in results {
            sum += value["sum"] as! Double
            print("Sum is : " , sum)
        }
        
        return sum
    }
    
    static func getLastSavingVoucher (goalId : Int) -> Hkb_goal_trx? {
        var lastVoucher : Hkb_goal_trx?
        let fetchRequest : NSFetchRequest<Hkb_goal_trx> = Hkb_goal_trx.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "voucherId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let activePredicate = Predicates.activePredicate()
        let goalIdPredicate = NSPredicate(format : "goalid = %li" , goalId )
        let andpredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates : [activePredicate , goalIdPredicate])
        fetchRequest.predicate = andpredicate
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            
            if let voucher = vouchers.last  {
                lastVoucher = voucher
            }
        } catch {
            print("Error : " , error)
        }
        
        return lastVoucher
    }
    
    static func deleteSingleVoucher (voucherId : Int) {
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "voucher_id = %li" , voucherId)
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            
            for voucher in vouchers as [Hkb_voucher] {
                DbController.getContext().delete(voucher)
                DbController.saveContext()
            }
        } catch {
            print("Error : " , error)
        }
        
    }
    
    static func fetchSavingAccount () -> (Hkb_account, Bool) {
        var isAccountCreated = false
        var hkb_account : Hkb_account?
        let fetchRequest : NSFetchRequest<Hkb_account> = Hkb_account.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "acctype in (%@)", ["Savings", "Saving"])
        
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest)
            
            if let account = accounts.first {
                hkb_account = account
            } else {
                let account : Hkb_account = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_ACCOUNT, into: DbController.getContext()) as! Hkb_account
//                let maxAccountId = QueryUtils.getMaxAccountId()
                account.active = 1
//                account.account_id = Int64(QueryUtils.getMaxAccountId() + 1)
                account.account_id =  Utils.getUniqueId()
                account.title = "Savings"
                account.acctype = "Savings"
                account.boxicon = "bt_12"
                account.openingbalance = 0
                account.is_synced = 0
                isAccountCreated = true
                
                hkb_account = account
                DbController.saveContext()
            }
        } catch {
            print("Error : " , error)
        }
        
        return (hkb_account!, isAccountCreated)
    }
}
