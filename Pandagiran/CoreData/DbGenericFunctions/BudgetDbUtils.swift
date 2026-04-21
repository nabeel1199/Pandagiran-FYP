
import Foundation
import CoreData

class BudgetDbUtils {
    
    static func fetchBudgets(catId : Int64 , currentInterval : String , month : String , year : Int) -> Array<Hkb_budget> {
        var arrayOfbudgets : Array<Hkb_budget> = []
        let fetchRequest : NSFetchRequest<Hkb_budget> = Hkb_budget.fetchRequest()
 
//        let sort = NSSortDescriptor(key: #keyPath(Hkb_voucher.created_on), ascending: true)
//        fetchRequest.sortDescriptors = [sort]
        //                fetchRequest.predicate = NSPredicate(format: "month = %i", month)
        
        if currentInterval == Constants.MONTHLY {
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.budgetCategory(categoryID: catId) , Predicates.budgetMonth(budgetMonth: Int(month)!) , Predicates.budgetYear(budgetYear: year)])
            fetchRequest.predicate = andPredicate
        } else if currentInterval == Constants.HALF_YEARLY {
            let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.budgetCategory(categoryID: catId) , Predicates.budgetMonthGreater(budgetMonth: firstIndex - 1) , Predicates.budgetMonthLesser(budgetMonth: lastIndex + 1) , Predicates.budgetYear(budgetYear: year)])
            fetchRequest.predicate = andPredicate
        } else if currentInterval == Constants.QUARTERLY {
            let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.budgetCategory(categoryID: catId) , Predicates.budgetMonthGreater(budgetMonth: firstIndex - 1) , Predicates.budgetMonthLesser(budgetMonth:  lastIndex + 1) , Predicates.budgetYear(budgetYear: year)])
            fetchRequest.predicate = andPredicate
        } else if currentInterval == Constants.YEARLY {
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.budgetCategory(categoryID: catId), Predicates.budgetYear(budgetYear: year)])
            fetchRequest.predicate = andPredicate
        } else {
            fetchRequest.predicate = Predicates.budgetCategory(categoryID: catId)
        }
        
        
        do {
            let budgets = try DbController.getContext().fetch(fetchRequest)
            print("Budgets : " , budgets.count)
            
            for vchBudget in budgets as [Hkb_budget] {
                arrayOfbudgets.append(vchBudget)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfbudgets
    }
    
    static func fetchVouchers(categoryId : Int , currentInterval : String , month : String , year : Int) -> Array<Hkb_voucher> {
        var arrayOfVouchers : Array<Hkb_voucher> = []
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Hkb_voucher.created_on), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let catPredicate = NSPredicate(format: "category_id = %i", categoryId)
        let expPredicate = NSPredicate(format: "vch_type = %@" , "Expense")
        
        if currentInterval == Constants.MONTHLY {
            let monthPredicate = NSPredicate(format : "month = %i" , Int(month)!)
            let yearPredicate = NSPredicate(format : "vch_year = %i" , year)
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [yearPredicate , monthPredicate , catPredicate , expPredicate])
            fetchRequest.predicate = andPredicate
        } else if currentInterval == Constants.HALF_YEARLY {
            print("Budget Months : " , month)
            let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
            let halfYearlyMonths = [firstIndex , firstIndex + 1 , lastIndex]
            
            let monthPredicate = NSPredicate(format : "month IN %@" , halfYearlyMonths)
            let yearPredicate = NSPredicate(format : "vch_year = %i" , year)
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [yearPredicate , monthPredicate , catPredicate , expPredicate])
            fetchRequest.predicate = andPredicate
        } else if currentInterval == Constants.QUARTERLY {
            let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
            let quarterlyMonths = [firstIndex , firstIndex + 1 , lastIndex]
            
            let monthPredicate = NSPredicate(format : "month IN %@" , quarterlyMonths)
            let yearPredicate = NSPredicate(format : "vch_year = %i" , year)
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [yearPredicate , monthPredicate , catPredicate , expPredicate])
            fetchRequest.predicate = andPredicate
        } else if currentInterval == Constants.YEARLY {
            let yearPredicate = NSPredicate(format: "vch_year = %i" , year)
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [yearPredicate , catPredicate , expPredicate])
            fetchRequest.predicate = andPredicate
        } else {
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [catPredicate , expPredicate])
            fetchRequest.predicate = andPredicate
        }
        
        //        if currentInterval != Constants.ALL_TIME {
        //            fetchRequest.predicate = NSPredicate(format : "vch_year = %i" , year)
        //        }
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            print("No of vouchers : " , vouchers.count)
            
            for vch in vouchers as [Hkb_voucher] {
                arrayOfVouchers.append(vch)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfVouchers
    }
    
    static func fetchBudgetAmount (categoryId : Int64 , currentInterval : String , month : String , year : Int) -> Double {
        let amountExpr = NSExpression(forKeyPath: "budgetvalue")
        let sumExpr = NSExpression(forFunction: "sum:", arguments: [amountExpr])
        let sumDescr = NSExpressionDescription()
        sumDescr.expression = sumExpr
        sumDescr.name = "sum"
        sumDescr.expressionResultType = .doubleAttributeType
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_BUDGET)
        fetchRequest.propertiesToFetch = [sumDescr]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        var andPredicate : NSPredicate?
        
        var sum : Double = 0
        
        
        if currentInterval == Constants.MONTHLY {
            if categoryId == 0 {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.budgetMonth(budgetMonth: Int(month)!) , Predicates.budgetYear(budgetYear: year), Predicates.activePredicate()])
            } else {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.budgetMonth(budgetMonth: Int(month)!) , Predicates.budgetYear(budgetYear: year) , Predicates.budgetCategory(categoryID: categoryId), Predicates.activePredicate()])
            }
    
            fetchRequest.predicate = andPredicate!
        } else if currentInterval == Constants.HALF_YEARLY || currentInterval == Constants.QUARTERLY {
            let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
            if categoryId == 0 {
              andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.budgetMonthGreater(budgetMonth: Int(firstIndex - 1)) , Predicates.budgetMonthLesser(budgetMonth: Int(lastIndex + 1)) , Predicates.budgetYear(budgetYear: year), Predicates.activePredicate()])
            } else {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.budgetMonthGreater(budgetMonth: Int(firstIndex - 1)) , Predicates.budgetMonthLesser(budgetMonth: Int(lastIndex + 1)) , Predicates.budgetYear(budgetYear: year) , Predicates.budgetCategory(categoryID: categoryId), Predicates.activePredicate()])
            }
    
            fetchRequest.predicate = andPredicate
        } else if currentInterval == Constants.YEARLY {
            if categoryId == 0 {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.budgetYear(budgetYear: year), Predicates.activePredicate()])
            } else {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.budgetYear(budgetYear: year) , Predicates.budgetCategory(categoryID: categoryId), Predicates.activePredicate()])
            }
            
            fetchRequest.predicate = andPredicate
        } else {
            if categoryId != 0 {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.budgetCategory(categoryID: categoryId), Predicates.activePredicate()])
                fetchRequest.predicate = andPredicate
            }
        }
        
        let results = try! DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
        
        for value in results {
            sum += value["sum"] as! Double
        }
        
        return sum
    }
    
    static func fetchAmountSpent (categoryId : Int64 , currentInterval : String , month : String , year : Int) -> Double {
        let amountExpr = NSExpression(forKeyPath: "vch_amount")
        let sumExpr = NSExpression(forFunction: "sum:", arguments: [amountExpr])
        let sumDescr = NSExpressionDescription()
        sumDescr.expression = sumExpr
        sumDescr.name = "sum"
        sumDescr.expressionResultType = .doubleAttributeType
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_VOUCHER)
        fetchRequest.propertiesToFetch = [sumDescr]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        var andPredicate : NSPredicate?
        let activePredicate = Predicates.activePredicate()
        let vchTypePredicate = NSPredicate(format : "vch_type = %@" , Constants.EXPENSE)
        
        var sum : Double = 0
        
        if currentInterval == Constants.MONTHLY {
            if categoryId == 0 {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.monthEquals(month: month) , Predicates.yearEquals(year: year) , activePredicate , vchTypePredicate])
            } else {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.monthEquals(month: month) , Predicates.yearEquals(year: year) , Predicates.categoryIdEquals(cateegoryId: categoryId) , activePredicate , vchTypePredicate])
            }
            
            fetchRequest.predicate = andPredicate
        } else if currentInterval == Constants.HALF_YEARLY || currentInterval == Constants.QUARTERLY {
            let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
            if categoryId == 0 {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.monthGreater(month: Int(firstIndex - 1)) , Predicates.monthLesser(month: Int(lastIndex + 1)) , Predicates.yearEquals(year: year) , activePredicate , vchTypePredicate])
            } else {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.monthGreater(month: Int(firstIndex - 1)) , Predicates.monthLesser(month: Int(lastIndex + 1)) , Predicates.yearEquals(year: year) , Predicates.categoryIdEquals(cateegoryId: categoryId) , activePredicate , vchTypePredicate])
            }
            
            fetchRequest.predicate = andPredicate
        } else if currentInterval == Constants.YEARLY {
            if categoryId == 0 {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.yearEquals(year: year) , activePredicate , vchTypePredicate])
            } else {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.yearEquals(year: year) , Predicates.categoryIdEquals(cateegoryId: categoryId) , activePredicate , vchTypePredicate])
            }
            
            fetchRequest.predicate = andPredicate
        } else {
            if categoryId == 0 {
                   andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [activePredicate , vchTypePredicate])
                fetchRequest.predicate = activePredicate
            } else {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.categoryIdEquals(cateegoryId: categoryId) , activePredicate , vchTypePredicate])
                fetchRequest.predicate = andPredicate
            }
        }
        
        let results = try! DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
        
        for value in results {
            sum += value["sum"] as! Double
        }
        
        return sum
    }

    static func fetchSingleBudget (categoryId : Int64 , month : Int , year : Int) -> Hkb_budget? {
        var hkb_budget : Hkb_budget?
        let fetchRequest : NSFetchRequest<Hkb_budget> = Hkb_budget.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let monthPredicate = Predicates.budgetMonth(budgetMonth: month)
        let yearPredicate = Predicates.budgetYear(budgetYear: year)
        let categoryPredicate = Predicates.budgetCategory(categoryID: categoryId)
        let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [categoryPredicate , monthPredicate , yearPredicate])
        fetchRequest.predicate = andPredicate
        
        do {
            let budgets = try DbController.getContext().fetch(fetchRequest)
            
            for budget in budgets as [Hkb_budget] {
                hkb_budget = budgets[0]
            }
        } catch {
            print("Error : " , error)
        }
        
        if let budget = hkb_budget {
            return budget
        } else {
            return nil
        }
    }
    
    static func clearBudget (month : Int , year : Int , categoryId : Int64) {
        let fetchRequest : NSFetchRequest<Hkb_budget> = Hkb_budget.fetchRequest()
        
        let categoryPredicate = Predicates.budgetCategory(categoryID: categoryId)
        let monthStartPredicate = NSPredicate(format : "budgetmonth >= %i" , month)
        let monthEndPredicate = NSPredicate(format : "budgetmonth <= 12")
        let yearPredicate = Predicates.budgetYear(budgetYear: year)
        let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [categoryPredicate , monthStartPredicate , monthEndPredicate , yearPredicate])
        fetchRequest.predicate = andPredicate
        print("Month : " , month , "Year : " , year , "Cat id : " , categoryId)
        
        do {
            let budgets = try DbController.getContext().fetch(fetchRequest)
            
            for budget in budgets as [Hkb_budget] {
                DbController.getContext().delete(budget)
            }
        } catch {
            print("Error : " , error)
        }
    }
    
    static func fetchBudgetCount (categoryId : Int64) -> Int {
        var count : Int = 0
        let fetchRequest : NSFetchRequest<Hkb_budget> = Hkb_budget.fetchRequest()
        let categoryPredicate = Predicates.budgetCategory(categoryID: categoryId)
        fetchRequest.predicate = categoryPredicate
        
        do {
            count = try DbController.getContext().count(for: fetchRequest)
        } catch {
            print("error is" , error)
        }
        
        return count
    }
}
