

import UIKit
import DropDown
import CoreData
import Alamofire
import SwiftyJSON

protocol AccountDeletionListener {
    func onAccountDeleted ()
}

class DeleteAccountPopup: BasePopup {

    @IBOutlet weak var label_transfer_type: UILabel!
    @IBOutlet weak var label_transfer: UILabel!
    @IBOutlet weak var label_popup_msg: UILabel!
    @IBOutlet weak var label_account: UILabel!
    @IBOutlet weak var btn_delete: GradientButton!
    @IBOutlet weak var table_view_accounts_height: NSLayoutConstraint!
    @IBOutlet weak var table_view_accounts: UITableView!
    @IBOutlet weak var view_account_list: UIView!
    @IBOutlet weak var view_select_account: CardView!
    @IBOutlet weak var popup_view: CardView!
    
    private let nibSelectionName = "CategorySelectionViewCell"
    private var arrayOfAccounts : Array<Hkb_account> = []
    private let dropDown = DropDown()
    private var selectedAccountId = 0
    
    public var accountId: Int64 = 0
    public var delegate : AccountDeletionListener?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        initVariables()
        fetchActiveAccounts()
        initUI()
        
    }

    
    private func initVariables () {
        table_view_accounts.delegate = self
        table_view_accounts.dataSource = self
        
        initNibs()
    }
    
    private func initUI () {
        btn_delete.backgroundColor = UIColor.lightGray
        
        
        let account = QueryUtils.fetchSingleAccount(accountId: Int64(accountId))
        let balance = ActivitiesDbUtils.getAccountBalance(accountID: accountId) + (account?.openingbalance ?? 0)
        var balanceMsg = ""
        
        if balance > 0 {
            balanceMsg = "Since your current balance is not 0, please transfer your positive balance to any active account before you can permanently delete it."
            label_transfer_type.text = "Transfer To :"
        } else {
            balanceMsg = "Since your current balance is not 0, please transfer the required amount from any active account before you can permanently delete it."
            label_transfer_type.text = "Transfer From :"
        }
    
        
        let popupMsg = NSMutableAttributedString(string: "Note: \(balanceMsg)")
        popupMsg.setColorForText(textForAttribute: "Note:", withColor: UIColor.red)
        label_popup_msg.attributedText = popupMsg

        let accountTapGest = UITapGestureRecognizer(target: self, action: #selector(onSelectTapped))
        view_select_account.addGestureRecognizer(accountTapGest)
        
        dropDown.anchorView = view_select_account
        dropDown.dataSource = getDropDownDataSource()
        
        
    }
    
    private func initNibs () {
        let nibAccountSelection = UINib(nibName: nibSelectionName, bundle: nil)
        table_view_accounts.register(nibAccountSelection, forCellReuseIdentifier: nibSelectionName)
    }
    
    private func getDropDownDataSource () -> Array<String> {
        var arrayOfAccounts : [String] = []
        
        for account in self.arrayOfAccounts {
            arrayOfAccounts.append(account.title!)
        }
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let account = self.arrayOfAccounts[index]
            self.selectedAccountId = Int(account.account_id)
            self.label_account.text = account.title!
            self.btn_delete.backgroundColor = .red
        }

        
        return arrayOfAccounts
    }
    
    private func fetchActiveAccounts () {
        arrayOfAccounts = QueryUtils.fetchAccounts(accountType: [], accountId: self.accountId)
        
        if arrayOfAccounts.count > 0 {
            view_account_list.isHidden = false
        }
    }
    
    @objc private func onSelectTapped () {
        dropDown.bottomOffset = CGPoint(x: 0, y: view_select_account.bounds.height)
        dropDown.show()
    }

    @IBAction func onDeleteTapped(_ sender: Any) {
        if selectedAccountId != 0 {
            let account = QueryUtils.fetchSingleAccount(accountId: Int64(accountId))
            let selectedAccount = QueryUtils.fetchSingleAccount(accountId: Int64(selectedAccountId))
            let vchDate = Utils.currentDateDbFormat(date: Date())
            let vchAmount = ActivitiesDbUtils.getAccountBalance(accountID: accountId) + (account?.openingbalance ?? 0)
            let voucher1 : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
            let voucher2 : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
            
            let firstVoucherId : Int64 = Utils.getUniqueId()
            let secondVoucherId : Int64 = Utils.getUniqueId()
            
            voucher1.active = 1
            voucher1.vch_no = "1"
            voucher1.vch_date = vchDate
            voucher1.flex1 = ""
            voucher1.vch_description = "Transfer for Account Deletion"
            voucher1.vch_day = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "day")
            voucher1.vch_year = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "year")
            voucher1.month = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "month")
            voucher1.vch_type = Constants.TRANSFER
            voucher1.tag = ""
            voucher1.categoryname = ""
            voucher1.fcrate = ""
            voucher1.eventname = ""
            voucher1.fccurrency = ""
            voucher1.vch_image = ""
            voucher1.vchcurrency = LocalPrefs.getUserCurrency()
            voucher1.use_case = "Transfer"
            voucher1.updated_on = vchDate
            voucher1.voucher_id = Int64(firstVoucherId)
            voucher1.ref_no = String(secondVoucherId)
            voucher1.created_on = vchDate
            
            voucher2.active = 1
            voucher2.vch_no = "0"
            voucher2.vch_date = vchDate
            voucher2.flex1 = ""
            voucher2.vch_description = "Transfer for Account Deletion"
            voucher2.vch_day = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "day")
            voucher2.vch_year = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "year")
            voucher2.month = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "month")
            voucher2.vch_type = Constants.TRANSFER
            voucher2.tag = ""
            voucher2.categoryname = ""
            voucher2.eventname = ""
            voucher2.fcrate = ""
            voucher2.fccurrency = ""
            voucher2.vch_image = ""
            voucher2.vchcurrency = LocalPrefs.getUserCurrency()
            voucher2.use_case = "Transfer"
            voucher2.updated_on = vchDate
            voucher2.created_on = vchDate
            voucher2.voucher_id = Int64(secondVoucherId)
            voucher2.ref_no = String(firstVoucherId)
            
            if vchAmount > 0 {
                voucher1.account_id = Int64(accountId)
                voucher1.accountname = account?.title ?? Constants.NULL_TEXT
                voucher1.vch_amount = (vchAmount * -1)
                voucher2.vch_amount = abs(vchAmount)
                voucher2.account_id = Int64(selectedAccountId)
                voucher2.accountname = selectedAccount?.title ?? Constants.NULL_TEXT
            } else {
                voucher1.account_id = Int64(selectedAccountId)
                voucher1.accountname = selectedAccount?.title!
                voucher1.vch_amount = vchAmount
                voucher2.vch_amount = abs(vchAmount)
                voucher2.account_id = Int64(accountId)
                voucher2.accountname = account?.title ?? Constants.NULL_TEXT
            }
            
            account?.active = 2
            if QueryUtils.getAccountSync(accountId: account!.account_id) == 1{
                DbController.saveContext()
                postAccountToServer(account: account!, isUpdate: true)
                VoucherNetworkCalls.sharedInstance.postVoucher(voucher: voucher1, voucher2: voucher2, isUpdate: true)
            } else {
                account?.is_synced = 0
                DbController.saveContext()
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            }
            
            delegate?.onAccountDeleted()
            DbController.saveContext()
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            UIUtils.showSnackbarNegative(message: "Please select account")
        }
    }
    
    @IBAction func onDismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
}


extension DeleteAccountPopup : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibSelectionName, for: indexPath) as! CategorySelectionViewCell
        
        let account = arrayOfAccounts[indexPath.row]
        cell.label_category.text = account.title!
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let account = arrayOfAccounts[indexPath.row]
        self.accountId = account.account_id
        label_account.text = account.title!
        btn_delete.backgroundColor = .red
        
        UIView.animate(withDuration: 0.3) {
            self.view_account_list.alpha = 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        table_view_accounts_height.constant = tableView.contentSize.height
    }
    
    
}
