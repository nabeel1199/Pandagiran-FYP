

import UIKit
import Alamofire
import SwiftyJSON
import FirebaseAnalytics
import CoreData

class AccountBalanceViewController: BaseViewController {

    @IBOutlet weak var label_account_name: CustomFontLabel!
    @IBOutlet weak var label_set_balance: UILabel!
    @IBOutlet weak var view_receivable_payable: UIView!
    @IBOutlet weak var text_field_amount: AmountEnterTextField!
    @IBOutlet weak var text_field_account_name: AmountEnterTextField!
    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var btn_positive_balance: UIButton!
    @IBOutlet weak var btn_negative_balance: UIButton!
    @IBOutlet weak var btn_add_account: GradientButton!
  
    
    public var accountType: String = ""
    public var accountName: String = ""
    public var editAccount: Hkb_account?
    public var accountIcon: String = ""
    private var isPositiveBalance = true
    public var bankName = ""
    
    override func viewDidLoad() {

        initVariables()
        populateEditAccount()
        initUI()
    }
    
    private func initVariables () {
        text_field_amount.delegate = self
//        text_field_account_name.delegate = self
    }
    
    private func initUI () {
        if editAccount != nil {
            btn_add_account.setTitle("SAVE CHANGES", for: .normal)
            self.navigationItem.title = "Edit \(self.accountType) Account"
        } else {
            btn_add_account.setTitle("ADD \(self.accountType.uppercased())", for: .normal)
            self.navigationItem.title = "Add \(accountType) Account"
        }
        
        label_account_name.text = "Your Account Name"
        self.navigationItemColor = .light
        
        btn_positive_balance.tintColor = UIColor().hexCode(hex: Style.color.PRIMARY_COLOR)
        btn_negative_balance.tintColor = UIColor().hexCode(hex: Style.color.PRIMARY_COLOR)
        label_currency.text = LocalPrefs.getUserCurrency()
        
        if accountType == "Person" {
                label_account_name.text = "Person Name"
            btn_positive_balance.setTitle("Receivable", for: .normal)
            btn_negative_balance.setTitle("Payable", for: .normal)
        } else {
            btn_positive_balance.setTitle("Positive", for: .normal)
            btn_negative_balance.setTitle("Negative", for: .normal)
        }
        
        text_field_account_name.text = accountName
        
    }
    
    private func populateEditAccount () {
        if let account = editAccount {
            self.accountName = account.title!
            self.accountIcon = account.boxicon!
            
            if account.acctype != nil {
                self.accountType = account.acctype!
            } else {
                self.accountType = ""
            }
            
            if account.bank_name != nil {
                self.bankName = account.bank_name!
            } else {
                self.bankName = ""
            }
    
            
            btn_add_account.setTitle("UPDATE", for: .normal)
            text_field_account_name.text = account.title!
            text_field_amount.text = Utils.formatDecimalNumber(number: account.openingbalance, decimal: LocalPrefs.getDecimalFormat())
            
            if account.openingbalance >= 0 {
                label_currency.text = LocalPrefs.getUserCurrency()
                isPositiveBalance = true
                btn_positive_balance.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
                btn_negative_balance.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
            } else {
                label_currency.text = "\(LocalPrefs.getUserCurrency()) -"
                isPositiveBalance = false
                btn_positive_balance.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
                btn_negative_balance.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
            }
            
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onCloseTapped))
        }
    }
    
    func accountDetails (account : Hkb_account) -> Hkb_account {
        let openingBalance = Utils.removeComma(numberString: text_field_amount.text!)
//        let maxAccountId = QueryUtils.getMaxAccountId()
        let maxAccountId = Utils.getUniqueId()
        account.title = text_field_account_name.text
        account.active = 1
        account.acctype = accountType
        account.account_currency = LocalPrefs.getUserCurrency()
        account.boxicon = "#00000"
        
        if account.acctype == "Bank" {
            account.boxicon = accountIcon
            account.bank_name = self.bankName
        } else if account.acctype == "Cash" {
            account.boxicon = "bt_87"
        } else if account.acctype == "Person" {
            account.boxicon = "ic_person"
        } else {
            account.boxicon = "bt_12"
        }
        
        if isPositiveBalance {
            account.openingbalance = abs(openingBalance)
        } else {
            account.openingbalance = abs(openingBalance) * -1
        }
        
        if editAccount != nil {
            account.account_id = (editAccount!.account_id)
            return account
        } else {
            account.account_id = Int64(maxAccountId + 1)
            return account
        }
        
    }
    
    // Saving account in db
    @objc func saveAccount() {

        if Utils.validateString(vc: self, string: text_field_account_name.text!, errorMsg: "Please enter account title") {
            
            var accountId: Int64 = 0
            if editAccount != nil {
                accountId = editAccount!.account_id
            }
            
            let existingAccount = QueryUtils.fetchAccountByName(nameString: (text_field_account_name.text)!, accountId: accountId)
            
            if existingAccount == nil  {
                if editAccount != nil {
                    let accountData = accountDetails(account: editAccount!)
                    if QueryUtils.getAccountSync(accountId: accountData.account_id) == 1{
                        postAccountToServer(account: accountData, isUpdate: true)
                    } else {
                        accountData.is_synced = 0
                        DbController.saveContext()
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                    
                } else  {
                    let newAccount : Hkb_account = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_ACCOUNT, into: DbController.getContext()) as! Hkb_account
                    let accountData = accountDetails(account: newAccount)
//                    if QueryUtils.getAccountSync(accountId: accountData.account_id) == 1{
                        postAccountToServer(account: accountData, isUpdate: false)
//                    } else {
//                        accountData.is_synced = 0
//                        DbController.saveContext()
//                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
//                    }
                    
                }
                
                DbController.saveContext()
                UIUtils.showSnackbar(message: "Account added successfully!")
                Analytics.logEvent("account_created", parameters: [:])
                self.dismiss(animated: true, completion: nil)
            } else {
                UIUtils.showAlert(vc: self, message: "Oops, looks like you had already created account with this title before. Use unique name to create a new account or simply add e.g. \(text_field_account_name.text ?? "") 1 or \(text_field_account_name.text ?? "") ABC")
//                UIUtils.showSnackbarNegative(message: "This account already exists")
            }
        }
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
    
    @IBAction func onPositiveBalanceTapped(_ sender: Any) {
        label_currency.text = LocalPrefs.getUserCurrency()
        isPositiveBalance = true
        btn_positive_balance.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
        btn_negative_balance.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
    }
    
    @IBAction func onNegativeBalanceTapped(_ sender: Any) {
        label_currency.text = "\(LocalPrefs.getUserCurrency()) -"
        isPositiveBalance = false
        btn_positive_balance.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
        btn_negative_balance.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
    }

    
    @IBAction func onChangeCurrencyTapped(_ sender: Any) {
        let changeCurrencyVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SELECT_CURRENCY) as! AccountCurrencyViewController
        self.navigationController?.pushViewController(changeCurrencyVC, animated: true)
    }
    
    @IBAction func onAddAccountTapped(_ sender: Any) {
        self.saveAccount()
    }
    
    @objc private func onCloseTapped () {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AccountBalanceViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case text_field_account_name:
            text_field_amount.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
}
