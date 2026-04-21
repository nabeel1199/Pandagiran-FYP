

import Foundation
import CoreData

class QueryUtils {
    
    //Update DB Record
    static func batchUpdates(entityName: String){
        // Create Entity Description
        
        let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: DbController.getContext())
             
            // Initialize Batch Update Request
            let batchUpdateRequest = NSBatchUpdateRequest(entity: entityDescription!)
             
            // Configure Batch Update Request
            batchUpdateRequest.resultType = .updatedObjectIDsResultType
            batchUpdateRequest.propertiesToUpdate = ["is_synced": Int32(0)]
             
            do {
                // Execute Batch Request
                _ = try DbController.getContext().execute(batchUpdateRequest) as! NSBatchUpdateResult
                 
                // Perform Fetch
                DbController.saveContext()
                 
            } catch {
                let updateError = error as NSError
                print("\(updateError), \(updateError.userInfo)")
            }
    }
    
    
    
    
    //Get all initial accounts
    static func fetchAccounts(accountType: [String], accountId: Int64? = 0) -> Array<Hkb_account> {
        var arrayOfAccounts : Array<Hkb_account> = []
        let fetchRequest : NSFetchRequest<Hkb_account> = Hkb_account.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Hkb_account.account_id), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let accountTypePredicate = NSPredicate(format: "acctype in %@", accountType)
        let emptyTypePredicate = NSPredicate(format: "acctype = %@", "")
        let nullTypePredicate = NSPredicate(format: "acctype = nil")
        let titlePredicate = NSPredicate(format: "title != nil")
        let activePredicate = Predicates.activePredicate()
        let orPredicate = NSCompoundPredicate(type : .or , subpredicates: [accountTypePredicate, nullTypePredicate, emptyTypePredicate])
        let accountExcludePredicate = NSPredicate(format: "account_id != %li", accountId!)
        
        
        if accountType.count == 0 {
            let andPredicate = NSCompoundPredicate(type : .and , subpredicates: [activePredicate, titlePredicate, accountExcludePredicate])
            fetchRequest.predicate = andPredicate
        } else {
            let andPredicate = NSCompoundPredicate(type : .and , subpredicates: [activePredicate, orPredicate, titlePredicate, accountExcludePredicate])
            fetchRequest.predicate = andPredicate
        }
        
        
        
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest)
            print("No of Accounts : " , accounts.count)
            
            for account in accounts as [Hkb_account] {
                arrayOfAccounts.append(account)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfAccounts
    }
    
    
    static func fetchAllAccounts() -> Array<Hkb_account> {
        var arrayOfAccounts : Array<Hkb_account> = []
        let fetchRequest : NSFetchRequest<Hkb_account> = Hkb_account.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Hkb_account.account_id), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let deletePredicate = NSPredicate(format: "active != %i", 2)
        let titlePredicate = NSPredicate(format: "title != nil")
        let andPredicate = NSCompoundPredicate(type : .and , subpredicates: [deletePredicate, titlePredicate])
        fetchRequest.predicate = andPredicate
        
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest)
            print("No of Accounts : " , accounts.count)
            
            for account in accounts as [Hkb_account] {
                arrayOfAccounts.append(account)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfAccounts
    }
    
    
    //Get all initial categories
    static func fetchCategories(type : String,
                                showActive : Bool = true,
                                showParent: Bool = false) -> Array <Hkb_category> {
        
        var arrayOfCategories : Array <Hkb_category> = []
        let fetchRequest : NSFetchRequest<Hkb_category> = Hkb_category.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Hkb_category.categoryId), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let expensePredicate = NSPredicate(format: "is_expense = %@", "1")
        let incomePredicate = NSPredicate(format: "is_expense = %@", "0")
        let parentPredicate = NSPredicate(format: "parent_category_id = %li", 0)
        let titlePredicate = NSPredicate(format: "title != nil")
        let activePredicate = Predicates.activePredicate()
        var predicateArray : Array<NSPredicate> = []
        predicateArray.append(titlePredicate)
        
        if type == Constants.EXPENSE {
            predicateArray.append(expensePredicate)
        }
        
        if type == Constants.INCOME {
            predicateArray.append(incomePredicate)
        }
        
        if showActive {
            predicateArray.append(activePredicate)
        }
        
        if showParent {
            predicateArray.append(parentPredicate)
        }
        
        fetchRequest.predicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: predicateArray)
        
        do {
            let categories = try DbController.getContext().fetch(fetchRequest)
            
            for category in categories as [Hkb_category]{
                arrayOfCategories.append(category)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfCategories
    }
    
    static func fetchSingleCategory (categoryId : Int64) -> Hkb_category? {
        var hkb_category : Hkb_category?
        let fetchRequest : NSFetchRequest<Hkb_category> = Hkb_category.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "categoryId = %li" , categoryId)
        
        do {
            let categories = try DbController.getContext().fetch(fetchRequest)
            
            if let category = categories.first{
                hkb_category = category
            }
        } catch {
            print("Error : " , error)
        }
        
        return hkb_category
    }
    
    /*********************************************  Start   ****************************************** */
    
    static func getCategorySync(categoryId : Int64) -> Int32 {
        var hkb_category : Hkb_category?
        let fetchRequest : NSFetchRequest<Hkb_category> = Hkb_category.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "categoryId = %li" , categoryId)
        
        do {
            let categories = try DbController.getContext().fetch(fetchRequest)
            
            if let category = categories.first{
                hkb_category = category
            }
        } catch {
            print("Error : " , error)
        }
        
        return hkb_category?.is_synced ?? 0
    }
    
    static func getAccountSync(accountId: Int64) -> Int32 {
        var hkb_account : Hkb_account?
        let fetchRequest : NSFetchRequest<Hkb_account> = Hkb_account.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "account_id = %li" , accountId)
        
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest)
            
            if let account = accounts.first{
                hkb_account = account
            }
        } catch {
            print("Error : " , error)
        }
        
        return hkb_account?.is_synced ?? 0
    }
    
    static func getVoucherSync(voucherId: Int64) -> Int32 {
        var hkb_voucher : Hkb_voucher?
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "voucher_id = %li" , voucherId)
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            
            if let voucher = vouchers.first{
                hkb_voucher = voucher
            }
        } catch {
            print("Error : " , error)
        }
        
        return hkb_voucher?.is_synced ?? 0
    }
    
    static func getGoalSync(goalId: Int64) -> Int32 {
        var hkb_goal : Hkb_goal?
        let fetchRequest : NSFetchRequest<Hkb_goal> = Hkb_goal.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "goalId = %li" , goalId)
        
        do {
            let goals = try DbController.getContext().fetch(fetchRequest)
            
            if let goal = goals.first{
                hkb_goal = goal
            }
        } catch {
            print("Error : " , error)
        }
        
        return hkb_goal?.is_synced ?? 0
    }
    
    static func getBudgetSync(budget_id: Int64) -> Int32 {
        var hkb_budget : Hkb_budget?
        let fetchRequest : NSFetchRequest<Hkb_budget> = Hkb_budget.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "budget_id = %li" , budget_id)
        
        do {
            let hkb_budgets = try DbController.getContext().fetch(fetchRequest)
            
            if let budget = hkb_budgets.first{
                hkb_budget = budget
            }
        } catch {
            print("Error : " , error)
        }
        
        return hkb_budget?.is_synced ?? 0
    }
    
    static func getEventSync(eventId: Int64) -> Int32 {
        var hkb_event : Hkb_event?
        let fetchRequest : NSFetchRequest<Hkb_event> = Hkb_event.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "eventid = %li" , eventId)
        
        do {
            let hkb_events = try DbController.getContext().fetch(fetchRequest)
            
            if let event = hkb_events.first{
                hkb_event = event
            }
        } catch {
            print("Error : " , error)
        }
        
        return hkb_event?.is_synced ?? 0
    }
/********************************************* End   ****************************************** */
    
    static func fetchSingleReminder (reminderId : Int64) -> Hkb_reminder {
        var arrayOfReminders : Array <Hkb_reminder> = []
        let fetchRequest : NSFetchRequest<Hkb_reminder> = Hkb_reminder.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "reminderId = %li" , reminderId)
        
        do {
            let reminders = try DbController.getContext().fetch(fetchRequest)
            
            for reminder in reminders as [Hkb_reminder]{
                arrayOfReminders.append(reminder)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfReminders[0]
    }
    
    
    
    static func fetchSingleAccount (accountId : Int64) -> Hkb_account? {
        var accountToFetch: Hkb_account?
        let fetchRequest : NSFetchRequest<Hkb_account> = Hkb_account.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "account_id = %li" , accountId)
        
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest)
            
            
            if let account = accounts.first {
                accountToFetch = account
            }
            
        } catch {
            print("Error : " , error)
        }
       
        
        return accountToFetch
    }
    
    static func fetchSingleVoucher (voucherId : Int64) -> Hkb_voucher? {
        var hkb_voucher: Hkb_voucher?
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "voucher_id = %li" , voucherId)
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            
            
            if let voucher = vouchers.first {
                hkb_voucher = voucher
            }
        } catch {
            print("Error : " , error)
        }
        
        return hkb_voucher
    }
    
    static func fetchSingleSavingGoal (goalId : Int64) -> Hkb_goal {
        var hkb_goal : Hkb_goal?
        let fetchRequest : NSFetchRequest<Hkb_goal> = Hkb_goal.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "goalId = %li" , goalId)
        
        do {
            let goals = try DbController.getContext().fetch(fetchRequest)
            
            if let goal = goals.first as? Hkb_goal {
                hkb_goal = goal
            }
        } catch {
            print("Error : " , error)
        }
        
        return hkb_goal!
    }
    
    static func fetchSingleNotification (notificationId : Int) -> Hkb_notifications {
        var arrayOfNotifications : Array<Hkb_notifications> = []
        let fetchRequest : NSFetchRequest<Hkb_notifications> = Hkb_notifications.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "notification_id = %i" , notificationId)
        
        do {
            let notifications = try DbController.getContext().fetch(fetchRequest)
            
            for notification in notifications as [Hkb_notifications] {
                arrayOfNotifications.append(notification)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfNotifications[arrayOfNotifications.count - 1]
    }
    
    static func fetchSingleEvent (eventId : Int64) -> Hkb_event? {
        var hkb_event: Hkb_event?
        let fetchRequest : NSFetchRequest<Hkb_event> = Hkb_event.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "eventid = %li" , eventId)
        
        do {
            let events = try DbController.getContext().fetch(fetchRequest)
            
            if let event = events.first{
                hkb_event = event
            }
        } catch {
            print("Error : " , error)
        }
        
        return hkb_event
    }
    
    static func saveCategories() {
        let categoriesJsonArray = Utils.readJson(resourceName: "hkb_category")
        var category : Dictionary<String , Any>
        
        for record in categoriesJsonArray {
            category = record as! Dictionary<String, Any>
            let dbCategory : Hkb_category = NSEntityDescription.insertNewObject(forEntityName: "Hkb_category", into: DbController.getContext()) as! Hkb_category
            let balance_amount : String = category["balance_amount"]! as! String
            dbCategory.balance_amount = (balance_amount as NSString).doubleValue
            dbCategory.title = category["title"] as? String
            dbCategory.active = 1
            dbCategory.box_color = category["box_color"] as? String
            dbCategory.box_icon = category["box_icon"] as? String
            dbCategory.budget_amount = (category["budget_amount"] as! NSString).doubleValue
            dbCategory.is_expense = category["is_expense"] as! Int16
            dbCategory.categoryId = category["category_id"] as! Int64
            dbCategory.tags = category["tags"] as? String
            dbCategory.is_synced = 1
        }
        
        DbController.saveContext()
    }
    
    static func saveAccounts() -> Void {
        let accountsJsonArray = Utils.readJson(resourceName: "hkb_account")
        var accounts : Dictionary<String , Any>
        
        for account in accountsJsonArray {
            print(account)
            accounts = account as! Dictionary<String , Any>
            
            let dbAccount : Hkb_account = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_ACCOUNT, into: DbController.getContext()) as! Hkb_account
            dbAccount.balance_amount = (accounts["balance_amount"] as! NSString).doubleValue
            dbAccount.boxcolor = accounts["box_color"] as? String
            dbAccount.boxicon = accounts["box_icon"] as? String
            dbAccount.title = (accounts["title"] as? String)
            dbAccount.active = 1
            dbAccount.acctype = accounts["acc_type"] as? String
            dbAccount.pin = "1"
            dbAccount.is_synced = 1
            dbAccount.user_id = (accounts["user_id"] as? Int64)!
            dbAccount.account_id = (accounts["account_id"] as? Int64)!
        }
        
        DbController.saveContext()
    }
    
    static func getMaxAccountId () -> Int64 {
        var arrayOfAccounts : Array<Hkb_account> = []
        let fetchRequest : NSFetchRequest<Hkb_account> = Hkb_account.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "account_id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest)
            print("No of Accounts : " , accounts.count)
            
            for account in accounts as [Hkb_account] {
                arrayOfAccounts.append(account)
            }
        } catch {
            print("Error : " , error)
        }
        
        if arrayOfAccounts.count > 0 {
            return arrayOfAccounts[0].account_id
        } else {
            return 0
        }
    }
    
    static func getMaxBudgetId () -> Int64 {
        var arrayOfBudgets : Array<Hkb_budget> = []
        let fetchRequest : NSFetchRequest<Hkb_budget> = Hkb_budget.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "budget_id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let budgets = try DbController.getContext().fetch(fetchRequest)
            
            for budget in budgets as [Hkb_budget] {
                arrayOfBudgets.append(budget)
            }
        } catch {
            print("Error : " , error)
        }
        
        if arrayOfBudgets.count > 0 {
            return arrayOfBudgets[0].budget_id
        } else {
            return 0
        }
    }
    
    static func getMaxVoucherId () -> Int64 {
        var arrayOfVouchers : Array<Hkb_voucher> = []
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "voucher_id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            print("No of Vouchers : " , vouchers.count)
            
            for voucher in vouchers as [Hkb_voucher] {
                arrayOfVouchers.append(voucher)
            }
        } catch {
            print("Error : " , error)
        }
        
        if arrayOfVouchers.count > 0 {
            return arrayOfVouchers[0].voucher_id
        } else {
            return 0
        }
    }
    

    
    static func getMaxSavingVchId () -> Int64 {
        var arrayOfVouchers : Array<Hkb_goal_trx> = []
        let fetchRequest : NSFetchRequest<Hkb_goal_trx> = Hkb_goal_trx.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "voucherId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            
            for voucher in vouchers as [Hkb_goal_trx] {
                arrayOfVouchers.append(voucher)
            }
        } catch {
            print("Error : " , error)
        }
        
        if arrayOfVouchers.count > 0 {
            return arrayOfVouchers[0].voucherId
        } else {
            return 0
        }
    }
    
    static func getMaxCategoryId () -> Int64 {
        var arrayOfCategories : Array<Hkb_category> = []
        let fetchRequest : NSFetchRequest<Hkb_category> = Hkb_category.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "categoryId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let categories = try DbController.getContext().fetch(fetchRequest)
            
            for category in categories as [Hkb_category] {
                arrayOfCategories.append(category)
            }
        } catch {
            print("Error : " , error)
        }
        
        if arrayOfCategories.count > 0 {
            return arrayOfCategories[0].categoryId
        } else {
            return 0
        }
    }
    
    static func getMaxGoalId () -> Int64 {
        var arrayOfGoals : Array<Hkb_goal> = []
        let fetchRequest : NSFetchRequest<Hkb_goal> = Hkb_goal.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "goalId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let goals = try DbController.getContext().fetch(fetchRequest)
            
            for goal in goals as [Hkb_goal] {
                arrayOfGoals.append(goal)
            }
        } catch {
            print("Error : " , error)
        }
        
        if arrayOfGoals.count > 0 {
            return arrayOfGoals[0].goalId
        } else {
            return 0
        }
    }
    
    static func getMaxReminderId () -> Int {
        var arrayOfReminders : Array<Hkb_reminder> = []
        let fetchRequest : NSFetchRequest<Hkb_reminder> = Hkb_reminder.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "reminderId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let reminders = try DbController.getContext().fetch(fetchRequest)
            print("No of reminders : " , reminders.count)
            
            for reminder in reminders as [Hkb_reminder] {
                arrayOfReminders.append(reminder)
            }
        } catch {
            print("Error : " , error)
        }
        
        if arrayOfReminders.count > 0 {
            return Int(arrayOfReminders[0].reminderId)
        } else {
            return 0
        }
    }
    
    static func getMaxNotificationId () -> Int {
        var arrayOfNotifications : Array<Hkb_notifications> = []
        let fetchRequest : NSFetchRequest<Hkb_notifications> = Hkb_notifications.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "notification_id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let notifications = try DbController.getContext().fetch(fetchRequest)
            
            for notification in notifications as [Hkb_notifications] {
                arrayOfNotifications.append(notification)
            }
        } catch {
            print("Error : " , error)
        }
        
        if arrayOfNotifications.count > 0 {
            return Int(arrayOfNotifications[0].notification_id)
        } else {
            return 0
        }
    }
    
    static func getMaxEventId () -> Int64 {
        var arrayOfEvents : Array<Hkb_event> = []
        let fetchRequest : NSFetchRequest<Hkb_event> = Hkb_event.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "eventid", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let events = try DbController.getContext().fetch(fetchRequest)
            
            for event in events as [Hkb_event] {
                arrayOfEvents.append(event)
            }
        } catch {
            print("Error : " , error)
        }
        
        if arrayOfEvents.count > 0 {
            return arrayOfEvents[0].eventid
        } else {
            return 0
        }
    }
    
    static func fetchPinnedAccounts() -> Array<Hkb_account> {
        var arrayOfAccounts : Array<Hkb_account> = []
        let fetchRequest : NSFetchRequest<Hkb_account> = Hkb_account.fetchRequest()
        let pinnedPredicate = NSPredicate(format : "pin = %@" , "1")
        let activePredicate = Predicates.activePredicate()
        let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [pinnedPredicate, activePredicate ])
        fetchRequest.predicate = andPredicate
        
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest)
            print("No of Accounts : " , accounts.count)
            
            for account in accounts as [Hkb_account] {
                arrayOfAccounts.append(account)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfAccounts
    }
    
    static func fetchOpeningBalanceAllAccounts () -> Double {
        var sum : Double = 0.0
        let amountExpr = NSExpression(forKeyPath: "openingbalance")
        let sumExpr = NSExpression(forFunction: "sum:", arguments: [amountExpr])
        let sumDescr = NSExpressionDescription()
        sumDescr.expression = sumExpr
        sumDescr.name = "sum"
        sumDescr.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.HKB_ACCOUNT)
        var andPredicate : NSCompoundPredicate?
        fetchRequest.propertiesToFetch = [sumDescr]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        let deletePredicate = NSPredicate(format : "active != %i" , 2)
        
        fetchRequest.predicate = deletePredicate
        
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest) as! [NSDictionary]
            
            for account in accounts {
                sum += account["sum"] as? Double ?? 0
                print("Sum is : " , sum)
            }
        } catch {
            print ("Error : " , error)
        }
        
        return sum
    }
    
    static func fetchAllVouchers () -> Array<Hkb_voucher> {
        var vchArray : Array<Hkb_voucher> = []
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        let activePredicate = Predicates.activePredicate()
        let vchNoPredicate = NSPredicate(format : "vch_no = %@" , "1")
        let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [vchNoPredicate, activePredicate ])
        fetchRequest.predicate = andPredicate
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            
            for voucher in vouchers as [Hkb_voucher] {
                vchArray.append(voucher)
            }
        } catch {
            print("Error : " , error)
        }
        
        return vchArray
    }
    
    static func fetchAllEvents () -> Array<Hkb_event> {
        var eventsArray : Array<Hkb_event> = []
        let fetchRequest : NSFetchRequest<Hkb_event> = Hkb_event.fetchRequest()
        let activePredicate = Predicates.activePredicate()
        fetchRequest.predicate = activePredicate
        
        do {
            let events = try DbController.getContext().fetch(fetchRequest)
            
            for event in events as [Hkb_event] {
                eventsArray.append(event)
            }
        } catch {
            print("Error : " , error)
        }
        
        return eventsArray
    }
    
    static func deleteAllAccounts () {
        let fetchRequest : NSFetchRequest<Hkb_account> = Hkb_account.fetchRequest()
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest)
            print("No of Accounts : " , accounts.count)
            
            for account in accounts as [Hkb_account] {
                DbController.getContext().delete(account)
            }
        } catch {
            print("Error : " , error)
        }
        DbController.saveContext()
    }
    
    static func deleteAllCategories () {
        let fetchRequest : NSFetchRequest<Hkb_category> = Hkb_category.fetchRequest()
        
        
        do {
            let categories = try DbController.getContext().fetch(fetchRequest)
            print("No of categories : " , categories.count)
            
            for category in categories as [Hkb_category]{
                DbController.getContext().delete(category)
            }
        } catch {
            print("Error : " , error)
        }
        
        DbController.saveContext()
    }
    
    static func deleteAllSavings () {
        let fetchRequest : NSFetchRequest<Hkb_goal> = Hkb_goal.fetchRequest()
        
        do {
            let goals = try DbController.getContext().fetch(fetchRequest)
            
            for goal in goals as [Hkb_goal] {
                DbController.getContext().delete(goal)
            }
        } catch {
            print("Error : " , error)
        }
        
        DbController.saveContext()
    }
    
    static func deleteAllNotifications () {
        let fetchRequest : NSFetchRequest<Hkb_notifications> = Hkb_notifications.fetchRequest()
        
        do {
            let notifications = try DbController.getContext().fetch(fetchRequest)
            
            for notification in notifications as [Hkb_notifications] {
                DbController.getContext().delete(notification)
            }
        } catch {
            print("Error : " , error)
        }
        
        DbController.saveContext()
    }
    
    static func deleteSavingTransactions () {
        let fetchRequest : NSFetchRequest<Hkb_goal_trx> = Hkb_goal_trx.fetchRequest()
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            
            for voucher in vouchers as [Hkb_goal_trx] {
                DbController.getContext().delete(voucher)
            }
        } catch {
            print("Error : " , error)
        }
        
        DbController.saveContext()
    }
    
    static func deleteAllTransaction () {
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            print("No of vouchers : " , vouchers.count)
            
            for vch in vouchers as [Hkb_voucher] {
                DbController.getContext().delete(vch)
                
            }
        } catch {
            print("Error : " , error)
        }
        
        DbController.saveContext()
    }
    
    static func deleteAllEvents () {
        let fetchRequest : NSFetchRequest<Hkb_event> = Hkb_event.fetchRequest()
        
        do {
            let events = try DbController.getContext().fetch(fetchRequest)
            print("Number of events : " , events.count)
            
            for event in events as [Hkb_event] {
                DbController.getContext().delete(event)
                
            }
        } catch {
            print("Error : " , error)
        }
        
        DbController.saveContext()
    }
    
    static func deleteAllBudgets () {
        let fetchRequest : NSFetchRequest<Hkb_budget> = Hkb_budget.fetchRequest()
        
        do {
            let budgets = try DbController.getContext().fetch(fetchRequest)
            
            for budget in budgets as [Hkb_budget] {
                DbController.getContext().delete(budget)
                
            }
        } catch {
            print("Error : " , error)
        }
        
        DbController.saveContext()
    }
    
    static func fetchAllNotifications () -> Array<Hkb_notifications> {
        var arrayofNotifications : Array <Hkb_notifications> = []
        let fetchRequest : NSFetchRequest<Hkb_notifications> = Hkb_notifications.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Hkb_notifications.notification_id), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            let notifications = try DbController.getContext().fetch(fetchRequest)
            
            for notification in notifications as [Hkb_notifications]{
                arrayofNotifications.append(notification)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayofNotifications
    }
    
    static func fetchCategoryByName (nameString: String, categoryId: Int64) -> Hkb_category? {
        var hkb_category : Hkb_category?
        let fetchRequest : NSFetchRequest<Hkb_category> = Hkb_category.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "title = [c] %@" , nameString)
        
        do {
            let categories = try DbController.getContext().fetch(fetchRequest)
            
            
            if let category = categories.first as? Hkb_category {
                hkb_category = category
            }
        } catch {
            print("Error : " , error)
        }
        
        if categoryId == hkb_category?.categoryId {
            return nil
        } else {
            return hkb_category
        }
    }
    
    static func fetchCategoryToDelete (nameString: String, categoryId: Int64) -> Hkb_category? {
        var hkb_category : Hkb_category?
        let fetchRequest : NSFetchRequest<Hkb_category> = Hkb_category.fetchRequest()
        fetchRequest.fetchLimit = 1
        let titlePredicate = NSPredicate(format : "title = %@" , nameString)
        let idPredicate = NSPredicate(format: "categoryId = %i", categoryId)
        let activePredicate = NSPredicate(format: "active = %i" , 1)
        let andPredicate = NSCompoundPredicate(type : NSCompoundPredicate.LogicalType.and , subpredicates: [idPredicate, titlePredicate, activePredicate ])
        fetchRequest.predicate = andPredicate
        
        do {
            let categories = try DbController.getContext().fetch(fetchRequest)
            
            
            if let category = categories.first as? Hkb_category {
                hkb_category = category
            }
        } catch {
            print("Error : " , error)
        }
        
        
        return hkb_category
    }
    
    static func fetchAccountByName (nameString: String, accountId: Int64) -> Hkb_account? {
        var hkb_account : Hkb_account?
        let fetchRequest : NSFetchRequest<Hkb_account> = Hkb_account.fetchRequest()
        fetchRequest.fetchLimit = 1
        let titlePredicate = NSPredicate(format : "title = [c] %@" , nameString)
        let activePredicate = NSPredicate(format: "active IN %@", [0,1])
        let andPredicate = NSCompoundPredicate.init(type: .and, subpredicates: [titlePredicate, activePredicate])
        fetchRequest.predicate = andPredicate
        
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest)
            
            
            if let account = accounts.first as? Hkb_account {
                if account.account_id != accountId {
                    hkb_account = account
                }
                
                
            }
        } catch {
            print("Error : " , error)
        }
        
        
        return hkb_account
    }
    
    static func fetchAllActivities() -> Array<Hkb_activity> {
        var arrayOfActivities : Array<Hkb_activity> = []
        let fetchRequest : NSFetchRequest<Hkb_activity> = Hkb_activity.fetchRequest()
        
        do {
            let activities = try DbController.getContext().fetch(fetchRequest)
            
            for activity in activities as [Hkb_activity] {
                arrayOfActivities.append(activity)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfActivities
    }
    
    static func deleteAllActivities () {
        let context = DbController.getContext()
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Hkb_activity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    
    static func fetchUnsyncedAllAccounts() -> Array<Hkb_account> {
        var arrayOfAccounts : Array<Hkb_account> = []
        let fetchRequest : NSFetchRequest<Hkb_account> = Hkb_account.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Hkb_account.account_id), ascending: true)
        fetchRequest.sortDescriptors = [sort]
//        let deletePredicate = NSPredicate(format: "active != %i", 2)
        let titlePredicate = NSPredicate(format: "title != nil")
        let isSyncedPredicate = Predicates.isSynced()
//        let andPredicate = NSCompoundPredicate(type : .and , subpredicates: [deletePredicate, titlePredicate, isSyncedPredicate])
        let andPredicate = NSCompoundPredicate(type : .and , subpredicates: [titlePredicate, isSyncedPredicate])
        fetchRequest.predicate = andPredicate
        
        do {
            let accounts = try DbController.getContext().fetch(fetchRequest)
            arrayOfAccounts = accounts
//            for item in accounts{
//                if item.is_synced == 0{
//                    arrayOfAccounts.append(item)
//                }
//            }
//
//            print("HKDR \(accounts)")
//            print("HKDR \(arrayOfAccounts.count)")
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfAccounts
    }
    
    static func fetchUnsyncedAllVouchers() -> Array<Hkb_voucher> {
        var vchArray : Array<Hkb_voucher> = []
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
//        let vchSyncPredicate = NSPredicate(format: "type in (%i)", [1,2])
//        fetchRequest.predicate = vchSyncPredicate
        let activePredicate = Predicates.isSynced()
        fetchRequest.predicate = activePredicate
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            vchArray = vouchers
//            for item in vouchers{
//                if item.is_synced == 0{
//                    vchArray.append(item)
//                }
//            }
//            print("HKDR \(vouchers)")
//            print("HKDR \(vchArray.count)")
        } catch {
            print("Error : " , error)
        }
        
        return vchArray
    }
    
    static func fetchUnsyncedAllEvents() -> Array<Hkb_event> {
        var eventsArray : Array<Hkb_event> = []
        let fetchRequest : NSFetchRequest<Hkb_event> = Hkb_event.fetchRequest()
        let activePredicate = Predicates.isSynced()
        fetchRequest.predicate = activePredicate
        
        do {
            let events = try DbController.getContext().fetch(fetchRequest)
            
            eventsArray = events
//            for item in events{
//                if item.is_synced == 0{
//                    eventsArray.append(item)
//                }
//            }
//
//            print("HKDR \(events)")
//            print("HKDR \(eventsArray.count)")
        } catch {
            print("Error : " , error)
        }
        
        return eventsArray
    }
    
    static func fetchUnsyncedAllCategories() -> Array<Hkb_category> {
        var categoryArray : Array<Hkb_category> = []
        let fetchRequest : NSFetchRequest<Hkb_category> = Hkb_category.fetchRequest()
        let activePredicate = Predicates.isSynced()
        fetchRequest.predicate = activePredicate
        
        do {
            let category = try DbController.getContext().fetch(fetchRequest)
            
            categoryArray = category
//            for item in category{
//                if item.is_synced == 0{
//                    categoryArray.append(item)
//                }
//            }
            
//            print("HKDR \(category)")
//            print("HKDR \(categoryArray.count)")
        } catch {
            print("Error : " , error)
        }
        
        return categoryArray
    }
    
    static func fetchUnsyncedAllSavingGoal() -> Array<Hkb_goal> {
        var goalArray : Array<Hkb_goal> = []
        let fetchRequest : NSFetchRequest<Hkb_goal> = Hkb_goal.fetchRequest()
        let activePredicate = Predicates.isSynced()
        fetchRequest.predicate = activePredicate
        
        do {
            let goals = try DbController.getContext().fetch(fetchRequest)
            
            for item in goals{
                if item.is_synced == 0{
                    goalArray.append(item)
                }
            }
            
            print("HKDR \(goals)")
            print("HKDR \(goalArray.count)")
        } catch {
            print("Error : " , error)
        }
        
        return goalArray
    }
    
    static func fetchUnsyncedAllSavingTrx() -> Array<Hkb_goal_trx> {
    var goalTrxArray : Array<Hkb_goal_trx> = []
    let fetchRequest : NSFetchRequest<Hkb_goal_trx> = Hkb_goal_trx.fetchRequest()
    let activePredicate = Predicates.isSynced()
    fetchRequest.predicate = activePredicate
    
    do {
        let goalTrx = try DbController.getContext().fetch(fetchRequest)
        goalTrxArray = goalTrx
//            for item in goalTrx{
//                if item.is_synced == 0{
//                    goalTrxArray.append(item)
//                }
//            }
//
//            print("HKDR \(goalTrx)")
//            print("HKDR \(goalTrxArray.count)")
    } catch {
        print("Error : " , error)
    }
    
    return goalTrxArray
}
    
    static func fetchUnsyncedAllBudget() -> Array<Hkb_budget> {
        var budgetArray : Array<Hkb_budget> = []
        let fetchRequest : NSFetchRequest<Hkb_budget> = Hkb_budget.fetchRequest()
        let activePredicate = Predicates.isSynced()
        fetchRequest.predicate = activePredicate
        
        do {
            let budgetTrx = try DbController.getContext().fetch(fetchRequest)
            budgetArray = budgetTrx
    //            for item in goalTrx{
    //                if item.is_synced == 0{
    //                    goalTrxArray.append(item)
    //                }
    //            }
    //
    //            print("HKDR \(goalTrx)")
    //            print("HKDR \(goalTrxArray.count)")
        } catch {
            print("Error : " , error)
        }
        
        return budgetArray
    }
    
    static func fetchExistingAccount(account_id: Int64, title: String) -> Bool {
        let fetchRequest : NSFetchRequest<Hkb_account> = Hkb_account.fetchRequest()
//        let activePredicate = Predicates.accoundIdEquals(accountId: account_id)
        let idPredicate = Predicates.accoundIdEquals(accountId: account_id)
//        fetchRequest.predicate = activePredicate
        let titlePredicate = Predicates.titleEquals(title: title)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPredicate, titlePredicate])
        
        do {
            let list = try DbController.getContext().fetch(fetchRequest)
            if list.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("Error : " , error)
            return false
        }
    }
    
    static func fetchExistingCategory(category_id: Int64, category_title: String) -> Bool {
        let fetchRequest : NSFetchRequest<Hkb_category> = Hkb_category.fetchRequest()
        let idPredicate = Predicates.categoryIDEqual(cateegoryId: category_id)
        let titlePredicate = Predicates.titleEquals(title: category_title)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPredicate, titlePredicate])
        
        do {
            let list = try DbController.getContext().fetch(fetchRequest)
            if list.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("Error : " , error)
            return false
        }
    }
    
    static func fetchExistingVoucher(account_id: Int64, voucher_id: Int64) -> Bool {
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        let idPredicate = Predicates.accoundIdEquals(accountId: account_id)
        let vIdPredicate = Predicates.voucherIdEquals(voucher_Id: voucher_id)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPredicate, vIdPredicate])
        
        do {
            let list = try DbController.getContext().fetch(fetchRequest)
            if list.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("Error : " , error)
            return false
        }
    }
    
    static func fetchExistingBudget(budget_id: Int64, category_id: Int64) -> Bool {
        let fetchRequest : NSFetchRequest<Hkb_budget> = Hkb_budget.fetchRequest()
        let idPredicate = Predicates.categoryIDEquals(cateegoryId: category_id)
        let cIdPredicate = Predicates.budgetIdEquals(budget_Id: budget_id)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPredicate, cIdPredicate])
        
        do {
            let list = try DbController.getContext().fetch(fetchRequest)
            if list.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("Error : " , error)
            return false
        }
    }
    
    static func fetchExistingEvents(event_id: Int64, event_name: String) -> Bool {
        let fetchRequest : NSFetchRequest<Hkb_event> = Hkb_event.fetchRequest()
        let idPredicate = Predicates.eventIdEquals(eventId: event_id)
        let namePredicate = Predicates.nameEquals(title: event_name)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPredicate, namePredicate])
        
        do {
            let list = try DbController.getContext().fetch(fetchRequest)
            if list.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("Error : " , error)
            return false
        }
    }
    
   
}



