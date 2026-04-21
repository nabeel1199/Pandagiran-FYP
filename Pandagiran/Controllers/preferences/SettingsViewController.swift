
import UIKit
import Kingfisher
import CoreData
import Alamofire
import SwiftyJSON

class SettingsViewController: BaseViewController , FormatUpdateListener , CurrencySelectionListener {

    @IBOutlet weak var view_logout: UIView!
    @IBOutlet weak var label_user_email: UILabel!
    @IBOutlet weak var label_user_name: UILabel!
    @IBOutlet weak var view_profile: UIView!
    @IBOutlet weak var view_security: UIView!
    @IBOutlet weak var view_notifications: UIView!
    @IBOutlet weak var view_currency: UIView!
    @IBOutlet weak var view_current_format: UIView!
    @IBOutlet weak var view_wipe_data: UIView!
    @IBOutlet weak var view_backup_restore: UIView!
    @IBOutlet weak var view_export_excel: UIView!
    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var iv_currency_flag: UIImageView!
    @IBOutlet weak var label_format: UILabel!
    @IBOutlet weak var switch_security: UISwitch!
    @IBOutlet weak var view_country: UIView!
    @IBOutlet weak var iv_country_flag: UIImageView!
    @IBOutlet weak var label_country_name: UILabel!
  
    
    
    var vouchersArray : Array<Hkb_voucher> = []
    var categoriesArray : Array<Hkb_category> = []
    var accountsArray : Array<Hkb_account> = []
    var isCurrencyTapped = true
    
    lazy var backupAlert: BackupAlertView = {
        let backupAlertview = BackupAlertView()

        return backupAlertview
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        addGesturesOnViews()

    }
    
    func initVariables() {
        vouchersArray = QueryUtils.fetchAllVouchers()
        categoriesArray = QueryUtils.fetchCategories(type: "ALL")
        accountsArray = QueryUtils.fetchAccounts(accountType: ["Bank", "Cash", "Person"])
    }

    func initUI() {
        self.navigationItem.title = "Settings"
        
        let flagURL = URL(string : LocalPrefs.getCurrencyFlag())
        iv_currency_flag.kf.setImage(with: flagURL)
        label_format.text = String(LocalPrefs.getDecimalFormat())
        label_currency.text = LocalPrefs.getUserCurrency()
        
        let countryFlagUrl = URL(string : LocalPrefs.getCountryFlag())
        iv_country_flag.kf.setImage(with: countryFlagUrl)
        label_country_name.text = LocalPrefs.getCountryName()
        
        if LocalPrefs.checkForNil(key: LocalPrefs.PASSCODE) {
            switch_security.isOn = true
        } else {
            switch_security.isOn = false
        }
        
        let userDetails : [String:String] = LocalPrefs.getUserData()
        
        if let name = userDetails[Constants.USER_NAME] {
            label_user_name.text = name
        }
        
        if let email = userDetails[Constants.EMAIL] {
            label_user_email.text = email
        }
    }
    
    func addGesturesOnViews() {
        let profileGesture = UITapGestureRecognizer(target: self, action: #selector(onProfileTapped(sender:)))
        view_profile.addGestureRecognizer(profileGesture)
        let decimalGesture = UITapGestureRecognizer(target: self, action: #selector(onDecimalPlaceTapped(sender:)))
        view_current_format.addGestureRecognizer(decimalGesture)
        let currencyGesture = UITapGestureRecognizer(target: self, action: #selector(onCurrencyTapped(sender:)))
        view_currency.addGestureRecognizer(currencyGesture)
        let wipeGesture = UITapGestureRecognizer(target: self, action: #selector(onWipeDataTapped(sender:)))
        view_wipe_data.addGestureRecognizer(wipeGesture)
        let backupGesture = UITapGestureRecognizer(target: self, action: #selector(onBackupTapped(sender:)))
        view_backup_restore.addGestureRecognizer(backupGesture)
        let exportGesture = UITapGestureRecognizer(target: self, action: #selector(onExportExcelTapped(sender:)))
        view_export_excel.addGestureRecognizer(exportGesture)
        let wipeDataGest = UITapGestureRecognizer(target: self, action: #selector(onWipeDataTapped(sender:)))
        view_wipe_data.addGestureRecognizer(wipeDataGest)
        let securityGest = UITapGestureRecognizer(target: self, action: #selector(onSecurityTapped(sender:)))
        view_security.addGestureRecognizer(securityGest)
        let countryGest = UITapGestureRecognizer(target: self, action: #selector(onCountryTapped(sender:)))
        view_country.addGestureRecognizer(countryGest)
        let logoutGest = UITapGestureRecognizer(target: self, action: #selector(onLogoutTapped(sender:)))
        view_logout.addGestureRecognizer(logoutGest)
    }
    
    private func navigateToPasscodeVC () {
        let passcodeVC = getStoryboard(name: ViewIdentifiers.SB_SETTINGS).instantiateViewController(withIdentifier: ViewIdentifiers.VC_PASSCODE) as! PasscodeViewController
        passcodeVC.isUpdate = true
        self.navigationController?.pushViewController(passcodeVC, animated: true)
    }
    
    private func copyDatabase() {
//        let backupFileName = "Backup.sqlite"
//        let backupFilePath = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library").appendingPathComponent("Application Support").appendingPathComponent(backupFileName)
//        let mainDataPSC = DbController.persistentContainer.persistentStoreCoordinator
//        let migratePSC = NSPersistentStoreCoordinator(managedObjectModel: mainDataPSC.managedObjectModel)
//        let origStore = mainDataPSC.persistentStores.first!
//
//        try! migratePSC.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: mainDataPSC.persistentStores.first!.url!, options: nil)
//
//        let activityVC = UIActivityViewController(activityItems: [backupFilePath], applicationActivities: nil)
//        present(activityVC, animated: true, completion: nil)
        
        let backUpFolderUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        let backupUrl = backUpFolderUrl.appendingPathComponent("backup")
        let container = NSPersistentContainer(name: "Hysab Kytab")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in })

        let store:NSPersistentStore
        store = container.persistentStoreCoordinator.persistentStores.last!
        do {
            try container.persistentStoreCoordinator.migratePersistentStore(store,
                                                                            to: backupUrl,
                                                                            options: nil,
                                                                            withType: NSSQLiteStoreType)
        } catch {
            print("Failed to migrate" , error)
        }
        
        LocalPrefs.setIsDataWiped(isDataWiped: true)
        QueryUtils.deleteAllSavings()
        QueryUtils.deleteAllNotifications()
        QueryUtils.deleteAllAccounts()
        QueryUtils.deleteAllCategories()
        QueryUtils.deleteSavingTransactions()
        QueryUtils.deleteAllTransaction()
        QueryUtils.deleteAllEvents()
        let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
        let dest = storyboard.instantiateViewController(withIdentifier: "LandingViewController")
        dest.modalPresentationStyle = .fullScreen
        self.present(dest, animated: true, completion: nil)
    }
    
    @objc func onProfileTapped (sender : UITapGestureRecognizer) {
        let profileVC = getStoryboard(name: ViewIdentifiers.SB_SETTINGS).instantiateViewController(withIdentifier: ViewIdentifiers.VC_PROFILE) as! UserProfileViewController
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func onWipeDataTapped (sender : UITapGestureRecognizer) {
//        WipeAllDataAlert
        let storyboard = UIUtils.getStoryboard(name: ViewIdentifiers.SB_BACKUP)
        if let dest = storyboard.instantiateViewController(withIdentifier: "WipeAllDataAlert") as? WipeAllDataAlert{
            dest.modalPresentationStyle = .overCurrentContext
            self.present(dest, animated: true, completion: nil)
        }
//        let alert = UIAlertController(title: "Wipe All Data", message: "This will delete all your accounts , categories , transactions and saving goals. Do you wish to continue?", preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {action in
//            LocalPrefs.setIsDataWiped(isDataWiped: true)
//            QueryUtils.deleteAllSavings()
//            QueryUtils.deleteAllAccounts()
//            QueryUtils.deleteAllCategories()
//            QueryUtils.deleteSavingTransactions()
//            QueryUtils.deleteAllTransaction()
//            QueryUtils.deleteAllBudgets()
//            QueryUtils.deleteAllEvents()
////            DbController.shared.clearDatabase {
//                let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
//                let dest = storyboard.instantiateViewController(withIdentifier: "LandingViewController")
//                dest.modalPresentationStyle = .fullScreen
//                self.present(dest, animated: true, completion: nil)
////            }
//
//
//
//        }))
//
//        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onExportExcelTapped (sender : UITapGestureRecognizer) {
        exportDB()
    }
    
    @objc func onBackupTapped (sender : UITapGestureRecognizer) {
        let dest = getStoryboard(name: ViewIdentifiers.SB_SETTINGS).instantiateViewController(withIdentifier: ViewIdentifiers.VC_BACKUP)
        self.navigationController?.pushViewController(dest, animated: true)
    }
    
    @IBAction func onDecimalPlaceTapped (sender : UITapGestureRecognizer) {
        let decimalDialog = DialogDecimalPlace()
        decimalDialog.myDelegate = self
        self.presentPopupView(popupView: decimalDialog)
    }
    
    @IBAction func onSecuritySwitchTapped(_ sender: Any) {
        if !switch_security.isOn {
            LocalPrefs.setPasscode(passcode: nil)
            UIUtils.showSnackbar(message: "Passcode turned off")
        } else {
            navigateToPasscodeVC()
        }
    }
    
    @IBAction func onCurrencyTapped (sender : UITapGestureRecognizer) {
        self.isCurrencyTapped = true
        if LocalPrefs.getIsTravelMode() {
            let alert = UIAlertController(title: "Warning", message: "Your travel mode is turned on. In order to change currency, you have to turn off your travel mode.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "TURN OFF", style: UIAlertAction.Style.default, handler: {action in
                LocalPrefs.setIsTravelMode(isTravelModeOn: false)
                LocalPrefs.setTravelModeDetails(travelModeDetails: [:])
                self.navigateToCurrencyVC(countryOption: false)
            }))
            
            alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            navigateToCurrencyVC(countryOption: false)
        }
    }
    
    @objc func onSecurityTapped (sender : UITapGestureRecognizer) {
        navigateToPasscodeVC()
    }
    
    @objc func onCountryTapped (sender : UITapGestureRecognizer) {
        isCurrencyTapped = false
        navigateToCurrencyVC(countryOption: true)
    }
    
    @objc func onLogoutTapped (sender : UITapGestureRecognizer) {
        print("Logout Tapped")
        if BackupAlertView.isSyncing{
            UIUtils.showSnackbarNegative(message: "Syncing in progress")
        } else {
            if let destination = self.getStoryboard(name: ViewIdentifiers.SB_BACKUP).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SKIP_MESSAGE) as? SkipRestoreMessage{
                destination.logout = true
                destination.modalPresentationStyle = .overCurrentContext
                present(destination, animated: true, completion: nil)
            }
        }
        
    }
    
    func navigateToCurrencyVC (countryOption: Bool) {
        let currencyVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SELECT_CURRENCY) as! AccountCurrencyViewController
        currencyVC.myDelegate = self
        currencyVC.isCountryOpted = countryOption
        self.navigationController?.pushViewController(currencyVC, animated: true)
    }
    
    
    func onFormatUpdated(format: Int) {
        label_format.text = String(format)
        DispatchQueue.main.async {
            UIUtils.showSnackbar(message: "Format updated successfully")
        }
    }
    
    func onCurrencySelected(currency: String, country2dg: String, currencyFlag: String , countryName : String , decimal : Int) {
        
        if isCurrencyTapped {
            let flagURL = URL(string : currencyFlag)
            label_currency.text = currency
            iv_currency_flag.kf.setImage(with: flagURL)
            LocalPrefs.setUserCurrency(userCurrency: currency)
            LocalPrefs.setCurrencyFlag(currencyFlag: currencyFlag)
            LocalPrefs.setDecimalFormat(decimalFormat: decimal)
//            updateCurrencyNetworkCall()
            
            DispatchQueue.main.async {
                UIUtils.showSnackbar(message: "Currency updated successfully")
            }
        } else {
            let flagURL = URL(string : currencyFlag)
            LocalPrefs.setCountryFlag(countryFlag: currencyFlag)
            LocalPrefs.setCountryName(countryName: country2dg)
            self.iv_country_flag.kf.setImage(with: flagURL)
            self.label_country_name.text = country2dg
//            updateCountryNetworkCall(countryCode: country2dg, countryName: countryName, countryFlag: currencyFlag)
            DispatchQueue.main.async {
                UIUtils.showSnackbar(message: "Country updated successfully")
            }
        }
    }
    
    func exportDB() {
        let exportedString = createExportString()
        saveAndExport(exportString: exportedString)
    }
    
    func saveAndExport (exportString : String) {
        let date = Utils.currentDateReminderFormat(date: Date())
        let trimmedDate = date.replacingOccurrences(of: " ", with: ",")
        print("TRIM DATE : " , trimmedDate)
        let exportFilePath = NSTemporaryDirectory() + "HysabKytab-Data-\(trimmedDate).csv"
        let exportFileURL = URL(string : exportFilePath)
        FileManager.default.createFile(atPath: exportFilePath, contents: NSData() as Data, attributes: nil)
        var fileHandle : FileHandle? = nil
        
        do {
            fileHandle = try FileHandle(forWritingTo: exportFileURL as! URL)
        } catch {
            print("Error with fileHandle" , error)
        }
        
        if fileHandle != nil {
            fileHandle!.seekToEndOfFile()
            let csvData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            fileHandle!.write(csvData!)
            
            fileHandle!.closeFile()
            
            let firstActivityItem = NSURL(fileURLWithPath: exportFilePath)
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [firstActivityItem], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
            ]
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func createExportString () -> String {
        
        var vchAmount : Double?
        var description : String?
        var date : String?
        var categoryName : String?
        var place : String = ""
        var fcrate = ""
        var eventId = ""
        var currency = ""
        var eventName = ""
        var hkb_category : Hkb_category?
        var export : String = NSLocalizedString("ACTIVITIES \n Voucher Amount , Voucher Desc , Voucher Date , Voucher Type , Category Name , Account Name , Place , Fc Amount , Fc Rate , Event Id , Base Currency , Event Name \n", comment: "")
        
        for (index , items) in vouchersArray.enumerated() {
            vchAmount = items.vch_amount
            description = items.vch_description?.replacingOccurrences(of: ",", with: " ")
            let vchType = items.vch_type
            let fcamount = items.fcamount
            
            if items.fcrate != nil {
                fcrate = items.fcrate!
            }
            
            if items.flex1 != nil && items.flex1 != "Select place" {
                place = items.flex1!.replacingOccurrences(of: ",", with: " ")
            }
            
            if items.vch_type != "Transfer" {
                hkb_category = QueryUtils.fetchSingleCategory(categoryId: Int64(items.category_id))
                categoryName = hkb_category!.title
            } else {
                categoryName = ""
            }
            
            if items.eventid != nil {
                eventId = String(items.eventid)
            }
            
            if items.vchcurrency != nil {
                currency = items.vchcurrency!
            }
            
            if items.eventname != nil {
                eventName = items.eventname!.replacingOccurrences(of: ",", with: " ")
            }
            
            guard let hkb_account = QueryUtils.fetchSingleAccount(accountId: Int64(items.account_id)) as Hkb_account? else {
                return ""
            }
            let accountName = hkb_account.title!.replacingOccurrences(of: ",", with: " ")
            date = items.created_on
            export += "\(vchAmount!) , \(description!) , \(date!) , \(vchType!) , \(categoryName!) , \(accountName) , \(place) , \(fcamount) , \(fcrate) , \(eventId) , \(currency) , \(eventName) \n"
        }
        
        export += " \n ACCOUNTS \n Title , Opening Balance \n"
        
        for (index , items) in accountsArray.enumerated() {
            let accountTitle = (accountsArray[index].title)!.replacingOccurrences(of: ",", with: " ")
            export += "\(accountTitle) , \(accountsArray[index].openingbalance) \n"
        }
        
        export += " \n CATEGORIES \n Title , Type , Balance  \n"
        
        var catType = "Expense"
        

        for (index , items) in categoriesArray.enumerated() {
            print(index)
            let categoryTitle = (items.title)!.replacingOccurrences(of: ",", with: " ")
            let categoryBalance = ActivitiesDbUtils.getCategoryBalance(categoryId: items.categoryId , month : "" , year : 0)
            if items.is_expense == 0 {
                catType = "Income"
            } else {
                catType = "Expense"
            }

            export += "\(categoryTitle) , \(catType) , \(categoryBalance) \n"
        }
        
        return export
    }
    
   
    
//    private func updateCurrencyNetworkCall () {
//        let url = "http://api.hysabkytab.app/api/v3/index.php/updatecurrency"
//        var params : [String : String]?
//
//        params = [ "user_id" : String(LocalPrefs.getConsumerId()),
//                   "currency_code" : LocalPrefs.getUserCurrency()]
//
//        let randString = Utils.getRandomString(size: 20)
//        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
//        let headers : [String : String] = ["MAC" : sha256,
//                                           "random" : randString]
//
//        Alamofire.request(url, method: .put, parameters: params!, encoding: URLEncoding.httpBody , headers : headers)
//            .responseString { response in
//                switch response.result {
//                case .success:
////                    guard let objc = response.result.value else { return }
////                    let responseObj = JSON(response.result.value)
//
//                    UIUtils.showSnackbar(message: "Currency updated successfully")
//
//                case .failure(let error):
//                    print(error)
//                    UIUtils.showSnackbarNegative(message: error.localizedDescription)
//                    print("FAILURE")
//                }
//        }
//    }
//
//    private func updateCountryNetworkCall (countryCode: String, countryName: String, countryFlag: String) {
//        let url = "http://api.hysabkytab.app/api/v3/index.php/update/consumer/country"
//        var params : [String : String]?
//
//        params = [ "branch_id" : LocalPrefs.getUserData()["branch_id"]!,
//                   "country_code" : countryCode,
//                   "country_name" : countryName]
//
//        let randString = Utils.getRandomString(size: 20)
//        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
//        let headers : [String : String] = ["MAC" : sha256,
//                                           "random" : randString]
//
//        Alamofire.request(url, method: .post, parameters: params!, encoding: URLEncoding.httpBody , headers : headers)
//            .responseString { response in
//                switch response.result {
//                case .success:
//
//                    UIUtils.showSnackbar(message: "Country updated successfully")
//
//                case .failure(let error):
//                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
//                }
//        }
//    }
}
