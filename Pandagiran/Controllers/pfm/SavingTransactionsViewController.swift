
import UIKit
import Alamofire
import SwiftyJSON

class SavingTransactionsViewController: BaseViewController {
    
    @IBOutlet weak var progress_view: UIProgressView!
    @IBOutlet weak var iv_goal: UIImageView!
    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var label_recent_transactions: CustomFontLabel!
    @IBOutlet weak var label_add: UILabel!
    @IBOutlet weak var label_percent_amount: UILabel!
    @IBOutlet weak var label_total_amount: UILabel!
    @IBOutlet weak var label_saved_amount: UILabel!
    @IBOutlet weak var label_saved: UILabel!
    @IBOutlet weak var label_goal_title: UILabel!
    @IBOutlet weak var label_target_date: UILabel!
    @IBOutlet weak var view_add_saving_transaction: CardView!
    @IBOutlet weak var savingTransactionsHeight: NSLayoutConstraint!
    @IBOutlet weak var table_view_saving_transactions: UITableView!
    
    
    private let nibSavingTransactionName = "TransactionViewCell"
    private var arrayOfVouchers : Array<Hkb_goal_trx> = []
    private var isGoalAcheive = true
    
    public var savingGoal : Hkb_goal?
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchGoalTransactions(goalId: savingGoal?.goalId ?? 0)
        fetchSavingGoalDetails()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_saving_transactions.delegate = self
        table_view_saving_transactions.dataSource = self
        
        let addSavingTapGest = UITapGestureRecognizer(target: self, action: #selector(onAddSavingTransactionTapped))
        view_add_saving_transaction.addGestureRecognizer(addSavingTapGest)
    }
    
    private func initUI () {
        progress_view.layer.masksToBounds = false
        progress_view.layer.cornerRadius = 10
        
        table_view_saving_transactions.rowHeight = UITableView.automaticDimension
        table_view_saving_transactions.estimatedRowHeight = 100
    }
    
    private func initNibs () {
        let nibSavingTransaction = UINib(nibName: nibSavingTransactionName, bundle: nil)
        table_view_saving_transactions.register(nibSavingTransaction, forCellReuseIdentifier: nibSavingTransactionName)
    }
    
    private func fetchSavingGoalDetails () {
        if let goal = savingGoal {
            self.navigationItem.title = "Goal: \(goal.title!)"
            let goalDate = Utils.convertStringToDate(dateString: goal.targetenddate!)
            let decimal = LocalPrefs.getDecimalFormat()
            let currency = LocalPrefs.getUserCurrency()
            let totalAmount = goal.amount
            let savedAmount = SavingDbUtils.fetchSavedAmount(goalId: Int(goal.goalId))
            let percentAmount: Double = (savedAmount / totalAmount) * 100
            let progressValue = savedAmount / totalAmount
            
            iv_goal.image = UIImage(named: (savingGoal?.flex2)!)
            label_goal_title.text = goal.title!
            label_target_date.text = "Target Date: \(Utils.currentDateUserFormat(date: goalDate))"
            label_total_amount.text = "/\(Utils.formatDecimalNumber(number: totalAmount, decimal: decimal))"
            label_saved_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: savedAmount, decimal: decimal))"
            label_percent_amount.text = "\(round(percentAmount))%"
            progress_view.setProgress(Float(progressValue), animated: true)
            
        }
    }
    
    private func showPlaceholder () {
        if arrayOfVouchers.count == 0 {
            view_placeholder.isHidden = false
        } else {
            view_placeholder.isHidden = true
        }
    }
    
    private func fetchGoalTransactions (goalId : Int64) {
        arrayOfVouchers.removeAll()
        arrayOfVouchers = SavingDbUtils.fetchSavingTransactions(goalId: goalId)
        self.table_view_saving_transactions.reloadData()
        showPlaceholder()
    }
    
    @IBAction func onBtnMenuTapped(_ sender: Any) {
    }
    
    
    @objc private func onAddSavingTransactionTapped() {
        let addSavingTransaction = getStoryboard(name: ViewIdentifiers.SB_SAVING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_SAVING_TRANSACTION) as! AddSavingTransactionViewController
        addSavingTransaction.goalId = Int64(self.savingGoal?.goalId ?? 0)
        self.navigationController?.pushViewController(addSavingTransaction, animated: true)
    }
    
    @IBAction func onGoalAcheiveTapped(_ sender: Any) {
        let goalAcheievePopup = GenericPopup()
        goalAcheievePopup.delegate = self
        goalAcheievePopup.message = "Are you you want to set the goal as acheived?"
        goalAcheievePopup.popupTitle = "GOAL"
        goalAcheievePopup.btnText = "SET AS ACHEIVED"
        self.presentPopupView(popupView: goalAcheievePopup)
    }
    
    private func postGoalToServer (goal : Hkb_goal, isUpdate : Bool) {
        let goalDetails = Utils.convertVchIntoDict(object: goal)
        let goalsJson = Utils.convertDictIntoJson(object: goalDetails)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        var URL = "\(Constants.BASE_URL)/saving/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        var httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["savings" : goalsJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        if isUpdate {
            URL = "\(Constants.BASE_URL)/saving/update"
            httpMethod = Alamofire.HTTPMethod.post
        }
        
        Alamofire.request(URL, method: httpMethod, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue

                    if status == 1 {
                            goal.is_synced = 1
                        
                    } else {
                        goal.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                    
                    DbController.saveContext()
                    
                case .failure(let error):
                    goal.is_synced = 0
                    DbController.saveContext()
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
//                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
}

extension SavingTransactionsViewController: UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfVouchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibSavingTransactionName, for: indexPath) as! TransactionViewCell
        
        let goalTitle = savingGoal?.title ?? Constants.NULL_TEXT
        cell.configureSavingTransactionWithItem(savingTrx: arrayOfVouchers[indexPath.row], goalTitle: goalTitle)
        print(goalTitle)
        print(arrayOfVouchers[indexPath.row])
        
        cell.btn_menu.addTarget(self, action: #selector(onMenuBtnTapped), for: .touchUpInside)
        cell.btn_menu.tag = indexPath.row

        savingTransactionsHeight.constant = tableView.contentSize.height
        cell.selectionStyle = .none
        return cell
    }
    
    @IBAction func onMenuBtnTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
       
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: {action in
            self.isGoalAcheive = false
            let deletePopup = GenericPopup()
            deletePopup.delegate = self
            deletePopup.btnText = "DELETE TRANSACTION"
            deletePopup.popupTitle = "DELETE TRANSACTION"
            deletePopup.message = "Are you sure you want to delete this transaction?"
            deletePopup.objectIndex = sender.tag
            self.presentPopupView(popupView: deletePopup)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension SavingTransactionsViewController : GenericPopupSelection {
    
    func onButtonTapped(index: Int, objectIndex: Int) {
        if isGoalAcheive {
            let currentDate = Date()
            savingGoal?.actualenddate = Utils.currentDateDbFormat(date: currentDate)
            DbController.saveContext()
            postGoalToServer(goal: savingGoal!, isUpdate: true)
            self.navigationController?.popViewController(animated: true)
        } else {
            let savingVch = arrayOfVouchers[objectIndex]
            
            if let voucher = QueryUtils.fetchSingleVoucher(voucherId: Int64(savingVch.hkbvchid)) {
                
                savingVch.active = 0
                voucher.active = 0
                if voucher.ref_no != nil && voucher.ref_no != "" {
                    if let voucher2 = QueryUtils.fetchSingleVoucher(voucherId: Int64(voucher.ref_no!)!) {
                        voucher2.active = 0
                        if savingVch.is_synced == 1{
                            VoucherNetworkCalls.sharedInstance.postVoucher(voucher: voucher, voucher2: voucher2, isUpdate: true)
                            SavingNetworkCalls.sharedInstance.postSavingTrxToServer(goalTrx: savingVch, isUpdate: true)
                        } else {
                            savingVch.is_synced = 0
                            DbController.saveContext()
                            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                        }
                        DbController.saveContext()
                    }
                } else {
                    if savingVch.is_synced == 1{
                        VoucherNetworkCalls.sharedInstance.postVoucher(voucher: voucher, voucher2: nil, isUpdate: true)
                        SavingNetworkCalls.sharedInstance.postSavingTrxToServer(goalTrx: savingVch, isUpdate: true)
                    } else {
                        savingVch.is_synced = 0
                        DbController.saveContext()
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                }
            }
            DbController.saveContext()
            arrayOfVouchers.remove(at: objectIndex)
            self.table_view_saving_transactions.reloadData()
            fetchSavingGoalDetails()
        }
    }
}
