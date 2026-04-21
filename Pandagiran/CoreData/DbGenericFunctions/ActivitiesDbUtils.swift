
import Foundation
import CoreData

class ActivitiesDbUtils {
    
    static func fetchVouchers(accountId : Int64 ,
                              categoryId : Int64 ,
                              type : String ,
                              currentInterval : String ,
                              month : String ,
                              year : Int,
                              offset : Int,
                              limit: Int) -> Array<Hkb_voucher> {
        
        var arrayOfVouchers : Array<Hkb_voucher> = []
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Hkb_voucher.vch_date), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        let isActivePredicate = NSPredicate(format : "active = %i" , 1)
        let vchNoPredicate = NSPredicate(format : "vch_no = %@" , "1")
        let typePredicate = NSPredicate(format : "vch_type = %@" , type)
        let accountIdPredicate = Predicates.accoundIdEquals(accountId: accountId)
        let categoryIdPredicate = Predicates.categoryIdEquals(cateegoryId: categoryId)
        var andPredicate : NSCompoundPredicate?
        var predicateArray : Array<NSPredicate> = []
        predicateArray.append(isActivePredicate)
        predicateArray.append(vchNoPredicate)
        fetchRequest.fetchOffset = 0
        
        if limit != 0 {
            fetchRequest.fetchLimit = limit
        }
        
        if currentInterval == Constants.MONTHLY {
            predicateArray.append(Predicates.monthEquals(month: month))
            predicateArray.append(Predicates.yearEquals(year: year))
            if categoryId != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountId != 0 {
                predicateArray.append(accountIdPredicate)
                predicateArray.remove(at: predicateArray.firstIndex(of: vchNoPredicate)!)
            }
            if type != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        }  else if currentInterval == Constants.QUARTERLY || currentInterval == Constants.HALF_YEARLY {
            let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
            predicateArray.append(Predicates.monthGreater(month: firstIndex - 1))
            predicateArray.append(Predicates.monthLesser(month: lastIndex + 1))
            predicateArray.append(Predicates.yearEquals(year: year))
            if categoryId != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountId != 0 {
                predicateArray.append(accountIdPredicate)
                predicateArray.remove(at: predicateArray.index(of: vchNoPredicate)!)
            }
            if type != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else if currentInterval == Constants.YEARLY {
            predicateArray.append(Predicates.yearEquals(year: year))
            if categoryId != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountId != 0 {
                predicateArray.append(accountIdPredicate)
                predicateArray.remove(at: predicateArray.index(of: vchNoPredicate)!)
            }
            if type != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else {
            if categoryId != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountId != 0 {
                predicateArray.append(accountIdPredicate)
                predicateArray.remove(at: predicateArray.index(of: vchNoPredicate)!)
            }
            if type != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        }

        fetchRequest.predicate = andPredicate
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            print("No of vouchers : " , vouchers.count)
            
            for vch in vouchers as [Hkb_voucher] {
                print("VOUCHER IS : " , vch)
                arrayOfVouchers.append(vch)
                
            }
        } catch {
            print("Error : " , error)
        }
        return arrayOfVouchers
    }
    
    static func fetchFilteredVouchers(accountId : Int64 , categoryId : Int64 , eventId: Int64, type : String , amountRange: String, currentInterval : String , month : String , year : Int, sortBy: String, isAscending: Bool, offset: Int, limit: Int) -> Array<Hkb_voucher> {
        var arrayOfVouchers : Array<Hkb_voucher> = []
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        let isActivePredicate = NSPredicate(format : "active = %i" , 1)
        let vchNoPredicate = NSPredicate(format : "vch_no = %@" , "1")
        let typePredicate = NSPredicate(format : "vch_type = %@" , type)
        let accountIdPredicate = Predicates.accoundIdEquals(accountId: accountId)
        let categoryIdPredicate = Predicates.categoryIdEquals(cateegoryId: categoryId)
        let eventIdPredicate = NSPredicate(format: "eventid = %i", eventId)
        var andPredicate : NSCompoundPredicate?
        var predicateArray : Array<NSPredicate> = []
        predicateArray.append(isActivePredicate)
        predicateArray.append(vchNoPredicate)
        fetchRequest.fetchOffset = offset
        
        if limit != 0 {
            fetchRequest.fetchLimit = limit
        }
        
        if amountRange != "" {
            let rangeArray = amountRange.split(separator: "-")
            let startAmount = Double(rangeArray[0])
            let endAmount = Double(rangeArray[1])
            let greaterThanPred = (NSPredicate(format: "abs(vch_amount) > %f", startAmount!))
            let LesserThanPred = (NSPredicate(format: "abs(vch_amount) < %f", endAmount!))
            predicateArray.append(greaterThanPred)
            predicateArray.append(LesserThanPred)
        }
        
        var sort = NSSortDescriptor()
        if sortBy == "date" {
            sort = NSSortDescriptor(key: #keyPath(Hkb_voucher.vch_date), ascending: isAscending)
        } else {
            sort = NSSortDescriptor(key: #keyPath(Hkb_voucher.vch_amount), ascending: isAscending)
        }
        
        if currentInterval == Constants.MONTHLY {
            predicateArray.append(Predicates.monthEquals(month: month))
            predicateArray.append(Predicates.yearEquals(year: year))
            if categoryId != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountId != 0 {
                predicateArray.append(accountIdPredicate)
                predicateArray.remove(at: predicateArray.index(of: vchNoPredicate)!)
            }
            
            if eventId != 0 {
                predicateArray.append(eventIdPredicate)
            }
            
            if type != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        }  else if currentInterval == Constants.QUARTERLY || currentInterval == Constants.HALF_YEARLY {
            let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
            predicateArray.append(Predicates.monthGreater(month: firstIndex - 1))
            predicateArray.append(Predicates.monthLesser(month: lastIndex + 1))
            predicateArray.append(Predicates.yearEquals(year: year))
            if categoryId != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountId != 0 {
                predicateArray.append(accountIdPredicate)
                predicateArray.remove(at: predicateArray.index(of: vchNoPredicate)!)
            }
            
            if eventId != 0 {
                predicateArray.append(eventIdPredicate)
            }
            
            if type != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else if currentInterval == Constants.YEARLY {
            predicateArray.append(Predicates.yearEquals(year: year))
            if categoryId != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountId != 0 {
                predicateArray.append(accountIdPredicate)
                predicateArray.remove(at: predicateArray.index(of: vchNoPredicate)!)
            }
            
            if eventId != 0 {
                predicateArray.append(eventIdPredicate)
            }
            
            if type != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else {
            if categoryId != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountId != 0 {
                predicateArray.append(accountIdPredicate)
                predicateArray.remove(at: predicateArray.firstIndex(of: vchNoPredicate)!)
            }
            
            if eventId != 0 {
                predicateArray.append(eventIdPredicate)
            }
            
            if type != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        }
        print("PREDICATE ARRAY : " , predicateArray)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = andPredicate
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            print("No of vouchers : " , vouchers.count)
            
            for vch in vouchers as [Hkb_voucher] {
                print("VOUCHER IS : " , vch)
                arrayOfVouchers.append(vch)
                
            }
        } catch {
            print("Error : " , error)
        }
        return arrayOfVouchers
    }
    
    static func fetchEventVouchers (eventId: Int64) -> Array<Hkb_voucher> {
        var arrayOfVouchers : Array<Hkb_voucher> = []
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Hkb_voucher.vch_date), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        let isActivePredicate = NSPredicate(format : "active = %i" , 1)
        let vchNoPredicate = NSPredicate(format : "vch_no = %@" , "1")
        let eventIdPredicate = NSPredicate(format: "eventid = %li", eventId)
    
        let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [isActivePredicate, vchNoPredicate, eventIdPredicate])
        fetchRequest.predicate = andPredicate
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            
            for vch in vouchers as [Hkb_voucher] {
                arrayOfVouchers.append(vch)
                
            }
        } catch {
            print("Error : " , error)
        }
        return arrayOfVouchers
    }
    
    static func fetchInflowAndOutflow(type : String , vchType : String , accountID : Int64 , categoryID : Int64 , currentInterval : String , month : String , year : Int) -> Double {
        var sum : Double = 0
        
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
        var vchTypePredicate = NSPredicate()
        let isActivePredicate = NSPredicate(format : "active = %i" , 1)
        let accountIdPredicate = Predicates.accoundIdEquals(accountId: accountID)
        let categoryIdPredicate = Predicates.categoryIdEquals(cateegoryId: categoryID)
        var andPredicate : NSCompoundPredicate?
        var predicateArray : Array<NSPredicate> = []
        predicateArray.append(isActivePredicate)
        var typePredicate = NSPredicate(format : "vch_type = %@" , vchType)
        
        if type == "Inflow" {
            vchTypePredicate = NSPredicate(format : "vch_amount > %i" , 0)
            predicateArray.append(vchTypePredicate)
        } else {
            vchTypePredicate = NSPredicate(format : "vch_amount < %i" , 0)
            predicateArray.append(vchTypePredicate)
        }
        
        let accountIDPredicate = Predicates.accoundIdEquals(accountId: accountID)
        let categoryIDPredicate = Predicates.categoryIdEquals(cateegoryId: categoryID)
        
        if currentInterval == Constants.MONTHLY {
            predicateArray.append(Predicates.monthEquals(month: month))
            predicateArray.append(Predicates.yearEquals(year: year))
            if categoryID != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountID != 0 {
                predicateArray.append(accountIdPredicate)
            }
            if vchType != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        }  else if currentInterval == Constants.QUARTERLY || currentInterval == Constants.HALF_YEARLY {
            let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
            predicateArray.append(Predicates.monthGreater(month: firstIndex - 1))
            predicateArray.append(Predicates.monthLesser(month: lastIndex + 1))
            predicateArray.append(Predicates.yearEquals(year: year))
            if categoryID != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountID != 0 {
                predicateArray.append(accountIdPredicate)
            }
            if vchType != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else if currentInterval == Constants.YEARLY {
            predicateArray.append(Predicates.yearEquals(year: year))
            if categoryID != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountID != 0 {
                predicateArray.append(accountIdPredicate)
            }
            if vchType != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else {
            if categoryID != 0 {
                predicateArray.append(categoryIdPredicate)
            }
            if accountID != 0 {
                predicateArray.append(accountIdPredicate)
            }
            if vchType != "" {
                predicateArray.append(typePredicate)
            }
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        }
        
        fetchRequest.predicate = andPredicate
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
            
            for vch in vouchers {
                sum += vch["sum"] as! Double
                print("Sum is : " , sum)
            }
        } catch {
            print ("Error : " , error)
        }
        
        return sum
    }
    
    static func getClosingBalance(accountId : Int64 , categoryId : Int64 , type : String ,  firstValue : Bool, currentInterval : String , month : String , year : Int) -> Double {
        var sum : Double = 0
        
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
        var yearPredicate : NSPredicate?
        var monthPredicate : NSPredicate?
        let activePredicate = NSPredicate(format: "active = %i" , 1)
        let vchNoPredicate = NSPredicate(format: "vch_no = %i", 0)
        var andPredicate = NSCompoundPredicate()
        var predicateArray : Array<NSPredicate> = []
        predicateArray.append(activePredicate)
        
        if currentInterval == Constants.MONTHLY {
            
            if firstValue {
                monthPredicate = NSPredicate(format : "month <= %i" , Int(month) ?? Utils.getCurrentMonth())
                yearPredicate = NSPredicate(format : "vch_year = %i" , year)
            } else {
                monthPredicate = NSPredicate(format : "month <= %i" , Int(month) ?? Utils.getCurrentMonth())
                yearPredicate = NSPredicate(format : "vch_year < %i" , year)
            }
            
            if accountId != 0 {
                predicateArray.append(Predicates.accoundIdEquals(accountId: accountId))
            } else {
                predicateArray.append(vchNoPredicate)
            }
            
            if categoryId != 0 {
                predicateArray.append(Predicates.categoryIdEquals(cateegoryId: categoryId))
            }
            
            if type != "" {
                predicateArray.append(NSPredicate(format : "vch_type = %@" , type))
            }
            
            predicateArray.append(monthPredicate!)
            predicateArray.append(yearPredicate!)
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else if currentInterval == Constants.HALF_YEARLY || currentInterval == Constants.QUARTERLY {
            if firstValue {
                let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
                monthPredicate = NSPredicate(format : "month <= %i" , Int(lastIndex))
                yearPredicate = NSPredicate(format : "vch_year = %i" , year)
            } else {
                yearPredicate = NSPredicate(format : "vch_year < %i" , year)
                monthPredicate = NSPredicate(format : "month <= %i" , Int(month)!)
            }
            
            if accountId != 0 {
                predicateArray.append(Predicates.accoundIdEquals(accountId: accountId))
            }
            
            if categoryId != 0 {
                predicateArray.append(Predicates.categoryIdEquals(cateegoryId: categoryId))
            }
            
            if type != "" {
                predicateArray.append(NSPredicate(format : "vch_type = %@" , type))
            }
            
            predicateArray.append(monthPredicate!)
            predicateArray.append(yearPredicate!)
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else if currentInterval == Constants.YEARLY {
            yearPredicate = NSPredicate(format: "vch_year <= %i" , year)
            
            predicateArray.append(yearPredicate!)
            
            if accountId != 0 {
                predicateArray.append(Predicates.accoundIdEquals(accountId: accountId))
            }
            
            if categoryId != 0 {
                predicateArray.append(Predicates.categoryIdEquals(cateegoryId: categoryId))
            }
            
            if type != "" {
                predicateArray.append(NSPredicate(format : "vch_type = %@" , type))
            }
            
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else {
            if accountId != 0 {
                predicateArray.append(Predicates.accoundIdEquals(accountId: accountId))
            }
            
            if categoryId != 0 {
                predicateArray.append(Predicates.categoryIdEquals(cateegoryId: categoryId))
            }
            
            if type != "" {
                predicateArray.append(NSPredicate(format : "vch_type = %@" , type))
            }
            
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        }
        
        fetchRequest.predicate = andPredicate
        
        let results = try! DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
        
        for value in results {
            sum += value["sum"] as! Double
            print("Sum is : " , sum)
        }
        
        
        return sum
    }
    
    static func getOpeningBalance(accountId : Int64 , categoryId : Int64 , type : String ,  firstValue : Bool, currentInterval : String , month : String , year : Int) -> Double {
        var sum : Double = 0
        
        
        let amountExpr = NSExpression(forKeyPath: "vch_amount")
        let sumExpr = NSExpression(forFunction: "sum:", arguments: [amountExpr])
        let sumDescr = NSExpressionDescription()
        sumDescr.expression = sumExpr
        sumDescr.name = "sum"
        sumDescr.expressionResultType = .doubleAttributeType
        let accountIdPredicate = NSPredicate(format : "account_id = %i" , accountId)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_VOUCHER)
        fetchRequest.propertiesToFetch = [sumDescr]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        var yearPredicate : NSPredicate?
        var monthPredicate : NSPredicate?
        let activePredicate = NSPredicate(format: "active = %i" , 1)
        var andPredicate = NSCompoundPredicate()
        var predicateArray : Array<NSPredicate> = []
        predicateArray.append(activePredicate)
        
        if currentInterval == Constants.MONTHLY {
            
            if firstValue {
                monthPredicate = NSPredicate(format : "month < %i" , Int(month)!)
                yearPredicate = NSPredicate(format : "vch_year = %i" , year)
            } else {
                monthPredicate = NSPredicate(format : "month <= %i" , Int(month)!)
                yearPredicate = NSPredicate(format : "vch_year < %i" , year)
            }
            
            if accountId != 0 {
                predicateArray.append(Predicates.accoundIdEquals(accountId: accountId))
            }
            
            if categoryId != 0 {
                predicateArray.append(Predicates.categoryIdEquals(cateegoryId: categoryId))
            }
            
            if type != "" {
                predicateArray.append(NSPredicate(format : "vch_type = %@" , type))
            }
            
            predicateArray.append(monthPredicate!)
            predicateArray.append(yearPredicate!)
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else if currentInterval == Constants.HALF_YEARLY || currentInterval == Constants.QUARTERLY {
            if firstValue {
                let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
                monthPredicate = NSPredicate(format : "month < %i" , Int(firstIndex))
                yearPredicate = NSPredicate(format : "vch_year = %i" , year)
            } else {
                yearPredicate = NSPredicate(format : "vch_year < %i" , year)
                monthPredicate = NSPredicate(format : "month <= %i" , Int(month)!)
            }
            
            if accountId != 0 {
                predicateArray.append(Predicates.accoundIdEquals(accountId: accountId))
            }
            
            if categoryId != 0 {
                predicateArray.append(Predicates.categoryIdEquals(cateegoryId: categoryId))
            }
            
            if type != "" {
                predicateArray.append(NSPredicate(format : "vch_type = %@" , type))
            }
            
            predicateArray.append(monthPredicate!)
            predicateArray.append(yearPredicate!)
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else if currentInterval == Constants.YEARLY {
            yearPredicate = NSPredicate(format: "vch_year < %i" , year)
            
            predicateArray.append(yearPredicate!)
            
            if accountId != 0 {
                predicateArray.append(Predicates.accoundIdEquals(accountId: accountId))
            }
            
            if categoryId != 0 {
                predicateArray.append(Predicates.categoryIdEquals(cateegoryId: categoryId))
            }
            
            if type != "" {
                predicateArray.append(NSPredicate(format : "vch_type = %@" , type))
            }
            
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        } else {
            if accountId != 0 {
                predicateArray.append(Predicates.accoundIdEquals(accountId: accountId))
            }
            
            if categoryId != 0 {
                predicateArray.append(Predicates.categoryIdEquals(cateegoryId: categoryId))
            }
            
            if type != "" {
                predicateArray.append(NSPredicate(format : "vch_type = %@" , type))
            }
            
            andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        }
        
        fetchRequest.predicate = andPredicate
        
        let results = try! DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
        
        for value in results {
            sum += value["sum"] as! Double
            print("Sum is : " , sum)
        }
        
        if currentInterval == Constants.ALL_TIME {
            return 0
        } else {
           return sum
        }
    }
    
 
    
    static func getAccountBalance (accountID : Int64) -> Double {
        var sum : Double = 0
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
        let activePredicate = Predicates.activePredicate()
        let accountIDPredicate = Predicates.accoundIdEquals(accountId: accountID)
        
        if accountID != 0 {
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [ activePredicate , accountIDPredicate ])
            fetchRequest.predicate = andPredicate
        } else {
//            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [ activePredicate])
            fetchRequest.predicate = activePredicate
        }
        
        
        let results = try! DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
        
        for value in results {
            sum += value["sum"] as! Double
            print("Sum is : " , sum)
        }
        
        return sum
    }
    
    static func getVoucherSumWithCategoryID (categoryId : Int64 , type : String , currentInterval : String , month : String , year : Int) -> Double {
        var sum : Double = 0
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
        let categoryIdPredicate = Predicates.categoryIdEquals(cateegoryId: categoryId)
        let activePredicate = Predicates.activePredicate()
        let vchNoPredicate = NSPredicate(format : "vch_no = %@" , "1")
        let vchTypePredicate = NSPredicate(format : "vch_type = %@" , type)
        
        if currentInterval == Constants.MONTHLY {
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.monthEquals(month: month) , Predicates.yearEquals(year: year) , activePredicate , categoryIdPredicate , vchTypePredicate])
            fetchRequest.predicate = andPredicate
        }  else if currentInterval == Constants.QUARTERLY || currentInterval == Constants.HALF_YEARLY {
            let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
            
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.monthGreater(month: firstIndex - 1) , Predicates.monthLesser(month: lastIndex + 1) , Predicates.yearEquals(year: year) , activePredicate , vchNoPredicate , categoryIdPredicate , vchTypePredicate])
            fetchRequest.predicate = andPredicate
        } else if currentInterval == Constants.YEARLY {
            fetchRequest.predicate = Predicates.yearEquals(year: year)
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.yearEquals(year: year) , activePredicate , vchNoPredicate , categoryIdPredicate , vchTypePredicate])
            fetchRequest.predicate = andPredicate
        } else {
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [activePredicate , vchNoPredicate , categoryIdPredicate , vchTypePredicate])
            fetchRequest.predicate = andPredicate
        }
        
        let results = try! DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
        
        for value in results {
            sum += value["sum"] as! Double
            print("Sum is : " , sum)
        }
        
        return sum
    }
    
    static func getTotalIncomeAndExpense (vchType : String , currentInterval : String , month : String , year : Int) -> Double {
            var sum : Double = 0
            
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
            var vchTypePredicate = NSPredicate(format : "vch_type = %@" , vchType)
            let isActivePredicate = NSPredicate(format : "active = %i" , 1)
            var andPredicate : NSCompoundPredicate?
            var predicateArray : Array<NSPredicate> = []
            predicateArray.append(isActivePredicate)
            predicateArray.append(vchTypePredicate)
        
        
            if currentInterval == Constants.MONTHLY {
                predicateArray.append(Predicates.monthEquals(month: month))
                predicateArray.append(Predicates.yearEquals(year: year))
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
            }  else if currentInterval == Constants.QUARTERLY || currentInterval == Constants.HALF_YEARLY {
                let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
                predicateArray.append(Predicates.monthGreater(month: firstIndex - 1))
                predicateArray.append(Predicates.monthLesser(month: lastIndex + 1))
                predicateArray.append(Predicates.yearEquals(year: year))
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
            } else if currentInterval == Constants.YEARLY {
                predicateArray.append(Predicates.yearEquals(year: year))
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
            } else {
                andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
            }
            
            fetchRequest.predicate = andPredicate
        
            do {
                let vouchers = try DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
                
                for vch in vouchers {
                    sum += vch["sum"] as! Double
                    print("Sum is : " , sum)
                }
            } catch {
                print ("Error : " , error)
            }
            
            return sum
        
    }
    
    static func getCategoryBalance (categoryId : Int64 , month : String , year : Int) -> Double {
        var sum : Double = 0
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
        let categoryIdPredicate = Predicates.categoryIdEquals(cateegoryId: categoryId)
        let activePredicate = Predicates.activePredicate()
        let monthPred = Predicates.monthEquals(month: month)
        let yearPred = Predicates.yearEquals(year: year)
        
        if month != "" && year != 0 {
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [categoryIdPredicate , activePredicate , monthPred , yearPred])
            fetchRequest.predicate = andPredicate
        } else {
            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [categoryIdPredicate , activePredicate])
            fetchRequest.predicate = andPredicate
        }

        let results = try! DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
        
        for value in results {
            sum += value["sum"] as! Double
            print("Sum is : " , sum)
        }
        
        return sum
    }
    
    static func fetchSearchResults (currentInterval : String , month : String , year : Int , searchString : String) -> Array<Hkb_voucher> {
        
        var arrayOfVouchers : Array<Hkb_voucher> = []
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Hkb_voucher.vch_date), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        let isActivePredicate = NSPredicate(format : "active = %i" , 1)
        let vchNoPredicate = NSPredicate(format : "vch_no = %@" , "1")
        let searchPredicate = NSPredicate(format : "categoryname contains[c] %@ OR accountname contains[c] %@ OR vch_type contains[c] %@" , searchString , searchString , searchString)
        let andPredicate = NSCompoundPredicate(type : .and , subpredicates: [isActivePredicate , vchNoPredicate , searchPredicate, searchPredicate])
        fetchRequest.predicate = andPredicate
//        if currentInterval == Constants.MONTHLY {
//            let andPredicate = NSCompoundPredicate(type : .and , subpredicates: [Predicates.monthEquals(month: month) , Predicates.yearEquals(year: year) , isActivePredicate , vchNoPredicate , searchPredicate])
//            fetchRequest.predicate = andPredicate
//        }  else if currentInterval == Constants.QUARTERLY || currentInterval == Constants.HALF_YEARLY {
//            let (firstIndex , lastIndex) = Utils.splitMonthsRange(range: month)
//            
//            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.monthGreater(month: firstIndex - 1) , Predicates.monthLesser(month: lastIndex + 1) , Predicates.yearEquals(year: year) , isActivePredicate , vchNoPredicate , searchPredicate])
//            fetchRequest.predicate = andPredicate
//        } else if currentInterval == Constants.YEARLY {
//            fetchRequest.predicate = Predicates.yearEquals(year: year)
//            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [Predicates.yearEquals(year: year) , isActivePredicate , vchNoPredicate , searchPredicate])
//            fetchRequest.predicate = andPredicate
//        } else {
//            let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [isActivePredicate , vchNoPredicate , searchPredicate])
//            fetchRequest.predicate = andPredicate
//        }
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            print("No of vouchers : " , vouchers.count)
            
            for vch in vouchers as [Hkb_voucher] {
                print("VOUCHER IS : " , vch)
                arrayOfVouchers.append(vch)
                
            }
        } catch {
            print("Error : " , error)
        }
        return arrayOfVouchers
    }
    
    static func fetchAllTags () -> Array<String> {
        var arrayOfTags : Array<String> = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_VOUCHER)
        let isActivePredicate = NSPredicate(format : "active = %i" , 1)
        let emptyPredicate = NSPredicate(format: "tag != %@", "")
//        let searchPredicate = NSPredicate(format : "tag contains [c] %@" , tagSearch )

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "vch_date", ascending: false)]
        fetchRequest.fetchLimit = 5
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [isActivePredicate , emptyPredicate])
        
        do {
            let tags = try DbController.getContext().fetch(fetchRequest)
            print("No of tags : " , tags.count)
            
            for tag in tags as! [Hkb_voucher] {
                print("TAG IS : " , tag.tag!)
                arrayOfTags.append(tag.tag!)
            }
        } catch {
            print("Error : " , error)
        }
        
      return arrayOfTags
    }
    

    
    public static func fetchPlaces () -> Array<(place: String, type: String)> {
        var placesArray : Array<(place: String, type: String)> = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_VOUCHER)
        let isActivePredicate = NSPredicate(format : "active = %i" , 1)
        let placePredicate = NSPredicate(format : "flex1 != %@", "Select place" )
        let emptyPredicate = NSPredicate(format : "flex1 != %@", "" )
        let sort = NSSortDescriptor(key: "created_on", ascending: false)
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToGroupBy = ["flex1", "vchtrxplace"]
        fetchRequest.propertiesToFetch = ["flex1", "vchtrxplace"]
        fetchRequest.fetchLimit = 5
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [isActivePredicate, placePredicate, emptyPredicate])
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            for voucher in vouchers as! Array<[String:String]> {
                print("VCHHH : " , voucher.description)
                placesArray.append((place: voucher["flex1"]!, type: voucher["vchtrxplace"]!))
            }
        } catch {
            print("Error : " , error)
        }
        
        return placesArray
    }
}
