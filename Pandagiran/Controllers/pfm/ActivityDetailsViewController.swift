

import UIKit
import XLPagerTabStrip
import Alamofire
import SwiftyJSON

class ActivityDetailsViewController: BaseViewController {
    
    @IBOutlet weak var label_balance: CustomFontLabel!
    @IBOutlet weak var scroll_view: UIScrollView!
    @IBOutlet weak var iv_filter: TintedImageView!
    @IBOutlet weak var label_filter_count: UILabel!
    @IBOutlet weak var view_sort: UIView!
    @IBOutlet weak var label_transactions: CustomFontLabel!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var view_breakdown: UIView!
    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var label_receive: UILabel!
    @IBOutlet weak var label_pay: UILabel!
    @IBOutlet weak var label_borrow: UILabel!
    @IBOutlet weak var label_lend: UILabel!
    @IBOutlet weak var view_receive: UIView!
    @IBOutlet weak var view_pay: UIView!
    @IBOutlet weak var view_borrow: UIView!
    @IBOutlet weak var view_lend: UIView!
    @IBOutlet weak var stack_view: UIStackView!
    @IBOutlet weak var breakDownHeight: NSLayoutConstraint!
    @IBOutlet weak var label_sort_filter: UILabel!
    @IBOutlet weak var label_filter: UILabel!
    @IBOutlet weak var label_sort: UILabel!
    @IBOutlet weak var label_breakdown: UILabel!
    @IBOutlet weak var label_add: UILabel!
    @IBOutlet weak var view_scollable: UIView!
    @IBOutlet weak var view_filter: CardView!
    @IBOutlet weak var view_sort_filter: GradientView!
    @IBOutlet weak var view_breakdown_amount: CardView!
    @IBOutlet weak var viewFilterHeight: NSLayoutConstraint!
    @IBOutlet weak var breakDownAmountHeight: NSLayoutConstraint!
    @IBOutlet weak var transactionTableHeight: NSLayoutConstraint!
    @IBOutlet weak var table_view_transactions: UITableView!
    @IBOutlet weak var view_add: CardView!
    @IBOutlet weak var label_breakdown_amount: UILabel!
    @IBOutlet weak var collection_view_breakdown: UICollectionView!
    
    private let nibAccountName = "BankLandingViewCell"
    private let nibTransactionName = "TransactionViewCell"
    private let nibCategoryBreakdownName = "CategoryBreakdownViewCell"
    private var openingBalance: Double?
    private var closingBalance: Double?
    private var didFinishLoading = false
    private var hasViewLoaded = false
    private var offset = 0
    private let limit = 20
    private var isDelete = false
    
    public var sortBy = "date"
    public var isAscending = false
    public var amountRange = ""
    public var breakdownType = ""
    public var categoryId: Int64 = 0
    public var accountId: Int64 = 0
    public var vchType = ""
    public var tabTitle = ""
    public var accountType = ""
    public var intervalIndex = 0
    public var eventId: Int64 = 0
    public var passedInterval = LocalPrefs.getCurrentInterval()
    public var month : String = ""
    public var year = 0
    public var arrayOfVouchers : Array<Hkb_voucher> = []

    

    override func viewWillAppear(_ animated: Bool) {
        
        arrayOfVouchers.removeAll()
        offset = 0
//        initUI()
        fetchTransactions()
        fetchAccountOrBudgetLedger()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
//        fetchAccountOrBudgetLedger()
        
    }
    
    
    private func initVariables () {
        initNibs()
        
        view_filter.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        scroll_view.delegate = self
        
        table_view_transactions.delegate = self
        table_view_transactions.dataSource = self
        
        collection_view_breakdown.delegate = self
        collection_view_breakdown.dataSource = self
        
    
        
    }
    
    private func initUI () {
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.title = "Transaction History"

        viewFilterHeight.constant = 0
        view_sort_filter.isHidden = true
        
        table_view_transactions.rowHeight = UITableView.automaticDimension
        table_view_transactions.estimatedRowHeight = 120
        
        let layout = collection_view_breakdown.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: collection_view_breakdown.bounds.width - 40, height: 180)
        
        let viewLandTap = UITapGestureRecognizer(target: self, action: #selector(onLendTapped))
        view_lend.addGestureRecognizer(viewLandTap)
        
        let viewBorrowTap = UITapGestureRecognizer(target: self, action: #selector(onBorrowTapped))
        view_borrow.addGestureRecognizer(viewBorrowTap)
        
        let viewPayTap = UITapGestureRecognizer(target: self, action: #selector(onPayTapped))
        view_pay.addGestureRecognizer(viewPayTap)
        
        let viewReceiveTap = UITapGestureRecognizer(target: self, action: #selector(onReceiveTapped))
        view_receive.addGestureRecognizer(viewReceiveTap)
        
        let tapFilterGest = UITapGestureRecognizer(target: self, action: #selector(onFilterTapped))
        view_filter.addGestureRecognizer(tapFilterGest)
        
        let sortTapGest = UITapGestureRecognizer(target: self, action: #selector(onSortTapped))
        view_sort.addGestureRecognizer(sortTapGest)


        
        label_breakdown_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_sort_filter.regularFont(fontStyle: .regular, size: Style.dimen.SMALL_TEXT)
        label_transactions.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
    }
    
    private func fetchAccountOrBudgetLedger () {
        if accountId != 0
        {
            collection_view_breakdown.reloadData()
            view_filter.isHidden = true
            view_sort.isHidden = true
            
            let account = QueryUtils.fetchSingleAccount(accountId: Int64(accountId))
            self.navigationItem.title = account?.title ?? Constants.NULL_TEXT
            
            if account?.acctype != "Person" {
                breakDownHeight.constant = breakDownHeight.constant - stackViewHeight.constant
                stackViewHeight.constant = 0
                stack_view.isHidden = true
            }
        }
        else if categoryId != 0
        {
            collection_view_breakdown.reloadData()
            view_filter.isHidden = true
            view_sort.isHidden = true
            
            let category = QueryUtils.fetchSingleCategory(categoryId: Int64(categoryId))
            self.navigationItem.title = category?.title ?? Constants.NULL_TEXT
            breakDownHeight.constant = breakDownHeight.constant - stackViewHeight.constant
            stackViewHeight.constant = 0
            stack_view.isHidden = true
        }
        else
        {
            label_breakdown_amount.isHidden = true
            breakDownHeight.constant = 50
            view_breakdown.isHidden = true
            stack_view.isHidden = true
            collection_view_breakdown.isHidden = true
        }
        
    }
    
    private func initNibs () {
        let nibTransaction = UINib(nibName: nibTransactionName, bundle: nil)
        let nibAccount = UINib(nibName: nibAccountName, bundle: nil)
        let nibCategoryBreakdown = UINib(nibName: nibCategoryBreakdownName, bundle: nil)
        
        collection_view_breakdown.register(nibCategoryBreakdown, forCellWithReuseIdentifier: nibCategoryBreakdownName)
        collection_view_breakdown.register(nibAccount, forCellWithReuseIdentifier: nibAccountName)
        table_view_transactions.register(nibTransaction, forCellReuseIdentifier: nibTransactionName)
    }
    
    private func showPlaceholder () {
        if arrayOfVouchers.count == 0 {
            view_placeholder.isHidden = false
        } else {
            view_placeholder.isHidden = true
        }
    }
    
    private func fetchTransactions () {
        let vouchers = ActivitiesDbUtils.fetchFilteredVouchers(accountId: accountId,
                                                               categoryId: categoryId,
                                                               eventId: eventId,
                                                               type: vchType,
                                                               amountRange: self.amountRange,
                                                               currentInterval: passedInterval,
                                                               month: month,
                                                               year: year,
                                                               sortBy: sortBy,
                                                               isAscending: isAscending,
                                                               offset: offset,
                                                               limit: limit)
        arrayOfVouchers.append(contentsOf: vouchers)
        
        let inflow = ActivitiesDbUtils.fetchInflowAndOutflow(type: "Inflow", vchType: "", accountID: accountId, categoryID: categoryId, currentInterval: passedInterval, month: month, year: year)
        let outflow = ActivitiesDbUtils.fetchInflowAndOutflow(type: "Outflow", vchType: "", accountID: accountId, categoryID: categoryId, currentInterval: passedInterval, month: month, year: year)
        let balance = inflow - abs(outflow)
        
        if vchType == Constants.EXPENSE {
            label_balance.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: outflow, decimal: LocalPrefs.getDecimalFormat()))"
        } else if vchType == Constants.INCOME {
            label_balance.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: inflow, decimal: LocalPrefs.getDecimalFormat()))"
        } else {
            label_balance.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: balance, decimal: LocalPrefs.getDecimalFormat()))"
        }
    
        
        
        offset += limit
        
        self.table_view_transactions.reloadData()
        showPlaceholder()
    }
    
    private func fetchOpeningBalance (accountId: Int64, categoryId: Int64) -> Double {
        var sum1 : Double = 0
        
        if passedInterval.lowercased() != Constants.YEARLY.lowercased() && passedInterval.lowercased() != Constants.ALL_TIME.lowercased() {
            sum1 = ActivitiesDbUtils.getOpeningBalance(accountId: accountId, categoryId: categoryId, type: "", firstValue: true , currentInterval: passedInterval, month: month, year: year)
        }
        
        let sum2 = ActivitiesDbUtils.getOpeningBalance(accountId: accountId, categoryId: categoryId, type: "" ,firstValue: false , currentInterval: passedInterval, month: "12", year: year)
        
        return (sum1 + sum2)
    }
    
    private func navigateToTransactionVC (useCaseType: String) {
        let transactionVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: "TransactionLoggingVC") as! TransactionLoggingViewController
        transactionVC.vchType = Constants.TRANSFER
        transactionVC.useCaseType = useCaseType
        transactionVC.accountType = "Person"
        let navController = UINavigationController()
        navController.viewControllers = [transactionVC]
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc private func onFilterTapped () {
        let filterVC = getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FILTER) as! ActivityFilterViewController
        filterVC.delegate = self
        filterVC.accountId = self.accountId
        filterVC.categoryId = self.categoryId
        filterVC.vchType = self.vchType
        filterVC.amountRange = self.amountRange
        filterVC.eventId = self.eventId
        self.navigationController?.pushViewController(filterVC, animated: true)
    }
    
    @objc private func onSearchTapped () {
        let navController = UINavigationController()
        let searchVC = getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SEARCH_ACTIVITY) as! SearchActivityViewController
        navController.viewControllers = [searchVC]
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc private func onShareTapped () {
        let text = "This is some text that I want to share."
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
        
        
    }
    
    @objc private func onAddTapped () {
        hasViewLoaded = false
        let transactionVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: ViewIdentifiers.VC_TRANSACTION_LOGGING) as! TransactionLoggingViewController
        let navController = UINavigationController()
        navController.viewControllers = [transactionVC]
        self.present(navController, animated: true, completion: nil)
    }
    
    
    @objc private func onSortTapped () {
        let sortPopup = SortPopup()
        sortPopup.delegate = self
        self.presentPopupView(popupView: sortPopup)
    }
    
    @objc private func onLendTapped () {
        hasViewLoaded = false
        navigateToTransactionVC(useCaseType: "Lend")
    }
    
    @objc private func onBorrowTapped () {
        hasViewLoaded = false
        navigateToTransactionVC(useCaseType: "Borrow")
    }
    
    @objc private func onPayTapped () {
        hasViewLoaded = false
        navigateToTransactionVC(useCaseType: "Pay")
    }
    
    @objc private func onReceiveTapped () {
        hasViewLoaded = false
        navigateToTransactionVC(useCaseType: "Receive")
    }

    private func postBudgetToServer (budget: Hkb_budget, isUpdate : Bool) {
        let budgetDic = Utils.convertVchIntoDict(object: budget)
        let budgetJson = Utils.convertDictIntoJson(object: budgetDic)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        var URL = "\(Constants.BASE_URL)/budget/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        var httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt : [String:Any] =  ["budgets" : budgetJson,
                                             "device_type" : "Ios",
                                             "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        if isUpdate {
            URL = "\(Constants.BASE_URL)/budget/update"
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
                    let message = responseObj["message"].stringValue
                    print("ResponseStatus : " , status,  message)
                    if status == 1 {
                        
                            budget.is_synced = 1
                        DbController.saveContext()
                    } else {
                        budget.is_synced = 0
                        DbController.saveContext()
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                    
                    
                case .failure(let error):
                    budget.is_synced = 0
                    DbController.saveContext()
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
//                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
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
}


extension ActivityDetailsViewController: FilterAppliedListener, SortSelectionListener {
    
    func onSortApplied(sortTitle: String, sortType: String, isAscending: Bool, sortIntType: Int) {
        arrayOfVouchers.removeAll()
        self.offset = 0
        label_sort.text = sortTitle
        self.sortBy = sortType
        self.isAscending = isAscending
        fetchTransactions()
    }
    
    func onFilterApplied(categoryId: Int64, accountId: Int64, eventId: Int64, vchType: String, filterParams: String, amountRange: String, count : Int) {
        
        arrayOfVouchers.removeAll()
        offset = 0
        
        if count > 0 {
            view_filter.backgroundColor = UIColor.white
            iv_filter.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            label_filter_count.text = "\(count)"
            label_filter.isHidden = false
            self.accountId = accountId
            self.categoryId = categoryId
            self.vchType = vchType
            self.eventId = eventId
            self.amountRange = amountRange
            fetchTransactions()
        } else {
            view_filter.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            iv_filter.tintColor = UIColor.white
            label_filter.isHidden = true
            self.amountRange = ""
            self.accountId = 0
            self.categoryId = 0
            self.eventId = 0
            self.vchType = ""
            fetchTransactions()
        }
    }
}

extension ActivityDetailsViewController : UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabTitle)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        
        self.transactionTableHeight.constant = table_view_transactions.contentSize.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfVouchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibTransactionName, for: indexPath) as! TransactionViewCell
        
        cell.configureWithItem(accountId: accountId, voucher: arrayOfVouchers[indexPath.row])
        
        viewWillLayoutSubviews()
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let voucher = arrayOfVouchers[indexPath.row]
        
        if voucher.use_case != "Savings" && voucher.vch_description != "Transfer for Account Deletion"{
            let transactionVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: ViewIdentifiers.VC_TRANSACTION_DETAILS) as! TransactionDetailsViewController
            transactionVC.viewVoucher = voucher
            transactionVC.showViewMode = true
            self.navigationController?.pushViewController(transactionVC, animated: true)
        } else if voucher.vch_description == "Transfer for Account Deletion" {
            UIUtils.showAlert(vc: self, message: "System created transactions can not be modify")
        } else {
            UIUtils.showAlert(vc: self, message: "Saving transactions can only be modified from savings module")
        }
    }
}

extension ActivityDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, GenericPopupSelection {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if accountId != 0 || categoryId != 0 {
            return 1
        } else {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if accountId != 0 {
            let cell = collection_view_breakdown.dequeueReusableCell(withReuseIdentifier: nibAccountName, for: indexPath) as! BankLandingViewCell
            
            cell.cellType = "BankBreakdown"
            cell.label_available_balance.isHidden = true
            
            
            if accountType == "Person" {
                cell.label_net_woth.text = "Pending debts"
            } else {
                cell.label_net_woth.text = "Available Balance"
            }
            
            
            if let account = QueryUtils.fetchSingleAccount(accountId: Int64(accountId)) {
                let accountOpening = account.openingbalance
                let openingBalance = fetchOpeningBalance(accountId: self.accountId, categoryId: 0) + accountOpening
                
                label_breakdown.text = "Opening balance for this period was \(Utils.formatDecimalNumber(number: openingBalance, decimal: LocalPrefs.getDecimalFormat()))"
                
                let inflowAmount = ActivitiesDbUtils.fetchInflowAndOutflow(type: "Inflow", vchType: self.vchType, accountID: accountId, categoryID: categoryId, currentInterval: passedInterval, month: month, year: year)
                
                let outflowAmount = ActivitiesDbUtils.fetchInflowAndOutflow(type: "Outflow", vchType: self.vchType, accountID: accountId, categoryID: categoryId, currentInterval: passedInterval, month: month, year: year)
                
                cell.configureAccountDetailsWithItem(account: account, inflow: inflowAmount, outflow: outflowAmount, opening: openingBalance)
                
                cell.btn_menu.tag = 1
                cell.btn_menu.addTarget(self, action: #selector(onBankCellMenuTapped), for: .touchUpInside)
            } else {
                cell.label_bank_name.text = "Something went wrong"
                cell.label_inflow_amount.text = "0"
                cell.label_outflow_amount.text = "0"
                cell.label_balance_amount.text = "0"
            }
            
            
            
            return cell
        } else  {
            let cell = collection_view_breakdown.dequeueReusableCell(withReuseIdentifier: nibCategoryBreakdownName, for: indexPath) as! CategoryBreakdownViewCell
            
            let openingBalance = fetchOpeningBalance(accountId: 0, categoryId: self.categoryId)
             label_breakdown.text = "Opening balance for this period was \(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: openingBalance, decimal: LocalPrefs.getDecimalFormat()))"
            
            if let category = QueryUtils.fetchSingleCategory(categoryId: Int64(categoryId)){
                cell.configureCategoryDetailsWithItem(category: category, passedInterval: passedInterval, month: month, year: year)
                
                cell.btn_menu.tag = 0
                cell.btn_menu.addTarget(self, action: #selector(onCategoryMenuTapped), for: .touchUpInside)
            } else {
                cell.label_category.text = "Something went worng"
            }
            
            
            return cell
        }
    }
    
    @objc private func onBankCellMenuTapped(sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let account = QueryUtils.fetchSingleAccount(accountId: Int64(self.accountId))
        
        if account?.title != "Savings" {
            
            alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: {action in
                
                let navController = UINavigationController()
                let editAccountVC = self.getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACCOUNT_BALANCE) as! AccountBalanceViewController
                editAccountVC.editAccount = account
                navController.viewControllers = [editAccountVC]
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {action in
                let balance = ActivitiesDbUtils.getAccountBalance(accountID: account?.account_id ?? 0) + Double(account?.openingbalance ?? 0)
                
                if balance == 0 {
                    self.isDelete = true
                    let genericPopup = GenericPopup()
                    genericPopup.delegate = self
                    genericPopup.popupTitle = "Delete this account?"
                    genericPopup.message = "This will permanently delete the account, all transactions made from this account will remain visible in history."
                    genericPopup.btnText = "DELETE"
                    genericPopup.objectIndex = 1
                    self.presentPopupView(popupView: genericPopup)
                } else {
                    let deletePopup = DeleteAccountPopup()
                    deletePopup.accountId = account?.account_id ?? 0
                    deletePopup.delegate = self
                    self.presentPopupView(popupView: deletePopup)
                }
                
                
            }))
        }
        
        var activateTitle = "Activate"
        
        if account?.active == 1 {
            activateTitle = "Deactivate"
        }
        
        alert.addAction(UIAlertAction(title: activateTitle, style:  .default, handler: {action in
            
            if account?.active == 1 {
                self.isDelete = false
                let genericPopup = GenericPopup()
                genericPopup.delegate = self
                genericPopup.popupTitle = "Deactivate Account?"
                genericPopup.message = "This will deactivate the account but the past transactions made from this account will remain visible in your history."
                genericPopup.btnText = "DEACTIVATE"
                genericPopup.objectIndex = sender.tag
                self.presentPopupView(popupView: genericPopup)
            } else {
                account?.active = 1
                if QueryUtils.getAccountSync(accountId: account!.account_id) == 1 {
                    self.postAccountToServer(account: account!, isUpdate: true)
                } else {
                    
                    account?.is_synced = 0
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                }
                DbController.saveContext()
                UIUtils.showSnackbar(message: "Account Activated")
                self.collection_view_breakdown.reloadData()
            }
            
        }))
      
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func onCategoryMenuTapped (sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: {action in
            if let budget = BudgetDbUtils.fetchSingleBudget(categoryId: self.categoryId, month: Int(self.month)!, year: self.year) {
                let addBudgetVC = self.getStoryboard(name: ViewIdentifiers.SB_BUDGET).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_BUDGET) as! AddBudgetViewController
                addBudgetVC.editBudget = budget
                addBudgetVC.budgetMonth = Int(self.month)!
                addBudgetVC.categoryId = self.categoryId
                let navController = UINavigationController()
                navController.viewControllers = [addBudgetVC]
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }

        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: {action in
            self.isDelete = true
            let genericPopup = GenericPopup()
            genericPopup.delegate = self
            genericPopup.popupTitle = "Delete Budget"
            genericPopup.message = "Are you sure you want to delete this budget?"
            genericPopup.btnText = "DELETE BUDGET"
            genericPopup.objectIndex = 0
            self.presentPopupView(popupView: genericPopup)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onButtonTapped(index: Int, objectIndex: Int) {
        // object index will be 0 for category and 1 for account
        if objectIndex == 0 {
            if let budget = BudgetDbUtils.fetchSingleBudget(categoryId: self.categoryId, month: Int(month)!, year: self.year) {
//                DbController.getContext().delete(budget)
                budget.active = 0
                if QueryUtils.getBudgetSync(budget_id: budget.budget_id) == 1 && QueryUtils.getCategorySync(categoryId: budget.categoryid) == 1 {
                    self.postBudgetToServer(budget: budget, isUpdate: true)
                } else {
                    budget.is_synced = 0
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                }
                
                DbController.saveContext()
                
                UIUtils.showSnackbar(message: "Budget deleted successfully")
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            let account = QueryUtils.fetchSingleAccount(accountId: Int64(self.accountId))
            
            if isDelete {
                account?.active = 2
                
                if QueryUtils.getAccountSync(accountId: account!.account_id) == 1 {
                    self.postAccountToServer(account: account!, isUpdate: true)
                } else {
                    
                    account?.is_synced = 0
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                }
                DbController.saveContext()
                UIUtils.showSnackbar(message: "Account Deleted")
                self.navigationController?.popViewController(animated: true)
            } else {
                account?.active = 0
                if QueryUtils.getAccountSync(accountId: account!.account_id) == 1 {
                    self.postAccountToServer(account: account!, isUpdate: true)
                } else {
                    
                    account?.is_synced = 0
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                }
                DbController.saveContext()
                UIUtils.showSnackbar(message: "Account Deactivated")
                self.collection_view_breakdown.reloadData()
            }
            
      
        }
    }
}

extension ActivityDetailsViewController : UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if ((scroll_view.contentOffset.y + (scroll_view.frame.size.height)) >= self.table_view_transactions.contentSize.height) {
            
            fetchTransactions()
        }
    }
}

extension ActivityDetailsViewController : AccountDeletionListener {
    
    func onAccountDeleted() {
        UIUtils.showSnackbar(message: "Account deleted successfully")
        self.navigationController?.popViewController(animated: true)
    }
    
    
}



