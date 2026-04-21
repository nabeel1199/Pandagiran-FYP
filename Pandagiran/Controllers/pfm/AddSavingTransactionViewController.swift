

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class AddSavingTransactionViewController: BaseViewController {

    @IBOutlet weak var view_date: CardView!
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var text_field_amount: UITextField!
    @IBOutlet weak var collection_view_accounts: UICollectionView!
    
    private let nibAccountName = "CategoryCell"
    private var arrayOfAccounts : Array<Hkb_account> = []
    private var vchDate = ""
    private var accountId:Int64 = 0
    private var accountName = ""
    private var shouldSetupView = false
    public var goaleditTrx : Hkb_goal_trx?
    public var goalId: Int64 = 0

    
    
    override func viewDidLoad() {
        
        initVariables()
        initUI()
        fetchAccounts(accountType: ["Cash", "Bank"])
    }
    

    override func viewDidAppear(_ animated: Bool) {
        if shouldSetupView {
            fetchAccounts(accountType: ["Cash", "Bank"])
        }
    }
    
    private func initVariables () {
        let date = Date()
        vchDate = Utils.currentDateDbFormat(date: date)
        label_date.text = Utils.currentDateUserFormat(date: date)
        
        initNibs()
        
        collection_view_accounts.delegate = self
        collection_view_accounts.dataSource = self
    }
    
    private func initUI () {
        label_currency.text = LocalPrefs.getUserCurrency()
        self.navigationItemColor = .light
        
        let dateTapGest = UITapGestureRecognizer(target: self, action: #selector(onDateTapped))
        view_date.addGestureRecognizer(dateTapGest)
    }
    
    private func initNibs () {
        let nibAccount = UINib(nibName: nibAccountName, bundle: nil)
        collection_view_accounts.register(nibAccount, forCellWithReuseIdentifier: nibAccountName)
    }
    
    private func fetchAccounts (accountType: [String]) {
        self.arrayOfAccounts.removeAll()
        arrayOfAccounts = QueryUtils.fetchAccounts(accountType: accountType)
        self.collection_view_accounts.reloadData()
        
    }
    
    private func fetchSavingTrxDetails (goalTrx: Hkb_goal_trx, voucher1: Hkb_voucher, voucher2: Hkb_voucher, isUpdate: Bool)  {
        
//        let firstVchId = QueryUtils.getMaxVoucherId() + 1
        let firstVchId = Utils.getUniqueId()
        let secondVchId = firstVchId + 1
        let vchAmount = Utils.removeComma(numberString: text_field_amount.text!)
        let (savingAccount, isAccountCreated) = SavingDbUtils.fetchSavingAccount()
        
        goalTrx.accountid = savingAccount.account_id
        goalTrx.active = 1
        goalTrx.amount = vchAmount
        goalTrx.goalid = Int64(self.goalId)
        goalTrx.trxdate = vchDate
        goalTrx.trxday = String(Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "day"))
        goalTrx.trxmonth = String(Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "month"))
        goalTrx.trxyear = String(Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "year"))
        
        if goaleditTrx == nil {
//            goalTrx.voucherId = Int64(QueryUtils.getMaxSavingVchId() + 1)
            goalTrx.voucherId = Utils.getUniqueId()
            goalTrx.hkbvchid = Int64(firstVchId)
        }
        
        voucher1.account_id = Int64(accountId)
        voucher1.active = 1
        voucher1.vch_no = "1"
        voucher1.vch_date = vchDate
        voucher1.flex1 = ""
        voucher1.vch_amount = (vchAmount * -1)
        voucher1.vch_day = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "day")
        voucher1.vch_year = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "year")
        voucher1.month = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "month")
        voucher1.vch_type = Constants.TRANSFER
        voucher1.fccurrency = ""
        voucher1.vch_description = ""
        voucher1.categoryname = ""
        voucher1.accountname = self.accountName
        voucher1.vchcurrency = LocalPrefs.getUserCurrency()
        voucher1.use_case = "Savings"
        
        voucher2.account_id = Int64(savingAccount.account_id)
        voucher2.active = 1
        voucher2.vch_no = "0"
        voucher2.vch_date = vchDate
        voucher2.flex1 = ""
        voucher2.accountname = savingAccount.title ?? "Savings"
        voucher2.vch_amount = vchAmount
        voucher2.vch_day = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "day")
        voucher2.vch_year = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "year")
        voucher2.month = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "month")
        voucher2.vch_type = Constants.TRANSFER
        voucher1.categoryname = ""
        voucher2.fccurrency = ""
        voucher2.vch_description = ""
        voucher2.vchcurrency = LocalPrefs.getUserCurrency()
        voucher2.use_case = "Savings"
        
        if goaleditTrx != nil {
            voucher1.updated_on = Utils.currentDateDbFormat(date: Date())
            voucher2.updated_on = Utils.currentDateDbFormat(date: Date())
        } else {
            voucher1.voucher_id = Int64(firstVchId)
            voucher1.ref_no = String(secondVchId)
            voucher1.created_on = Utils.currentDateDbFormat(date: Date())
            voucher2.created_on = Utils.currentDateDbFormat(date: Date())
            voucher2.voucher_id = Int64(secondVchId)
            voucher2.ref_no = String(firstVchId)
        }
        
        DbController.saveContext()
        let activityNetwork = VoucherNetworkCalls()
        let savingNetwork = SavingNetworkCalls()
        
        if (!isAccountCreated) {
            if QueryUtils.getAccountSync(accountId: voucher1.account_id) == 1 && QueryUtils.getGoalSync(goalId: goalTrx.goalid) == 1 {
                activityNetwork.postVoucher(voucher: voucher1, voucher2: voucher2, isUpdate: isUpdate)
                savingNetwork.postSavingTrxToServer(goalTrx: goalTrx, isUpdate: isUpdate)
                
            } else {
                goalTrx.is_synced = 0
                voucher1.is_synced = 0
                voucher2.is_synced = 0
                DbController.saveContext()
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
//                self.dismiss(animated: true, completion: nil)
            }
            
        }

    }
    
    
    private func saveGoalTransaction () {
        if let goal = goaleditTrx {
            
        } else {
            let goalTrx : Hkb_goal_trx = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_SAVING_TRX, into: DbController.getContext()) as! Hkb_goal_trx
            let voucher1 : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
            let voucher2 : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
            fetchSavingTrxDetails(goalTrx: goalTrx, voucher1: voucher1, voucher2: voucher2, isUpdate: false)
        }
    }
    
    @objc private func onDateTapped () {
        let datePopup = DialogSelectDate()
        datePopup.myDelegate = self
        self.presentPopupView(popupView: datePopup)
    }
    
    @IBAction func onAddSavingTransactionTapped(_ sender: Any) {
        if Utils.validateAmount(vc: self, amount: Utils.removeComma(numberString: text_field_amount.text!), errorMsg: "Please enter the amount") && Utils.validateInt(vc: self, intValue: accountId, errorMsg: "Please select the account") {
            
            saveGoalTransaction()
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    private func navigateToAddAccount () {
        let addAccountVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_ACCOUNT) as! AddAccountViewController
        let navController = UINavigationController(rootViewController: addAccountVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    

}

extension AddSavingTransactionViewController: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfAccounts.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibAccountName, for: indexPath) as! CategoryCell
        
        if indexPath.row == arrayOfAccounts.count {
            cell.categoryImage.image = UIImage(named: "ic_add")
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
            cell.contentView.layer.borderWidth = 1.0
            cell.category_title.text = "Add Account"
        } else {
            cell.cellType = "Account"
            cell.configureAccountsWithItemCells(account: arrayOfAccounts[indexPath.row])
        }
        
      
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            navigateToAddAccount()
            self.shouldSetupView = true
        } else {
            self.accountId = arrayOfAccounts[indexPath.row].account_id
            self.accountName = arrayOfAccounts[indexPath.row].title!
            let cell = collection_view_accounts.cellForItem(at: indexPath) as! CategoryCell
            cell.isSelected = true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = collection_view_accounts.cellForItem(at: indexPath) as! CategoryCell
        cell.isSelected = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collection_view_accounts.frame.size.width / 3
        let height : CGFloat = 80
        return CGSize(width: width, height: height)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationItemColor = .dark
    }
}

extension AddSavingTransactionViewController: DateSelectionListener {
    func onDateSelected(date: Date) {
        
        label_date.text = Utils.currentDateUserFormat(date: date)
        vchDate = Utils.currentDateDbFormat(date: date)
        
    }

}
