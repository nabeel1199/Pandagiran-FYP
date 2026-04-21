

import UIKit
import CoreData
import Firebase
import FirebaseInstanceID
import GoogleSignIn
import GooglePlaces
import GooglePlacePicker
import GoogleMaps
import UserNotifications
import FirebaseMessaging
import FBSDKCoreKit
import SwiftyJSON
import Mixpanel
import Network

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , UNUserNotificationCenterDelegate , CLLocationManagerDelegate, MessagingDelegate  {
    
    var window: UIWindow?
    var centerContainer: MMDrawerController?
    var loader = UIActivityIndicatorView()
    let locationManager = CLLocationManager()
    
    
    
    //
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        LocalPrefs.setConsumerId(userId: 0)
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("Core data Path : " , NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        print("Test URL - \(urls)")
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // just for example purposes
//            QueryUtils.migrateStoreIfNeeded()
//            DbController.shared.loadPersistentStore {
//                print("Working")
//            DbController.shared.setup {
//                print("DBController Called")
//            }
//            }
            
            print("urls - \(urls)")
            print("Working")
        }
        //
        //        DbController.shared.setup {
        //            print("Setup Called")
        //        }
        
//        self.checkInternet()
        registerDefaultLocalValues()
        
        initFirebaseNotifications(application: application)
        InitializeMixPanel()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        
        // 1
        GIDSignIn.sharedInstance().clientID = "828691823842-dphi4i24hhfrfmrtmvi3m433e7d5281e.apps.googleusercontent.com"
        // 2
//        GIDSignIn.sharedInstance()?.delegate = self
        // 3
//        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        GMSServices.provideAPIKey("AIzaSyB3-nEFn0sMZmybTqIypqeTLiC2nF9yE3s")
        GMSPlacesClient.provideAPIKey("AIzaSyB3-nEFn0sMZmybTqIypqeTLiC2nF9yE3s")
        
        //        locationManager.delegate = self
        //        locationManager.requestAlwaysAuthorization()
        
        
//        window?.makeKeyAndVisible()
        
        //        addShortCuts(application: application)
        
        if let notification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            
            DispatchQueue.main.async { //asyncAfter(deadline: .now() + 3, execute: {
                self.handleRemoteNotification(notification: notification)
            }
//            handleRemoteNotification(notification: notification)
        }
        
        
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                LocalPrefs.setDeviceToken(deviceToken: "\(result.token)")
            }
        }
        
        
        return true
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if GIDSignIn.sharedInstance().handle(url)/*GIDSignIn.sharedInstance().handle(url,
                                             sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                             annotation: options[UIApplicationOpenURLOptionsKey.annotation]) */ {
            return true
        }
        
        
        return self.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: "")
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        AppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("tokenStringData : " , deviceToken)
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print(deviceTokenString)
        let token = tokenParts.joined()
        print(token)
        
        //        notifyOnTokenReceived()
        
    }
    
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
//        LocalPrefs.setDeviceToken(deviceToken: "ABCABC")
        //        notifyOnTokenReceived()
        
    }
    
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        
        if GIDSignIn.sharedInstance().handle(url) {
            return true
        }
        
        
        
//        return Invites.handleUniversalLink(url) { invite, error in
//            // ...
//            print("ERRORRRR HERE" , error)
//        }
        return false
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler( [.alert, .badge, .sound])
        
        if notification.request.identifier != "Saving" && notification.request.content.userInfo.count == 0 {
            postReminderNotification(reminderId: Int64(notification.request.identifier)!)
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.content.userInfo.count > 0
        {
            if let notification = response.notification.request.content.userInfo as? [String : AnyObject] {
                let userInfo = JSON(notification)
                print(userInfo)
                handleRemoteNotification(notification: notification)
            }
            
        }
        //        else if response.notification.request.identifier != "Saving" && response.notification.request.content.userInfo.count == 0
        //        {
        //            postReminderNotification(reminderId: Int(response.notification.request.identifier)!)
        //            let storyboard = UIUtils.getStoryboard(name: "Main")
        //            let dest = storyboard.instantiateViewController(withIdentifier: "MainVC")
        //            self.window?.rootViewController = dest
        //            self.window?.makeKeyAndVisible()
        //        }
        
        completionHandler()
        
    }
    
    
    private func handleRemoteNotification (notification: [String: AnyObject]) {
        let userInfo = JSON(notification)
        let data = userInfo["data"].dictionaryValue
        let actionType = userInfo["action_type"].stringValue
        print(userInfo)
        
        if !LocalPrefs.getIsVerified() && !LocalPrefs.getIsRegistered() {
            return
        }
        
        let tabbarController = UIUtils.getStoryboard(name: ViewIdentifiers.SB_MAIN).instantiateViewController(withIdentifier: ViewIdentifiers.VC_MAIN) as! TabBarViewController
        self.window?.rootViewController = tabbarController
        
        switch actionType {
        
        case "c0":
            if let tabbarController = window?.rootViewController as? TabBarViewController {
//                tabbarController.selectedIndex = 3
                tabbarController.selectedIndex = 0
            }
            
        case "c1":
            if let tabbarController = window?.rootViewController as? TabBarViewController {
//                tabbarController.selectedIndex = 4
                tabbarController.selectedIndex = 1
            }
            
        case "c2":
            let sb = UIUtils.getStoryboard(name: ViewIdentifiers.SB_TRANSACTION)
                let transactionVC = sb.instantiateViewController(withIdentifier: ViewIdentifiers.VC_TRANSACTION_LOGGING)
                let navController = UINavigationController()
                navController.viewControllers = [transactionVC]
                navController.modalPresentationStyle = .fullScreen
            window?.rootViewController?.present(navController, animated: true, completion: nil)
                        
        case "c3":
            if let tabbarController = window?.rootViewController as? TabBarViewController {
                tabbarController.selectedIndex = 3
            }

            
        case "c7":

            tabbarController.selectedIndex = 4
            let sb = UIUtils.getStoryboard(name: ViewIdentifiers.SB_SAVING)
                           let savingVC = sb.instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_SAVING)
                       UIApplication.getTopViewController()?.navigationController?.pushViewController(savingVC, animated: true)
      
        case "c6":

            tabbarController.selectedIndex = 1
                
                    let sb = UIUtils.getStoryboard(name: ViewIdentifiers.SB_BUDGET)
                        let budgetVC = sb.instantiateViewController(withIdentifier: ViewIdentifiers.VC_BUDGET_PAGE)
                    UIApplication.getTopViewController()?.navigationController?.pushViewController(budgetVC, animated: true)
            
        case "c5":
            if let tabbarController = window?.rootViewController as? TabBarViewController {
                    tabbarController.selectedIndex = 0
                  }
            let sb = UIUtils.getStoryboard(name: ViewIdentifiers.SB_CATEGORY)
                let catVC = sb.instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_CATEGORY)
            UIApplication.getTopViewController()?.navigationController?.pushViewController(catVC, animated: true)
            
        case "c4":
            if let tabbarController = window?.rootViewController as? TabBarViewController {
                    tabbarController.selectedIndex = 4
                  }
            
            break
            
        default:
            print("Nothing")
        }
    }
    
//    Home Screen - c3
//    add Expense - c4
//    create budget - c5
//    Add Transaction - c4
//    Charts and report page - c1
//    create Saving goal
//    create category page
//    budget page
//    add saving c6
//    saving goal page - c2
    
    
    private func notifyOnTokenReceived () {
        NotificationCenter.default.post(name: NSNotification.Name("OnTokenReceived"), object: nil , userInfo: nil)
    }
    
    //    private func congigFlurryLogs() {
    //        Flurry.startSession("8TW6R8DM2VYYXK85R4P4", with: FlurrySessionBuilder
    //            .init()
    //            .withCrashReporting(true)
    //            .withLogLevel(FlurryLogLevelAll))
    //    }
    
    @objc private func postReminderNotification (reminderId : Int64) {
        let reminder : Hkb_reminder = QueryUtils.fetchSingleReminder(reminderId: reminderId)
        LocalPrefs.setReminderId(reminderId: Int(reminder.reminderId))
        
        if reminder.flex1 == "1" {
            postRecurringVoucher(reminder: reminder)
        }
        
        updateReminder(reminder: reminder)
    }
    
    private func updateReminder (reminder : Hkb_reminder) {
        let myCalendar = Calendar(identifier: .gregorian)
        var alarmDate = Date()
        let repeatInterval = reminder.recurring
        
        if repeatInterval == "Monthly" {
            alarmDate = myCalendar.date(byAdding: .month, value: 1, to: alarmDate)!
        } else if repeatInterval == "Weekly" {
            alarmDate = myCalendar.date(byAdding: .day, value: 7, to: alarmDate)!
        } else if repeatInterval == "Daily" {
            alarmDate = myCalendar.date(byAdding: .day, value: 1, to: alarmDate)!
        } else {
            reminder.active = 0
            return
        }
        
        let interval = alarmDate.timeIntervalSinceNow
        let content = UNMutableNotificationContent()
        content.title = "Hysab Kytab"
        
        if reminder.flex1 == "1" {
            content.body = "Recurring transaction has been recorded"
        } else {
            content.body = "You have a transaction reminder"
        }
        
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest.init(identifier: String(reminder.reminderId), content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print("Error : " , error)
        }
    }
    
    private func postRecurringVoucher (reminder: Hkb_reminder) {
        if reminder.isexpense != 2 {
            let vch : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
            let category: Hkb_category = QueryUtils.fetchSingleCategory(categoryId: Int64(reminder.categoryId))!
            guard let account = QueryUtils.fetchSingleAccount(accountId: Int64(reminder.accountid)) as Hkb_account? else {
                return
            }
            var vchType = ""
//            let voucherId = QueryUtils.getMaxVoucherId() + 1
            let voucherId = Utils.getUniqueId()
            
            if reminder.isexpense == 0 {
                vchType = Constants.INCOME
            } else {
                vchType = Constants.EXPENSE
            }
            
            vch.account_id = Int64(reminder.accountid)
            vch.active = 1
            vch.vch_amount = Utils.removeComma(numberString: String(reminder.amount))
            vch.category_id = Int64(reminder.categoryId)
            vch.vch_no = "1"
            vch.month = Utils.getDayMonthAndYear(givenDate: reminder.rmdate!, dayMonthOrYear: Constants.MONTH)
            vch.vch_year = Utils.getDayMonthAndYear(givenDate: reminder.rmdate!, dayMonthOrYear: Constants.YEAR)
            vch.vch_day = Utils.getDayMonthAndYear(givenDate: reminder.rmdate!, dayMonthOrYear: Constants.DAY)
            vch.vch_type = vchType
            vch.vch_date = reminder.rmdate
            vch.vch_description = "\(vchType) recurring transaction"
            vch.vch_image = ""
            vch.flex3 = "0"
            vch.flex1 = ""
            vch.vchtrxplace = ""
            vch.accountname = account.title
            vch.categoryname = category.title
            vch.tag = ""
            vch.eventid = 0
            vch.ref_no = ""
            vch.eventname = ""
            vch.created_on = reminder.rmdate
            vch.updated_on = reminder.rmdate
            vch.vchcurrency = LocalPrefs.getUserCurrency()
            vch.voucher_id = Int64(voucherId)
            
            if vchType == Constants.EXPENSE {
                vch.vch_amount = vch.vch_amount * -1
            }
            
            pushRecurringVchOnFirebase(vch: vch)
        } else {
            let voucher1 : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
//            let maxVoucherId : Int = Int(QueryUtils.getMaxVoucherId() + 1)
            let maxVoucherId : Int64 = Utils.getUniqueId()
            voucher1.account_id = Int64(reminder.account_from)
            voucher1.active = 1
            voucher1.vch_no = "0"
            voucher1.vch_date = reminder.rmdate
            voucher1.flex1 = ""
            voucher1.vch_amount = (reminder.amount * -1)
            voucher1.vch_description = "Transfer recurring transaction"
            voucher1.vch_day = Utils.getDayMonthAndYear(givenDate: reminder.rmdate!, dayMonthOrYear: "day")
            voucher1.vch_year = Utils.getDayMonthAndYear(givenDate: reminder.rmdate!, dayMonthOrYear: "year")
            voucher1.month = Utils.getDayMonthAndYear(givenDate: reminder.rmdate!, dayMonthOrYear: "month")
            voucher1.vch_type = Constants.TRANSFER
            voucher1.tag = ""
            voucher1.fcrate = ""
            voucher1.fccurrency = ""
            voucher1.vch_image = ""
            voucher1.created_on = reminder.rmdate
            voucher1.vchcurrency = LocalPrefs.getUserCurrency()
            voucher1.ref_no = String(maxVoucherId + 1)
            voucher1.voucher_id = Int64(maxVoucherId)
            voucher1.updated_on = reminder.rmdate
            
            let voucher2 : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
            voucher2.account_id = Int64(reminder.accountid)
            voucher2.active = 1
            voucher2.vch_no = "1"
            voucher2.vch_date = reminder.rmdate
            voucher2.flex1 = ""
            voucher2.vch_amount = reminder.amount
            voucher2.vch_description = "Transfer recurring transaction"
            voucher2.vch_day = Utils.getDayMonthAndYear(givenDate: reminder.rmdate!, dayMonthOrYear: "day")
            voucher2.vch_year = Utils.getDayMonthAndYear(givenDate: reminder.rmdate!, dayMonthOrYear: "year")
            voucher2.month = Utils.getDayMonthAndYear(givenDate: reminder.rmdate!, dayMonthOrYear: "month")
            voucher2.vch_type = Constants.TRANSFER
            voucher2.tag = ""
            voucher2.fcrate = ""
            voucher2.fccurrency = ""
            voucher2.vch_image = ""
            voucher2.vchcurrency = LocalPrefs.getUserCurrency()
            voucher2.created_on = reminder.rmdate
            voucher2.voucher_id = Int64(maxVoucherId + 1)
            voucher2.ref_no = String(maxVoucherId)
            voucher2.updated_on = reminder.rmdate
            
            pushRecurringVchOnFirebase(vch: voucher1)
            pushRecurringVchOnFirebase(vch: voucher2)
        }
        
        DbController.saveContext()
    }
    
    private func pushRecurringVchOnFirebase (vch : Hkb_voucher) {
        let currentDate = Date()
        let dbRef = Database.database().reference()
        let weekOfYear = Calendar.current.component(.weekOfYear, from: currentDate)
        let year = Calendar.current.component(.year, from: currentDate)
        let voucher = Utils.convertVchIntoDict(object: vch)
        
        if let branchId = LocalPrefs.getUserData()["branch_id"] {
            dbRef
                .child("hk_vch")
                .child("\(year)-\(weekOfYear)")
                .child("hk_vch_ios")
                .child(branchId)
                .child(String(vch.voucher_id))
                .setValue(voucher)
            
            dbRef
                .child("ios")
                .child("voucher")
                .child(branchId)
                .child(String(vch.voucher_id))
                .setValue(voucher)
        }
    }
    
    private func registerDefaultLocalValues () {
        UserDefaults.standard.register(defaults: [LocalPrefs.OVER_VIEW_VISIBILTY : true])
        UserDefaults.standard.register(defaults: [LocalPrefs.ACCOUNTS_VISIBILITY : true])
        UserDefaults.standard.register(defaults: [LocalPrefs.LAST_RECORDS_VISIBILITY : true])
        UserDefaults.standard.register(defaults: [LocalPrefs.DEVICE_TOKEN : ""])
        UserDefaults.standard.register(defaults: [LocalPrefs.PROFESSION_TYPE : ""])
    }
    
    private func setInappNotification (title: String , codeType: Int , image: String, url: String , btnText: String , content: String , expiry: String) {
        LocalPrefs.setInappVisibility(visibilty: true)
        let currentDate = Date()
        let notification : Hkb_notifications = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_NOTIFICATIONS, into: DbController.getContext()) as! Hkb_notifications
        notification.title = title
        notification.buttontext = btnText
        notification.codetype = Int32(codeType)
        notification.createdOn = Utils.currentDateDbFormat(date: currentDate)
        notification.day = String(Utils.getDayMonthAndYear(givenDate: Utils.currentDateDbFormat(date: currentDate), dayMonthOrYear: "day"))
        notification.isRead = 0
        notification.imageurl = image
        notification.message = content
        notification.month = String(Utils.getDayMonthAndYear(givenDate: Utils.currentDateDbFormat(date: currentDate), dayMonthOrYear: "month"))
        notification.expirydate = expiry
        DbController.saveContext()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        //        let userInfo = JSON(userInfo)
        //        let aps = userInfo["aps"].dictionaryValue
        //        let data = aps["data"]!.stringValue
        //        var splitArray = data.components(separatedBy: "~")
        //        let type = splitArray[0]
        //
        //        if type == "in_app" {
        //            let title = splitArray[1]
        //            let content = splitArray[2]
        //            let codeType = splitArray[3]
        //            let url = splitArray[4]
        //            let btnText = splitArray[5]
        //            let image = splitArray[6]
        //            let expiry = splitArray[7]
        //            setInappNotification(title: title, codeType: Int(codeType)!, image: image, url: url, btnText: btnText, content: content, expiry: expiry)
        //        } else if type == "uber" {
        //            let amount = splitArray[1]
        //            uberTransaction(amount: Double(amount)!)
        //        }
    }
    
    private func uberTransaction (amount: Double) {
        let category = QueryUtils.fetchCategoryByName(nameString: "Fuel & Transport", categoryId: 0)
        let voucher : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
        let date = Utils.currentDateDbFormat(date: Date())
        voucher.account_id = 1
        voucher.active = 1
        voucher.created_on = date
        voucher.vch_amount = amount
        voucher.vch_no = "1"
        voucher.vch_type = Constants.EXPENSE
        voucher.vch_day = Utils.getDayMonthAndYear(givenDate: date, dayMonthOrYear: "day")
        voucher.month = Utils.getDayMonthAndYear(givenDate: date, dayMonthOrYear: "month")
        voucher.vch_year = Utils.getDayMonthAndYear(givenDate: date, dayMonthOrYear: "year")
        voucher.vch_date = date
        voucher.vch_description = "Travelling with Uber"
        
        if category != nil {
            voucher.category_id = Int64((category?.categoryId)!)
        }
        
        DbController.saveContext()
    }
    
    private func showGeofenceNotification (message : String) {
        let content = UNMutableNotificationContent()
        content.title = "Hysab Kytab"
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest.init(identifier: "Geofence", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print("Error : " , error as Any)
        }
    }
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            
        }
        
        return handled
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            showGeofenceNotification(message: "Entered region \(region.identifier)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            showGeofenceNotification(message: "Exited region \(region.identifier)")
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        //        handleShortcutItem()
        
        
    }
    
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    private func handleShortcutItem () {
        let rootViewController = self.window?.rootViewController
        let transactionVC = UIUtils.getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: ViewIdentifiers.VC_TRANSACTION_LOGGING) as! TransactionLoggingViewController
        let navController = UINavigationController(rootViewController: transactionVC)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    
    private func initFirebaseNotifications (application : UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    
    // Mixpanel Function
    func InitializeMixPanel(){
        Mixpanel.initialize(token: Constants.MIXPANEL_TOKEN)
        Mixpanel.mainInstance().flushInterval = 10
        var mixpanelID = UserDefaults.standard.object(forKey: "MixpanelID")
        if (mixpanelID == nil) {
            mixpanelID = "mehmood.hassan@jbs.com"
            UserDefaults.standard.set(mixpanelID, forKey: "MixpanelID")
        }
        Mixpanel.mainInstance().identify(distinctId: mixpanelID as! String)
        //Mixpanel.mainInstance().registerSuperProperties(["App Language" : "English"])
        Mixpanel.mainInstance().track(event: "App Launched")
    }
    
//    func checkInternet(){
//        if #available(iOS 12.0, *) {
//            let monitor = NWPathMonitor()
//            let queue = DispatchQueue(label: "Monitor")
//            monitor.start(queue: queue)
//            monitor.pathUpdateHandler = { path in
//                if path.status == .satisfied {
//                    print("We're connected!")
////                    UIUtils.showSnackbar(message: "You're connected to Internet")
//                } else {
//                    print("No connection.")
//                    UIUtils.showSnackbarNegative(message: "No Internet Connection")
//                }
//
//                print(path.isExpensive)
//            }
//
//
//        } else {
//            // Fallback on earlier versions
//        }
//    }
}


extension AppDelegate/*: GIDSignInDelegate */ {
    
    private func addShortCuts (application: UIApplication) {
        let shortcut1 = UIMutableApplicationShortcutItem(type: "SearchDoc",
                                                         localizedTitle: "Search",
                                                         localizedSubtitle: "Search document",
                                                         icon: UIApplicationShortcutIcon(type: .add),
                                                         userInfo: nil)
        application.shortcutItems = [shortcut1]
    }
}


extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
