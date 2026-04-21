

import UIKit
import Firebase
import CoreLocation
import CoreData
import SwiftyJSON
import Alamofire
import SocketIO
import Instructions
import FirebaseAnalytics

class TabBarViewController: UITabBarController , NotificationDetailsTapListeners, CLLocationManagerDelegate, UITabBarControllerDelegate {
    
    
    
    
    var window: UIWindow?
    var centerContainer: MMDrawerController?
    @IBOutlet weak var menu_button: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var latitude = ""
    var longitude = ""
    var manager: SocketManager!
    private var unsyncedArray : Array<Hkb_voucher> = []
    private let button = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
    private let coachMarksController = CoachMarksController()
    var isPopUpRequired: Bool?
    var tabViewControllers: [UIViewController]?
    
    public var selectedTab = 0 {
        didSet {
            if isViewLoaded {
                self.selectedIndex = selectedTab
            }
        }
    }
    lazy var backupAlert: BackupAlertView = {
        let backupAlertview = BackupAlertView()
        
        return backupAlertview
    }()
    
    override func viewDidLoad() {
        
        postActivityToFirebase()
        postActivities()
        
        
        
        print("TOKEN : " , LocalPrefs.getDeviceToken())
        
        if !LocalPrefs.getUpdateMessage() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigateToWalkthrough()
            }
        }
        
        
        self.coachMarksController.overlay.isUserInteractionEnabled = true
        self.coachMarksController.dataSource = self
        self.delegate = self
        controllersForTabs()
        
        if let tabbarItems = self.tabBar.items {
            tabbarItems[2].isEnabled = false
        }
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        
        tabBar.tintColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR)
        tabBar.barTintColor = UIColor.white
        tabBar.isTranslucent = false
        
        
        self.backupAlert.animateIn(viewController: self)
        self.backupAlert.showAlert()
        
        self.selectedIndex = selectedTab
        self.observerForCoreData()
        
        if LocalPrefs.getUserPhone() != "" {
            self.verifyUser(verify_device: false)
        }
        
        if Reachability.isConnectedToNetwork(){
            //            self.verifyUser(verify_device: true)
            self.verifySessionFromServer()
        }
    }
    
    
    private func observerForCoreData(){
        //        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: DbController.getContext())
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)
        
        
        
        
    }
    
    
    public func popupAppear(){
        //        if self.isPopUpRequired == nil || self.isPopUpRequired == true{
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.backupAlert.popUpRequired == true{
                
                self.backupAlert.mainView.isHidden = false
                //            }
                
            } else {
                
                self.backupAlert.mainView.isHidden = true
            }
        }
        
        //            if self.backupAlert.popUpRequired == true{
        //
        //                self.backupAlert.mainView.isHidden = false
        ////            }
        //
        //        } else {
        //
        //            self.backupAlert.mainView.isHidden = true
        //        }
    }
    
    public func popupDisappear(){
        self.backupAlert.mainView.isHidden = true
    }
    
    @objc func methodOfReceivedNotification(notification: NSNotification) {
        // Take Action on Notification
        print("Working Observer")
        self.isPopUpRequired = true
        self.backupAlert.popUpRequired = true
        self.backupAlert.showAlert()
        
        
        //        if UIApplication.shared.keyWindow?.rootViewController == self.presentedViewController{
        //            self.backupAlert.showAlert(viewController: self)
        //        }
        //        if self.navigationController?.viewControllers.count == nil{
        //            self.backupAlert.showAlert(viewController: self)
        //        }
    }
    
    func verifySessionFromServer(){
        APIManager.sharedInstance.verifySession { status, message, error in
            if status == 400{
                //                self.verifyUser(verify_device: true)
//                UIUtils.showLoader(view: self.view)
                self.verifyUser(verify_device: true)
            } else if status == 1 {
                print("You are verified")
                //                self.verifyUser(verify_device: true)
            } else {
                print("Login to Other Device")
                UIUtils.showSnackbarNegative(message: error?.localizedDescription ?? "Something went wrong")
            }
        }
        
    }
    
    
    private func verifyUser(verify_device: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let dest = UIUtils.getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: "VerifyVC") as! VerifyVC
            dest.verify_Device = verify_device
            dest.modalPresentationStyle = .overCurrentContext
            self.present(dest, animated: true, completion: nil)
        }
    }
    
    private func logOutUser(){
    //        if let destination = UIUtils.getStoryboard(name: ViewIdentifiers.SB_BACKUP).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SKIP_MESSAGE) as? SkipRestoreMessage{
    //            destination.logout = true
    //            destination.modalPresentationStyle = .overCurrentContext
    //            present(destination, animated: true, completion: nil)
    //        }
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Analytics.logEvent("App_Logout", parameters: nil)
                LocalPrefs.setIsDataWiped(isDataWiped: false)
                LocalPrefs.setIsRegistered(isRegistered: false)
                LocalPrefs.setIsVerified(isVerified: false)
                
    //            let domain = Bundle.main.bundleIdentifier!
    //            UserDefaults.standard.removePersistentDomain(forName: domain)
    //            UserDefaults.standard.synchronize()
    //            print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)

                QueryUtils.deleteAllSavings()
                QueryUtils.deleteAllAccounts()
                QueryUtils.deleteAllCategories()
                QueryUtils.deleteSavingTransactions()
                QueryUtils.deleteAllTransaction()
                QueryUtils.deleteAllBudgets()
                QueryUtils.deleteAllEvents()
        //        DbController.shared.clearDatabase {
                    let navController = UINavigationController()
                    let storyboard = UIUtils.getStoryboard(name: ViewIdentifiers.SB_ONBOARDING)
                    if let dest = storyboard.instantiateViewController(withIdentifier: "GetStartedVC") as? GetStartedViewController{
                        navController.viewControllers = [dest]
                        navController.modalPresentationStyle = .fullScreen
                        UIUtils.dismissLoader(uiView: self.view)
                        self.present(navController, animated: true) {
                            let domain = Bundle.main.bundleIdentifier!
                            UserDefaults.standard.removePersistentDomain(forName: domain)
                            UserDefaults.standard.synchronize()
                            print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
                        }
                    }
    //        }
                
        }

    
    private func navigateToWalkthrough () {
        LocalPrefs.setUpdateMessage(isShown: true)
        let vc = UIUtils.getStoryboard(name: ViewIdentifiers.SB_BACKUP).instantiateViewController(withIdentifier: ViewIdentifiers.VC_NOTIFICATION_MESSAGE) as! BackupNotificationVC
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        
        //        let walkthroughVc = UIUtils.getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_WALKTHROUGH) as! WalkthroughViewController
        //        walkthroughVc.delegate = self
        //        let navController = UINavigationController(rootViewController: walkthroughVc)
        //        self.present(navController, animated: true, completion: nil)
    }
    
    private func controllersForTabs () {
        let controller1 = UIUtils.getStoryboard(name: ViewIdentifiers.SB_DASHBOARD).instantiateViewController(withIdentifier: "NavigationDashboard")
        controller1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "ic_home"), tag: 1)
        
        
        let controller2 = UINavigationController()
        let pfmLandingVC = UIUtils.getStoryboard(name:ViewIdentifiers.SB_PFM).instantiateViewController(withIdentifier: ViewIdentifiers.VC_PFM_PAGE)
        controller2.viewControllers = [pfmLandingVC]
        //        let controller2 = UIUtils.getStoryboard(name: ViewIdentifiers.SB_BUDGET).instantiateViewController(withIdentifier: "NavigationManageBudgetVC")
        controller2.tabBarItem = UITabBarItem(title: "Money", image: UIImage(named: "ic_tab_pfm"), tag: 2)
        
        let controller3 = UIViewController()
        let nav3 = UINavigationController(rootViewController: controller3)
        nav3.title = ""
        
        
        let chartsVC = UIUtils.getStoryboard(name: ViewIdentifiers.SB_CHARTS).instantiateViewController(withIdentifier: ViewIdentifiers.VC_CHARTS)
        let controller4 = UINavigationController(rootViewController: chartsVC)
        controller4.tabBarItem = UITabBarItem(title: "Insights", image: UIImage(named: "ic_charts"), tag: 3)
        
        let savingsVC = UIUtils.getStoryboard(name: ViewIdentifiers.SB_SAVING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SAVING)
        let controller5 = UINavigationController(rootViewController: savingsVC)
        controller5.tabBarItem = UITabBarItem(title: "Savings", image: UIImage(named: "savings_inactive"), tag: 4)
        
        
        
        viewControllers = [controller1, controller2, controller3, controller4, controller5]
        tabViewControllers = viewControllers
        
        setupMiddleButton()
    }
    
    
    func setupMiddleButton() {
        let circularView: GradientView = GradientView(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        
        let cornerRadius = circularView.frame.width/2
        circularView.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: circularView.bounds, cornerRadius: cornerRadius)
        var circularViewFrame = circularView.frame
        circularViewFrame.origin.y = -10
        circularViewFrame.origin.x = view.bounds.width/2 - circularViewFrame.size.width/2
        circularView.frame = circularViewFrame
        
        circularView.layer.masksToBounds = false
        circularView.layer.shadowColor = UIColor.groupTableViewBackground.cgColor
        circularView.layer.shadowOffset = CGSize(width: 0, height: 2)
        circularView.layer.shadowOpacity = 1
        circularView.layer.shadowPath = shadowPath.cgPath
        
        
        button.setImage(UIImage(named: "ic_add"), for: .normal)
        button.tintColor = UIColor.white
        circularView.addSubview(button)
        tabBar.addSubview(circularView)
        
        
        tabBar.layoutIfNeeded()
        button.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
    }
    
    @objc private func menuButtonAction(sender: UIButton) {
        let sb = UIUtils.getStoryboard(name: ViewIdentifiers.SB_TRANSACTION)
        let transactionVC = sb.instantiateViewController(withIdentifier: ViewIdentifiers.VC_TRANSACTION_LOGGING)
        let navController = UINavigationController()
        navController.viewControllers = [transactionVC]
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    
    private func setRegion()  {
        let geofenceRegionCenter1 = CLLocationCoordinate2DMake(24.863963600, 67.073590600)
        let geofenceRegionCenter2 = CLLocationCoordinate2DMake(24.895841, 67.068168)
        
        
        let region = CLCircularRegion(center: geofenceRegionCenter1,
                                      radius: 100,
                                      identifier: "Hk Room")
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        let region1 = CLCircularRegion(center: geofenceRegionCenter2,
                                       radius: 100,
                                       identifier: "My Home")
        
        
        region1.notifyOnEntry = true
        region1.notifyOnExit = true
        
        
        locationManager.startMonitoring(for: region)
        locationManager.requestState(for: region)
        
        locationManager.startMonitoring(for: region1)
        locationManager.requestState(for: region1)
        locationManager.startMonitoringSignificantLocationChanges()
        
    }
    
    private func initVariables () {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    private func fetchUnsyncedVouchers() -> Array<Hkb_voucher> {
        let arrayOfUnsyncedVch = SyncUtils.fetchUnsyncedVouchers()
        print("Unsynced : " , arrayOfUnsyncedVch.count)
        return arrayOfUnsyncedVch
    }
    
    
    func updateLatLong () {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            latitude = String(describing: locationManager.location!.coordinate.latitude)
            longitude = String(describing: locationManager.location!.coordinate.longitude)
            print("Lat : " , latitude , "Long : " , longitude)
        }
    }
    
    func postActivityToFirebase () {
        let branchId = LocalPrefs.getUserData()["branch_id"]!
        let dateTime = Utils.currentDateDbFormat(date: Date())
        
        let activity : Hkb_activity = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_ACTIVITY, into: DbController.getContext()) as! Hkb_activity
        activity.branchid = branchId
        activity.deviceversion = getOsVersion()
        activity.devicemodel = UIDevice.current.modelName
        activity.devicename = "Apple"
        activity.appversion = getAppVersion()
        activity.iosversion = getOsVersion()
        activity.activitydatetime = dateTime
        activity.hkappcodeversion = getCodeVersion()
        activity.latitude = latitude
        activity.longitude = longitude
        
        DbController.saveContext()
        
        if branchId != "" {
            let activityDetails = Utils.convertVchIntoDict(object: activity)
            let dbRef = Database.database().reference()
            dbRef.child("activity").child(branchId).childByAutoId().setValue(activityDetails)
        }
    }
    
    func getAppVersion () -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        let appVersion = nsObject as! String
        return appVersion
    }
    
    func getCodeVersion () -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleVersion"] as AnyObject
        let codeVersion = nsObject as! String
        return codeVersion
    }
    
    func getOsVersion () -> String {
        let systemVersion = UIDevice.current.systemVersion
        return systemVersion
    }
    
    private func showReminderAlert () {
        if LocalPrefs.checkForNil(key: LocalPrefs.REMINDER_ID) {
            let hkb_reminder = QueryUtils.fetchSingleReminder(reminderId: Int64(LocalPrefs.getReminderId()))
            let categoryId = hkb_reminder.categoryId
            let isExpense = hkb_reminder.isexpense
            LocalPrefs.setReminderId(reminderId: nil)
            let category = QueryUtils.fetchSingleCategory(categoryId: Int64(categoryId))
            
            let alert = UIAlertController(title: "Reminder", message: "You have a transaction reminder for \(category?.title ?? Constants.NULL_TEXT). Would you like to add the transaction?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Add Transaction", style: UIAlertAction.Style.default, handler: {action in
                //                let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
                //                let dest = storyboard.instantiateViewController(withIdentifier: "IncomeExpenseVC") as! IncomeExpenseViewController
                //                if isExpense == 1 {
                //                    dest.vchType = Constants.EXPENSE
                //                } else {
                //                    dest.vchType = Constants.INCOME
                //                }
                //
                //                dest.vch_description = hkb_reminder.title!
                //                dest.categoryId = Int(categoryId)
                //                self.navigationController?.pushViewController(dest, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //    private func updateProfileAlert () {
    //        let context = DbController.getContext()
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Hkb_voucher")
    //        var transactionCount = 0
    //      do {
    //        transactionCount = try context.count(for: fetchRequest)
    //        } catch  {
    //            print("Error : ", error)
    //        }
    //        var dob = ""
    //        let name = LocalPrefs.getUserData()["user_name"]!
    //        let email = LocalPrefs.getUserData()["email"]!
    //        if let dateOfBirth = LocalPrefs.getUserData()["dob"] {
    //            dob = dateOfBirth
    //        }
    //
    //        let professionType = LocalPrefs.getProfessionType()
    //
    //        print("DETAILS : " , name , email , dob)
    //
    //        if transactionCount > 2 && (name == "Guest" || email == "" || dob == "") {
    //            let alert = UIAlertController(title: "Complete Profile", message: "Please complete your profile", preferredStyle: UIAlertControllerStyle.alert)
    //
    //            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
    //                 Analytics.logEvent("UP_dismis_clickcount", parameters: [ : ])
    //            }))
    //
    //            alert.addAction(UIAlertAction(title: "Update Profile", style: UIAlertActionStyle.default, handler: {action in
    //                Analytics.logEvent("UP_up_clickcount", parameters: [ : ])
    //                let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
    //                let dest = storyboard.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterViewController
    //                dest.isUpdate = true
    //                self.navigationController?.pushViewController(dest, animated: true)
    //            }))
    //
    //            self.present(alert, animated: true, completion: nil)
    //        }
    //    }
    
    public func notifyOnBudgetProgress (categoryId : Int64 , month : Int , year : Int) {
        var message : String = ""
        var percentage : Int = 0
        let budgetAmount = BudgetDbUtils.fetchBudgetAmount(categoryId: categoryId, currentInterval: Constants.MONTHLY, month: String(month) , year: year)
        let spentAmount = ActivitiesDbUtils.getVoucherSumWithCategoryID(categoryId: categoryId, type: Constants.EXPENSE, currentInterval: Constants.MONTHLY, month: String(month), year: year)
        let category = QueryUtils.fetchSingleCategory(categoryId: Int64(categoryId))
        
        if budgetAmount != 0 {
            let leftAmount = budgetAmount - abs(spentAmount)
            percentage = Int((abs(spentAmount) / budgetAmount) * 100)
            if percentage >= 80 && percentage < 100 {
                let arrayOfNotifications = NotificationDbUtils.fetchNotification(categoryId: categoryId, message: Constants.BUDGET_80, month: String(month), year: String(year))
                if arrayOfNotifications.count == 0 {
                    message = "You have consumed \(percentage)% of your \(category?.title ?? Constants.NULL_TEXT) budget. Spend wisely to stay within the allocated budget!"
                    showAlertOnBudgetProgress(message: message, positiveBtn: "Revise budget", categoryId: categoryId)
                    createNotificationForBudget(categoryId: categoryId, message: message, month: String(month), year: String(year), budgetReched: Constants.BUDGET_80)
                }
            } else if percentage > 100 {
                let arrayOfNotifications = NotificationDbUtils.fetchNotification(categoryId: categoryId, message: Constants.BUDGET_100, month: String(month), year: String(year))
                if arrayOfNotifications.count == 0 {
                    message = "This month, you spent \(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(spentAmount), decimal: LocalPrefs.getDecimalFormat())) on \(category?.title ?? Constants.NULL_TEXT) budget. This exceed your budget of \(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: budgetAmount, decimal: LocalPrefs.getDecimalFormat())) by \(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(leftAmount), decimal: LocalPrefs.getDecimalFormat()))"
                    showAlertOnBudgetProgress(message: message, positiveBtn: "Revise budget", categoryId: categoryId)
                    createNotificationForBudget(categoryId: categoryId, message: message, month: String(month), year: String(year), budgetReched: Constants.BUDGET_100)
                }
            }
        } else {
            let arrayOfNotifications = NotificationDbUtils.fetchNotification(categoryId: categoryId, message: Constants.NO_BUDGET, month: String(month), year: String(year))
            if arrayOfNotifications.count == 0 {
                message = "Seems like you have not defined a budget for \(category?.title ?? Constants.NULL_TEXT). Would you like to set?"
                showAlertOnBudgetProgress(message: message, positiveBtn: "Set budget", categoryId: categoryId)
                createNotificationForBudget(categoryId: categoryId, message: message, month: String(month), year: String(year), budgetReched: Constants.NO_BUDGET)
            }
        }
    }
    
    private func showAlertOnBudgetProgress (message : String , positiveBtn : String , categoryId : Int64) {
        let alert = UIAlertController(title: "Budget Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Later", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: positiveBtn, style: UIAlertAction.Style.default, handler: {action in
            let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
            let dest = storyboard.instantiateViewController(withIdentifier: "AddBudgetVC") as! AddBudgetViewController
            //            dest.categoryId = categoryId
            self.navigationController?.pushViewController(dest, animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func createNotificationForBudget (categoryId : Int64, message : String, month : String, year : String, budgetReched: String) {
        let hkb_notification : Hkb_notifications = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_NOTIFICATIONS, into: DbController.getContext()) as! Hkb_notifications
        let date = Date()
        let expiryDate = Calendar.current.date(byAdding: .year, value: 1, to: date)
        hkb_notification.message = message
        hkb_notification.createdOn = Utils.currentDateDbFormat(date: date)
        hkb_notification.month = month
        hkb_notification.year = year
        hkb_notification.codetype = 0
        hkb_notification.categoryId = Int64(categoryId)
        hkb_notification.title = "Budget alert"
        hkb_notification.expirydate = Utils.currentDateDbFormat(date: expiryDate!)
        hkb_notification.imageurl = "http://hysabkytab.com/bo/hysab_kytab_img/budget/budget_alert.png"
        hkb_notification.buttontext = "Go back"
        hkb_notification.flex1 = budgetReched
        
        DbController.saveContext()
    }
    
    private func showInappNotification () {
        if LocalPrefs.getInappVisibility() {
            LocalPrefs.setInappVisibility(visibilty: false)
            let dialogInapp = DialogNotification()
            dialogInapp.modalPresentationStyle = .overCurrentContext
            dialogInapp.myDelegate = self
            self.present(dialogInapp, animated: true, completion: nil)
        }
    }
    
    
    // converts  NSmanaged objects into dictionary of array
    private func convertArrayToDictionary (givenArray: Array<Any>) -> Array<[String: Any]>  {
        var arrayToReturn : Array<[String: Any]> = []
        
        for i in 0 ..< givenArray.count {
            let singleObject = givenArray[i]
            let singleObjectDict = Utils.convertVchIntoDict(object: singleObject as! NSManagedObject)
            arrayToReturn.append(singleObjectDict)
        }
        
        return arrayToReturn
    }
    
    // if network response is success, changed field is_synced to 1
    private func changeSyncStatus (arrayOfObject: Array<NSManagedObject>) {
        for object in arrayOfObject {
            object.setValue(1, forKey: "is_synced")
        }
    }
    
    
    
    private func syncRecords () {
        // fetch array to convert into dictionary
        let accountsArray = SyncUtils.fetchUnsyncedAccounts()
        let categoryArray = SyncUtils.fetchUnsyncedCategories()
        let voucherArray = SyncUtils.fetchUnsyncedVouchers()
        let eventsArray = SyncUtils.fetchUnsyncedEvents()
        let budgetsArray = SyncUtils.fetchUnsyncedBudgets()
        let goalsArray = SyncUtils.fetchUnsyncedGoals()
        let goalTrxArray = SyncUtils.fetchUnsyncedGoalTrx()
        
        
        // Send JSON to server
        syncAllNetworkCall(vouchers: voucherArray, accounts: accountsArray, categories: categoryArray, events: eventsArray, budgets: budgetsArray, goals: goalsArray, goalTransactions: goalTrxArray)
    }
    
    private func syncAllNetworkCall (vouchers : Array<Hkb_voucher>, accounts: Array<Hkb_account>, categories: Array<Hkb_category>, events: Array<Hkb_event>, budgets: Array<Hkb_budget>, goals: Array<Hkb_goal>, goalTransactions: Array<Hkb_goal_trx>) {
        
        // convert array to into dictionary
        let accountsDict = convertArrayToDictionary(givenArray: accounts)
        let categoriesDict = convertArrayToDictionary(givenArray: categories)
        let voucherDict = convertArrayToDictionary(givenArray: vouchers)
        let eventsDict = convertArrayToDictionary(givenArray: events)
        let budgetsDict = convertArrayToDictionary(givenArray: budgets)
        let goalTrxDict = convertArrayToDictionary(givenArray: goals)
        let goalsDict = convertArrayToDictionary(givenArray: goalTransactions)
        
        // convert dictionary into JSON
        let vouchJson = Utils.convertDictIntoJson(object: voucherDict)
        let categoryJson = Utils.convertDictIntoJson(object: categoriesDict)
        let accountJson = Utils.convertDictIntoJson(object: accountsDict)
        let eventsJson = Utils.convertDictIntoJson(object: eventsDict)
        let budgetsJson = Utils.convertDictIntoJson(object: budgetsDict)
        let goalsJson = Utils.convertDictIntoJson(object: goalsDict)
        let goalTrxJson = Utils.convertDictIntoJson(object: goalTrxDict)
        
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/sync"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        let httpMethod = Alamofire.HTTPMethod.post
        let params = ["transactions" : vouchJson,
                      "accounts" : accountJson,
                      "categories" : categoryJson,
                      "events" : eventsJson,
                      "goals" : goalsJson,
                      "goals_transactions" : goalTrxJson,
                      "budgets" : budgetsJson,
                      "device_type" : "Ios",
                      "consumer_id" : consumerId]
        
        
        Alamofire.request(URL, method: httpMethod, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseObj = JSON(response.result.value!)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    print("ResponseStatus : " , status,  message)
                    if status == 1 {
                        // if network response is success, changed field is_synced to 1
                        self.changeSyncStatus(arrayOfObject: vouchers)
                        self.changeSyncStatus(arrayOfObject: accounts)
                        self.changeSyncStatus(arrayOfObject: categories)
                        self.changeSyncStatus(arrayOfObject: goals)
                        self.changeSyncStatus(arrayOfObject: goalTransactions)
                        self.changeSyncStatus(arrayOfObject: events)
                        self.changeSyncStatus(arrayOfObject: budgets)
                        
                        DbController.saveContext()
                    }
                    
                case .failure(let error):
                    print("Error : " , error.localizedDescription)
                }
            }
    }
    
    private func postActivities () {
        let arrayOfActivities = QueryUtils.fetchAllActivities()
        var arrayOfActivityDict = convertArrayToDictionary(givenArray: arrayOfActivities)
        let activityJson = Utils.convertDictIntoJson(object: arrayOfActivityDict)
        
        let URL = "\(Constants.BASE_URL)/activity/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        let dictToEncrypt =  ["activity" : activityJson,
                              "device_type" : "Ios",
                              "consumer_id" : "\(LocalPrefs.getConsumerId())",]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    //                    let message = responseObj["message"].stringValue
                    
                    if status == 1 {
                        QueryUtils.deleteAllActivities()
                    }
                    
                case .failure(let error):
                    print("Could not save", error.localizedDescription)
                }
            }
    }
    
    func onMoreInfoTapped(notification: Hkb_notifications) {
        let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
        let dest = storyboard.instantiateViewController(withIdentifier: "NotificationDetailsVC") as! NotificationDetailsViewController
        dest.hkb_notification = notification
        self.navigationController?.pushViewController(dest, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)  \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
}

extension TabBarViewController : CoachMarksControllerDataSource, CoachMarksControllerDelegate  {
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        
        LocalPrefs.setIsTabbarOnboardingShown(isShown: true)
        let pof = button
        return coachMarksController.helper.makeCoachMark(for: pof)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        coachViews.bodyView.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        coachViews.arrowView?.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        coachViews.bodyView.hintLabel.textColor = UIColor.black
        coachViews.bodyView.nextLabel.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        coachViews.bodyView.hintLabel.font = UIFont(name: Style.font.REGULAR_FONT, size: 12.0)
        coachViews.bodyView.nextLabel.font = UIFont(name: "\(Style.font.REGULAR_FONT)-Bold", size: 14.0)
        
        
        coachViews.bodyView.hintLabel.text = "Add your income,expense or any other transaction by tapping this button"
        coachViews.bodyView.nextLabel.text = "NEXT"
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    //    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
    //        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
    //
    //        coachViews.bodyView.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
    //        coachViews.arrowView?.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
    //        coachViews.bodyView.hintLabel.textColor = UIColor.black
    //        coachViews.bodyView.nextLabel.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
    //        coachViews.bodyView.hintLabel.font = UIFont(name: Style.font.REGULAR_FONT, size: 12.0)
    //        coachViews.bodyView.nextLabel.font = UIFont(name: "\(Style.font.REGULAR_FONT)-Bold", size: 14.0)
    //
    //
    //        coachViews.bodyView.hintLabel.text = "Add your income,expense or any other transaction by tapping this button"
    //        coachViews.bodyView.nextLabel.text = "NEXT"
    //
    //        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    //    }
}

extension TabBarViewController: WalkthroughCompletionListener {
    
    
    func didFinishWalkthrough() {
        if !LocalPrefs.getIsTabbarOnboardingShown() {
            self.coachMarksController.start(in:.window(over: self))
        }
        
        
    }
    
    
}


//extension UINavigationController{
//     func pushViewController(_ viewController: UIViewController, animated: Bool){
//        if self.navigationController?.viewControllers.count ?? 0 > 1{
//
//        }
//    }
//}
