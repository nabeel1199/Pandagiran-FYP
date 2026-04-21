

import UIKit
import SwiftyJSON
import Alamofire

class AccountBalancesViewController: BaseViewController , UITableViewDataSource , UITableViewDelegate , AccountAddListener , GenericPopupSelection , AccountDeletionListener {
    
    @IBOutlet weak var view_all_accounts: CardView!
    @IBOutlet weak var label_outflow_amount: UILabel!
    @IBOutlet weak var label_inflow_amount: UILabel!
    @IBOutlet weak var label_available_balance: UILabel!
    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var label_net_balance: UILabel!
    
    var netBalance : Double!
    var accountsArray : Array<Hkb_account> = []
    let pinImage = UIImage(named : "ic_pin_account")?.withRenderingMode(.alwaysTemplate)
    let unpinImage = UIImage(named : "ic_unpin_account")?.withRenderingMode(.alwaysTemplate)
    let activitiesImage = UIImage(named : "drawer_icon")?.withRenderingMode(.alwaysTemplate)
    var sortedArray : Array<Hkb_account> = []
    private var isDelete = false
    
    public var month : String = String(Utils.getCurrentMonth())
    public var year : Int = Utils.getCurrentYear()
    public var passedInterval = Constants.ALL_TIME
    
    override func viewWillAppear(_ animated: Bool) {
      
        initVariables()
        fetchAccounts()
        initUI()
    }
    

    
    func initVariables() {
        
        table_view.delegate = self
        table_view.dataSource = self
        
        let nibAccountBalance = UINib (nibName : "AccountBalanceViewCell" , bundle : nil)
        table_view.register(nibAccountBalance, forCellReuseIdentifier: "AccountBalanceNib")
        
    }
    
    func initUI () {
        self.view_all_accounts.backgroundColor = UIColor(patternImage: UIImage(named: "bg_card")!)

        
        let inflowAmount = ActivitiesDbUtils.fetchInflowAndOutflow(type: "Inflow", vchType: "", accountID: 0, categoryID: 0, currentInterval: passedInterval, month: month, year: year)
         let outflowAmount = ActivitiesDbUtils.fetchInflowAndOutflow(type: "Outflow", vchType: "", accountID: 0, categoryID: 0, currentInterval: passedInterval, month: month, year: year)
        
        
        let allAccountsBalance = fetchAllAccountsBalance()
        label_net_balance.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: allAccountsBalance, decimal: LocalPrefs.getDecimalFormat()))"
        label_inflow_amount.text = "\(Utils.formatDecimalNumber(number: inflowAmount, decimal: LocalPrefs.getDecimalFormat()))"
        label_outflow_amount.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(outflowAmount), decimal: LocalPrefs.getDecimalFormat()))"
    
    }
    
    private func fetchAccounts () {
        accountsArray.removeAll()
        sortedArray.removeAll()
        accountsArray = QueryUtils.fetchAllAccounts()
        
        for i in 0 ..< accountsArray.count {
            accountsArray[i].balance_amount = ActivitiesDbUtils.getAccountBalance(accountID: accountsArray[i].account_id) + accountsArray[i].openingbalance
        }
        
        sortedArray = accountsArray.sorted { (obj1 , obj2) -> Bool in
            return Float(obj1.balance_amount) > Float(obj2.balance_amount)
        }
        
        table_view.reloadData()
    }

    private func postAccountToServer (account : Hkb_account, isUpdate : Bool) {
        let accountDetails = Utils.convertVchIntoDict(object: account)
        let accountJson = Utils.convertDictIntoJson(object: accountDetails)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        var URL = "\(Constants.BASE_URL)/account/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        var httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["accounts" : accountJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
//        if isUpdate {
//            URL = "\(Constants.BASE_URL)/account/update"
//            httpMethod = Alamofire.HTTPMethod.post
//        }
        
        Alamofire.request(URL, method: httpMethod, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    print("ResponseStatus : " , status,  message)
                    if status == 1 {
                    
                            account.is_synced = 1
                    } else {
                        account.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                    
                    DbController.saveContext()
                    
                case .failure(let error):
                    account.is_synced = 0
                    DbController.saveContext()
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
//                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    private func fetchAllAccountsBalance () -> Double {
        var sum : Double = 0
        
        for account in accountsArray {
            sum += ActivitiesDbUtils.getAccountBalance(accountID: account.account_id)
        }
        
        return sum + QueryUtils.fetchOpeningBalanceAllAccounts()
    }
    
    @objc func navigateToAddAccountVC() {
        let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
        let dest = storyboard.instantiateViewController(withIdentifier: "AddAccountVC") as! AddAccountViewController
//        dest.myDelegate = self
        navigationController?.pushViewController(dest, animated: true)
    }
    
    @objc private func onBackTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountBalanceNib", for: indexPath) as! AccountBalanceViewCell
        
        let account = sortedArray[indexPath.row]
        let accountBalance : Double = ActivitiesDbUtils.getAccountBalance(accountID: account.account_id) + account.openingbalance
        
        cell.tv_account_title.text = account.title
        cell.tv_account_balance.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: accountBalance, decimal: LocalPrefs.getDecimalFormat()))"
        
        if let type = account.acctype {
            if let boxIcon = account.boxicon {
                if type != "Bank" {
//                    let image = UIImage(named: boxIcon)?.withRenderingMode(.alwaysTemplate)
                    if let image = UIImage(named: boxIcon){
                        cell.image_account.image = image.withRenderingMode(.alwaysTemplate)
                    } else {
                        cell.image_account.image = UIImage(named: "accounts")?.withRenderingMode(.alwaysTemplate)
                    }
                    
                    cell.image_account.tintColor = UIColor.lightGray
                } else {
                    if let image = UIImage(named: boxIcon){
                        cell.image_account.image = image
                    } else {
                        cell.image_account.image = UIImage(named: "accounts")
                    }
//                    let image = UIImage(named: boxIcon)
//                    cell.image_account.image = image
                }
            }
        }
        

        if account.active == 1 {
            cell.label_inactive.isHidden = true
        } else {
            cell.label_inactive.isHidden = false
        }

        
        cell.btn_menu.tag = indexPath.row
        cell.btn_menu.addTarget(self, action: #selector(onMenuBtnTapped), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activitiesVC = getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACTIVITY_PAGE) as! ActivityPageViewController
        if let accountType = sortedArray[indexPath.row].acctype {
            activitiesVC.accountType = accountType
        }
        let intervalIndex = Utils.getInitialIntervalIndex(currentInterval: LocalPrefs.getCurrentInterval())
        activitiesVC.intervalIndex = intervalIndex
        activitiesVC.accountId = sortedArray[indexPath.row].account_id 
        self.navigationController?.pushViewController(activitiesVC, animated: true)
    }
    
    @IBAction func onMenuBtnTapped (_ sender: UIButton) {
        guard let viewRect = sender as? UIView else {
            return
        }
        
        var activateTitle = "Activate"
        
        let account = self.sortedArray[sender.tag]
        
        if account.active == 1 {
            activateTitle = "Deactivate"
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
    
        if account.title != "Savings" {
            alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: {action in
                
                let account = QueryUtils.fetchSingleAccount(accountId: Int64(account.account_id))
                let navController = UINavigationController()
                let editAccountVC = self.getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACCOUNT_BALANCE) as! AccountBalanceViewController
                editAccountVC.editAccount = account
                navController.viewControllers = [editAccountVC]
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {action in
                let balance = ActivitiesDbUtils.getAccountBalance(accountID: account.account_id) + account.openingbalance
                
                if balance == 0 {
                    self.isDelete = true
                    let genericPopup = GenericPopup()
                    genericPopup.delegate = self
                    genericPopup.popupTitle = "Delete this account?"
                    genericPopup.message = "This will permanently delete the account, all transactions made from this account will remain visible in history."
                    genericPopup.btnText = "DELETE"
                    genericPopup.objectIndex = sender.tag
                    self.presentPopupView(popupView: genericPopup)
                } else {
                    let deletePopup = DeleteAccountPopup()
                    deletePopup.accountId = account.account_id
                    deletePopup.delegate = self
                    self.presentPopupView(popupView: deletePopup)
                }
            }))
        }
       
        
        alert.addAction(UIAlertAction(title: activateTitle, style: UIAlertAction.Style.default, handler: {action in
            
            if account.active == 1 {
                self.isDelete = false
                let genericPopup = GenericPopup()
                genericPopup.delegate = self
                genericPopup.popupTitle = "Deactivate Account?"
                genericPopup.message = "This will deactivate the account but the past transactions made from this account will remain visible in your history."
                genericPopup.btnText = "DEACTIVATE"
                genericPopup.objectIndex = sender.tag
                self.presentPopupView(popupView: genericPopup)
            } else {
                
                account.active = 1
                DbController.saveContext()
                if QueryUtils.getAccountSync(accountId: account.account_id) == 1{
                    self.postAccountToServer(account: account, isUpdate: true)
                } else {
                    account.is_synced = 0
                    DbController.saveContext()
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                }
                
                self.fetchAccounts()
                self.table_view.reloadData()
            }
   
        }))
        
       
        
//        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {action in
//            self.isDelete = true
//            let genericPopup = GenericPopup()
//            genericPopup.delegate = self
//            genericPopup.popupTitle = "Delete Account?"
//            genericPopup.message = "TThis will permanently delete this account and any remaining balances will be excluded from your net worth. However, past transactions made from this account will remain visible in your history."
//            genericPopup.btnText = "DELETE"
//            genericPopup.objectIndex = sender.tag
//            self.presentPopupView(popupView: genericPopup)
//        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = viewRect;
            presenter.sourceRect = viewRect.bounds;
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func onAccountAdded() {
        accountsArray = QueryUtils.fetchAccounts(accountType: [])
        for i in 0 ..< accountsArray.count {
            accountsArray[i].balance_amount = ActivitiesDbUtils.getAccountBalance(accountID: accountsArray[i].account_id) + accountsArray[i].openingbalance
        }
        
        sortedArray = accountsArray.sorted { (obj1 , obj2) -> Bool in
            return Float(obj1.balance_amount) > Float(obj2.balance_amount)
        }
        table_view.reloadData()
    }
    
    func onButtonTapped(index: Int, objectIndex: Int) {
//        let account = self.sortedArray[objectIndex]
//        account.active = 0
//        DbController.saveContext()
//        let index = self.sortedArray.index(of: account)
//        self.sortedArray.remove(at: index!)
//        self.table_view.reloadData()
//        UIUtils.showSnackbar(message: "Account deleted successfully")
        
        let account = self.sortedArray[objectIndex]

        if isDelete {
            account.active = 2
        } else {
            account.active = 0
        }
        DbController.saveContext()
        if QueryUtils.getAccountSync(accountId: account.account_id) == 1 {
            self.postAccountToServer(account: account, isUpdate: true)
        } else {
            account.is_synced = 0
            DbController.saveContext()
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
        }
        
        self.fetchAccounts()
        self.table_view.reloadData()
    }
    
    func onAccountDeleted() {
        fetchAccounts()
    }
    
}
