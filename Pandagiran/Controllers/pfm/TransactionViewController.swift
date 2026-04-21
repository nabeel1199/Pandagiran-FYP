

import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import FirebaseAnalytics

class TransactionViewController: BaseViewController, TransactionAddAnotherListener {
 
    
    @IBOutlet weak var btn_finish: GradientButton!
    @IBOutlet weak var page_control_height: NSLayoutConstraint!
    @IBOutlet weak var page_control: UIPageControl!
    @IBOutlet weak var categoryCollectionLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var viewTravelHeight: NSLayoutConstraint!
    @IBOutlet weak var label_travel_conversion: UILabel!
    @IBOutlet weak var view_travel_mode: UIView!
    @IBOutlet weak var view_amount: GradientView!
    @IBOutlet weak var stack_view: UIStackView!
    @IBOutlet weak var view_pay_receive: GradientView!
    @IBOutlet weak var payReceiveHeight: NSLayoutConstraint!
    @IBOutlet weak var btn_receive_money: UIButton!
    @IBOutlet weak var btn_pay_money: UIButton!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var label_select_account: UILabel!
    @IBOutlet weak var label_select_category: UILabel!
    @IBOutlet weak var view_segment: CustomSegments!
    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var text_field_amount: AmountEnterTextField!
    @IBOutlet weak var collection_view_category: UICollectionView!
    @IBOutlet weak var collection_view_account: UICollectionView!
    @IBOutlet weak var categoryCollectionHeight: NSLayoutConstraint!
    
    private let nibCategoryName = "CategoryCell"
    private var arrayOfCategories : Array<Hkb_category> = []
    private var arrayOfAccountsFrom : Array<Hkb_account> = []
    private var arrayOfAccountsTo : Array<Hkb_account> = []
    private var shouldSetupView = false
    private var voucherNetworkManager : VoucherNetworkCalls!
    
    public var accountToName : String = ""
    public var accountId: Int64 = 0
    public var categoryId: Int64 = 0
    public var accountToId: Int64 = 0
    public var categoryName = ""
    public var accountName = ""
    public var vchAmount: Double = 0
    public var accountType = "ALL"
    public var isExpense = 0
    public var useCaseType = "Lend"
    
    public var vchType = "Expense" { // Receive this value from TransactionLogging
        didSet {
           setupView()
        }
    }
    
    public var editVoucher : Hkb_voucher? {
        didSet {
            voucherEdit()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if shouldSetupView {
            setupView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        
    }
    
    private func initVariables () {
        voucherNetworkManager = VoucherNetworkCalls()
        initNibs()
    }
    
    private func initUI () {
        text_field_amount.becomeFirstResponder()
        text_field_amount.attributedPlaceholder =
            NSAttributedString(string: "0", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        if editVoucher != nil {
            let navClosekIcon = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onCloseTapped))
            self.navigationItem.rightBarButtonItem = navClosekIcon
        }
        
        label_currency.text = LocalPrefs.getUserCurrency()
        
        label_select_category.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_select_account.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        
        btn_next.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_select_category.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_select_account.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        
        let viewAmountTap = UITapGestureRecognizer(target: self, action: #selector(onViewAmountTapped))
        view_amount.addGestureRecognizer(viewAmountTap)
    }
    
    private func setupView () {
        arrayOfAccountsTo.removeAll()
        arrayOfAccountsFrom.removeAll()
        arrayOfCategories.removeAll()
        
        payReceiveHeight?.constant = 0
        view_pay_receive?.isHidden = true
        
        if vchType == Constants.EXPENSE || vchType == Constants.INCOME {
            collection_view_category.isPagingEnabled = true
            page_control.isHidden = false
            page_control_height.constant = 30
            
            categoryCollectionLayout.minimumLineSpacing = 0
            categoryCollectionHeight.constant = 170
            
            
            let accountType = ["Bank", "Cash"]
            fetchCategories(categoryType: self.vchType)
            fetchAccountsTo(accountType: accountType)
            
            label_select_category?.text = "Select category"
            label_select_account?.text = "Select account"
            
            showTravelModeExtension()
            
            
            let noOfPages = (Float(arrayOfCategories.count) / 6).rounded(.up)
            page_control.numberOfPages = Int(noOfPages)
        }
        else if vchType == Constants.TRANSFER
        {
            collection_view_category.isPagingEnabled = false
            page_control.isHidden = true
            page_control_height.constant = 0
            
            categoryCollectionLayout.minimumLineSpacing = 10
            categoryCollectionHeight.constant = 80
            viewTravelHeight.constant = 0
            view_travel_mode.isHidden = true
            label_currency.text = LocalPrefs.getUserCurrency()
            
            label_select_category?.text = "From Account"
            label_select_account?.text = "To Account"
            
            if accountType == "Person" {
                view_pay_receive?.isHidden = false // show pay receive if accountType == Person
                payReceiveHeight?.constant = 50
                
                label_select_category?.text = "\(useCaseType) From"
                label_select_account?.text = "\(useCaseType) To"
                
                if useCaseType == "Lend" || useCaseType == "Pay" {
                    let accountFromType = ["Bank", "Cash"]
                    let accountToType = ["Person"]
                    fetchAccountsFrom(accountType: accountFromType)
                    fetchAccountsTo(accountType: accountToType)
                    
                    if useCaseType == "Lend" {
                        configureUseCaseSelection(selectedIndex: 0)
                        label_select_category.text = "From Account"
                        label_select_account?.text = "Lend To"
                    } else {
                        configureUseCaseSelection(selectedIndex: 2)
                    }
                    
                } else if useCaseType == "Borrow" || useCaseType == "Receive" {
                    let accountFromType =  ["Person"]
                    let accountToType = ["Bank","Cash"]
                    fetchAccountsFrom(accountType: accountFromType)
                    fetchAccountsTo(accountType: accountToType)
                    label_select_account?.text = "To Account"
                    
                    if useCaseType == "Borrow" {
                        configureUseCaseSelection(selectedIndex: 1)
                    } else {
                        configureUseCaseSelection(selectedIndex: 3)
                    }
                    
                }
            } else {
                 if useCaseType == "ATM" {
                    let accountFromType = ["Bank"]
                    let accountToType = ["Cash"]
                    fetchAccountsFrom(accountType: accountFromType)
                    fetchAccountsTo(accountType: accountToType)
                 } else {
                    fetchAccountsFrom(accountType: [])
                    fetchAccountsTo(accountType: [])
                }
            }
        }        
    }
    
    private func showTravelModeExtension () {
        if LocalPrefs.getIsTravelMode() {
            let startDateString = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_START_DATE]
            let endDateString = LocalPrefs.getTravelModeDetails() [Constants.TRAVEL_END_DATE]
            let startDate = Utils.convertStringToDate(dateString: startDateString!)
            let endDate = Utils.convertStringToDate(dateString: endDateString!)
            let conversionRate = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_CONVERSION_RATE]
            let travelCurrency = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_CURRENCY_TO]
            
            if Utils.isDateBetween(startDate, and: endDate, middleDate: Date()) {
                label_currency.text = travelCurrency
                view_travel_mode.isHidden = false
                viewTravelHeight.constant = 35
                label_travel_conversion.text = "1 \(travelCurrency!) = \(conversionRate!) \(LocalPrefs.getUserCurrency())"
            }
        }
    }
    
    private func voucherEdit () {
        if let voucher = editVoucher {
            btn_finish.isHidden = true
            setupView()
            
            self.navigationItem.title = "Edit Transaction"
            
            vchAmount = abs(voucher.vch_amount)
            text_field_amount.text = Utils.formatDecimalNumber(number: vchAmount, decimal: LocalPrefs.getDecimalFormat())
            
            
            if voucher.vch_type! == Constants.TRANSFER
            {
        
                accountId = voucher.account_id
                
                let account = QueryUtils.fetchSingleAccount(accountId: Int64(voucher.account_id))
                accountName = account?.title ?? Constants.NULL_TEXT
                if account != nil {
                    if let index = arrayOfAccountsFrom.index(of: account!) {
                        DispatchQueue.main.async {
                            self.collection_view_category.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: [.centeredHorizontally])
                        }
                    }
                }
               
                
                
                
                if let refNo = voucher.ref_no {
                    let voucherTo = QueryUtils.fetchSingleVoucher(voucherId: Int64(refNo)!)!
                    let accountTo = QueryUtils.fetchSingleAccount(accountId: Int64(voucherTo.account_id))
                    accountToId = voucherTo.account_id
                    accountToName = accountTo?.title ?? Constants.NULL_TEXT
                    if accountTo != nil {
                        if let index = arrayOfAccountsTo.index(of: accountTo!) {
                            DispatchQueue.main.async {
                                self.collection_view_account.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: [.centeredHorizontally])
                            }
                        }
                    }
                   
                }
            }
            else
            {
       

                let category = QueryUtils.fetchSingleCategory(categoryId: Int64(voucher.category_id))!
                if let catIndex = arrayOfCategories.index(of: category) {
                    DispatchQueue.main.async {
                        self.collection_view_category.selectItem(at: IndexPath(item: catIndex, section: 0), animated: true, scrollPosition: [.centeredHorizontally])
                    }
                }
          
                
                let account = QueryUtils.fetchSingleAccount(accountId: Int64(voucher.account_id))
                if let index = arrayOfAccountsTo.index(of: account!) {
                    DispatchQueue.main.async {
                        self.collection_view_account.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: [.centeredHorizontally])
                    }
                }
                
                categoryName = category.title!
                categoryId = voucher.category_id
                accountName = account?.title ?? Constants.NULL_TEXT
                accountId = voucher.account_id
                
                if voucher.travelmode == 1 {
                    text_field_amount.text = Utils.formatDecimalNumber(number: abs(voucher.fcamount), decimal: LocalPrefs.getDecimalFormat())
                }
            }
            
            
        }
    }
    
    private func configureUseCaseSelection (selectedIndex: Int) {
        for btn in stack_view.arrangedSubviews {
            let button = btn as! UIButton
            
            button.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
        }
        
        let selectedBtn = stack_view.arrangedSubviews[selectedIndex] as! UIButton
        selectedBtn.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
        selectedBtn.setTitleColor(UIColor().hexCode(hex: Style.color.PRIMARY_COLOR), for: .normal)
    }
    
    private func initNibs () {
        let nibCategory = UINib(nibName: nibCategoryName, bundle: nil)
        collection_view_category.register(nibCategory, forCellWithReuseIdentifier: nibCategoryName)
        collection_view_account.register(nibCategory, forCellWithReuseIdentifier: nibCategoryName)
        
        collection_view_category.delegate = self
        collection_view_category.dataSource = self
        
        collection_view_account.delegate = self
        collection_view_account.dataSource = self
    }
    
    private func navigateToTransactionDetails () {
        let transactionDetailsVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: ViewIdentifiers.VC_TRANSACTION_DETAILS) as! TransactionDetailsViewController
        transactionDetailsVC.addAnotherDelegate = self
        transactionDetailsVC.vchType = self.vchType
        transactionDetailsVC.accountId = self.accountId
        transactionDetailsVC.categoryId = self.categoryId
        transactionDetailsVC.accountToId = self.accountToId
        transactionDetailsVC.categoryName = self.categoryName
        transactionDetailsVC.accountToName = self.accountToName
        transactionDetailsVC.accountName = self.accountName
        transactionDetailsVC.useCaseType = self.useCaseType
        transactionDetailsVC.vchCurrency = label_currency.text!
        transactionDetailsVC.vchAmount = Utils.removeComma(numberString: text_field_amount.text!)
        
        if editVoucher != nil {
            transactionDetailsVC.editVoucher = editVoucher!
        }
        
        transactionDetailsVC.vchAmount = Utils.removeComma(numberString: text_field_amount.text!)
        self.navigationController?.pushViewController(transactionDetailsVC, animated: true)
    }
    
    private func fetchCategories (categoryType: String) {
        arrayOfCategories = QueryUtils.fetchCategories(type: categoryType)
        self.collection_view_category?.reloadData()
    }
    
    private func fetchAccountsFrom (accountType: [String]) {
        arrayOfAccountsFrom = QueryUtils.fetchAccounts(accountType: accountType)
        self.collection_view_category?.reloadData()
    }
    
    private func fetchAccountsTo (accountType: [String]) {
        arrayOfAccountsTo = QueryUtils.fetchAccounts(accountType: accountType)
        self.collection_view_account?.reloadData()
    }
    
    private func postTransferVoucherDetails (voucher1 : Hkb_voucher , voucher2 : Hkb_voucher, isUpdate: Bool) {
        vchAmount = Utils.removeComma(numberString: text_field_amount.text!)
        let vchDate = Utils.currentDateDbFormat(date: Date())
//        let maxVoucherId : Int = Int(QueryUtils.getMaxVoucherId() + 1)
        let voucher1Id : Int64 = Utils.getUniqueId()
        let voucher2Id : Int64 = Utils.getUniqueId()
        voucher1.account_id = accountId
        voucher1.active = 1
        voucher1.vch_no = "1"
        voucher1.vch_date = vchDate
        voucher1.flex1 = ""
        voucher1.vch_amount = (vchAmount * -1)
        voucher1.vch_description = ""
        voucher1.vch_day = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "day")
        voucher1.vch_year = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "year")
        voucher1.month = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "month")
        voucher1.vch_type = Constants.TRANSFER
        voucher1.tag = ""
        voucher1.categoryname = ""
        voucher1.fcrate = ""
        voucher1.eventid = 0
        voucher1.eventname = ""
        voucher1.fccurrency = ""
        voucher1.accountname = accountName
        voucher1.vch_image = ""
        voucher1.vchcurrency = LocalPrefs.getUserCurrency()
        voucher1.use_case = self.useCaseType
        
        
        voucher2.account_id = accountToId
        voucher2.active = 1
        voucher2.vch_no = "0"
        voucher2.vch_date = vchDate
        voucher2.flex1 = ""
        voucher2.accountname = accountToName
        voucher2.vch_amount = vchAmount
        voucher2.vch_description = ""
        voucher2.vch_day = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "day")
        voucher2.vch_year = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "year")
        voucher2.month = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "month")
        voucher2.vch_type = Constants.TRANSFER
        voucher2.tag = ""
        voucher2.categoryname = ""
        voucher2.eventid = 0
        voucher2.eventname = ""
        voucher2.fcrate = ""
        voucher2.fccurrency = ""
        voucher2.vch_image = ""
        voucher2.vchcurrency = LocalPrefs.getUserCurrency()
        voucher2.use_case = self.useCaseType
        
        if editVoucher != nil {
            voucher1.updated_on = Utils.currentDateDbFormat(date: Date())
            
            voucher2.updated_on = Utils.currentDateDbFormat(date: Date())
        } else {
            //For Voucher 1
            voucher1.voucher_id = voucher1Id
            //For Voucher 2
            voucher2.voucher_id = voucher2Id
            //For Voucher 1 reference value is voucher 2
            voucher1.ref_no = String(voucher2Id)
            //For Voucher 2 reference value is voucher 1
            voucher2.ref_no = String(voucher1Id)
            voucher1.created_on = Utils.currentDateDbFormat(date: Date())
            voucher2.created_on = Utils.currentDateDbFormat(date: Date())
//            voucher2.voucher_id = Int64(Int(QueryUtils.getMaxVoucherId() + 1))
            
        }
 
    
        var mobileNo = ""
        let email = LocalPrefs.getUserData()[Constants.EMAIL]!
        if let mobile = LocalPrefs.getUserData()[Constants.USER_PHONE] {
            mobileNo = mobile
        }
        
        let vchDetails : [String : String] = ["account name" : accountName ,
                                              "account_to" : accountToName ,
                                              "amount" : String(voucher1.vch_amount) ,
                                              "consumer_mobile" : mobileNo,
                                              "consumer_name" : LocalPrefs.getUserData()["user_name"]!,
                                              "consumer_email" : email,
                                              "currency" : LocalPrefs.getUserCurrency(),
                                              "place" : "",
                                              "place_type" : "",
                                              "trx_type" : "Transfer"]
        Analytics.logEvent("trx_added", parameters: vchDetails)
        if QueryUtils.getAccountSync(accountId: voucher1.account_id) == 1 && QueryUtils.getAccountSync(accountId: voucher2.account_id) == 1 {
            voucherNetworkManager.postVoucher(voucher: voucher1, voucher2: voucher2, isUpdate: false)
        } else {
            voucher1.is_synced = 0
            voucher2.is_synced = 0
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            
        }
        
        DbController.saveContext()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func postVoucherDetails(vch: Hkb_voucher, isUpdate: Bool) -> Void {
        vchAmount = Utils.removeComma(numberString: text_field_amount.text!)
        let vchDate = Utils.currentDateDbFormat(date: Date())
        let voucherDate = Utils.convertStringToDate(dateString: vchDate)
        vch.account_id = accountId
        vch.active = 1
        vch.vch_amount = vchAmount
        vch.category_id = categoryId
        vch.vch_no = "1"
        vch.month = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: Constants.MONTH)
        vch.vch_type = vchType
        vch.vch_date = vchDate
        vch.vch_year = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: Constants.YEAR)
        vch.vch_day = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: Constants.DAY)
        vch.vch_description = ""
        vch.vch_image = ""
        vch.flex3 = "0"
        vch.flex1 = ""
        vch.vchtrxplace = ""
        vch.accountname = accountName
        vch.categoryname = categoryName
        vch.tag = ""
        vch.eventid = 0
        vch.eventname = ""
        vch.ref_no = "1"
        vch.use_case = useCaseType
        vch.vchcurrency = LocalPrefs.getUserCurrency()
        
        if vchType == Constants.EXPENSE {
            vch.vch_amount = vch.vch_amount * -1
        }
        
        if editVoucher != nil && editVoucher?.travelmode == 1 {
            let conversionRate = editVoucher?.fcrate!
            vch.fcamount = vchAmount
            vch.vch_amount = vchAmount * (conversionRate! as NSString).doubleValue
            
            if vchType == Constants.EXPENSE {
                vch.vch_amount = (vchAmount * (conversionRate! as NSString).doubleValue) * -1
                vch.fcamount = vchAmount * -1
            } else {
                vch.fcamount = vchAmount
                vch.vch_amount = vchAmount * (conversionRate! as NSString).doubleValue
            }
        } else {
            if LocalPrefs.getIsTravelMode() {
                let startDateString = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_START_DATE]
                let endDateString = LocalPrefs.getTravelModeDetails() [Constants.TRAVEL_END_DATE]
                let startDate = Utils.convertStringToDate(dateString: startDateString!)
                let endDate = Utils.convertStringToDate(dateString: endDateString!)
                
                if Utils.isDateBetween(startDate, and: endDate, middleDate: voucherDate) {
                    let currencyTo = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_CURRENCY_TO]!
                    let conversionRate = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_CONVERSION_RATE]!
                    let travelPlace = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_TRAVEL_TO]!
                    vch.fcamount = vchAmount
                    vch.fccurrency = currencyTo
                    vch.fcrate = conversionRate
                    vch.vch_amount = vchAmount * (conversionRate as NSString).doubleValue
                    vch.travelmode = 1
                    vch.travelmodeplace = travelPlace
                    vch.travlemodelocation = "\(startDate)~\(endDate)"
                    
                    if vchType == Constants.EXPENSE {
                        vch.vch_amount = (vchAmount * (conversionRate as NSString).doubleValue) * -1
                        vch.fcamount = vchAmount * -1
                    } else {
                        vch.fcamount = vchAmount
                        vch.vch_amount = vchAmount * (conversionRate as NSString).doubleValue
                    }
                }
            }
        }
        
        if editVoucher != nil {
            vch.voucher_id = (editVoucher?.voucher_id)!
            vch.updated_on = vchDate
        } else {
//            vch.voucher_id = Int64(Int((QueryUtils.getMaxVoucherId() + 1)))
            vch.voucher_id = Utils.getUniqueId()
            vch.created_on = vchDate
        }

        var mobileNo = ""
        
        let email = LocalPrefs.getUserData()["email"]!
        if let mobile = LocalPrefs.getUserData()[Constants.USER_PHONE] {
            mobileNo = mobile
        }
        
        
        let vchDetails : [String : String] = ["account_name" : accountName,
                                              "amount" : String(vch.vch_amount),
                                              "category_name" : categoryName,
                                              "consumer_mobile" : mobileNo,
                                              "consumer_email" : email,
                                              "consumer_name" : LocalPrefs.getUserData()["user_name"]!,
                                              "currency" : LocalPrefs.getUserCurrency(),
                                              "place" : "",
                                              "place_type" : "",
                                              "trx_type" : vchType]
        Analytics.logEvent("trx_added", parameters: vchDetails)
        
        if QueryUtils.getAccountSync(accountId: vch.account_id) == 1 && QueryUtils.getCategorySync(categoryId: vch.category_id) == 1 {
            voucherNetworkManager.postVoucher(voucher: vch, voucher2: nil, isUpdate: false)
        } else {
            vch.is_synced = 0
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
        }
        
        DbController.saveContext()
//        self.notifyForBudgetProceed()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNextTapped(_ sender: Any) {
        if vchType == Constants.TRANSFER {
            if Utils.validateAmount(vc: self, amount: Utils.removeComma(numberString: text_field_amount.text!), errorMsg: "Please enter the amount") && Utils.validateInt(vc: self, intValue: accountId, errorMsg: "Please select account") && Utils.validateInt(vc: self, intValue: accountToId, errorMsg: "Please select account") {
                if accountId == accountToId {
                    UIUtils.showAlert(vc: self, message: "Transfer must be made in two different accounts")
                } else {
                    navigateToTransactionDetails()
                }
            }
        }
        else
        {
            if Utils.validateAmount(vc: self, amount: Utils.removeComma(numberString: text_field_amount.text!), errorMsg: "Please enter the amount") && Utils.validateInt(vc: self, intValue: categoryId, errorMsg: "Please select category") && Utils.validateInt(vc: self, intValue: accountId, errorMsg: "Please select account") {
                navigateToTransactionDetails()
            }
        }
       
    }
    
    private func navigateToAddAccount () {
        let addAccountVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_ACCOUNT) as! AddAccountViewController
        let navController = UINavigationController(rootViewController: addAccountVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func onCalculatorTapped(_ sender: Any) {
        let calculatorPopup = DialogCalculator()
        calculatorPopup.initialText = text_field_amount.text!
        calculatorPopup.myDelegate = self
        self.presentPopupView(popupView: calculatorPopup)
    }
    
    @IBAction func onFinishTapped(_ sender: Any) {
        if vchType == Constants.TRANSFER {
            if Utils.validateAmount(vc: self, amount: Utils.removeComma(numberString: text_field_amount.text!), errorMsg: "Please enter the amount") && Utils.validateInt(vc: self, intValue: accountId, errorMsg: "Please select account") && Utils.validateInt(vc: self, intValue: accountToId, errorMsg: "Please select account") {
                if accountId == accountToId {
                    UIUtils.showAlert(vc: self, message: "Transfer must be made in two different accounts")
                } else {
                    let voucher1 : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
                    let voucher2 : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
                    postTransferVoucherDetails(voucher1: voucher1, voucher2: voucher2, isUpdate: false)
                }
            }
        }
        else
        {
            if Utils.validateAmount(vc: self, amount: Utils.removeComma(numberString: text_field_amount.text!), errorMsg: "Please enter the amount") && Utils.validateInt(vc: self, intValue: categoryId, errorMsg: "Please select category") && Utils.validateInt(vc: self, intValue: accountId, errorMsg: "Please select account") {
                let voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
                postVoucherDetails(vch: voucher, isUpdate: false)
               
                
            }
        }
        
    }
    

    func onAddAnotherTapped() {
        self.view.setNeedsDisplay()
        collection_view_account.reloadData()
        collection_view_category.reloadData()
        accountId = 0
        accountName = ""
        accountToName = ""
        vchAmount = 0
        accountToId = 0
        categoryId = 0
    }
    
    @IBAction func onPayMoneyTapped(_ sender: Any) {
        configureUseCaseSelection(selectedIndex: 2)
        useCaseType = "Pay"
        setupView()
    }
    
    @IBAction func onReceiveMoneyTapped(_ sender: Any) {
        configureUseCaseSelection(selectedIndex: 3)
        useCaseType = "Receive"
        setupView()
    }
    
    @IBAction func onLendMoneyTapped(_ sender: Any) {
        configureUseCaseSelection(selectedIndex: 0)
        useCaseType = "Lend"
        setupView()
    }
    
    @IBAction func onBorrowMoneyTapped(_ sender: Any) {
        configureUseCaseSelection(selectedIndex: 1)
        useCaseType = "Borrow"
        setupView()
    }
    
    @objc private func onViewAmountTapped () {
        text_field_amount.becomeFirstResponder()
    }
    
    @objc private func onCloseTapped () {
        self.dismiss(animated: true, completion: nil)
    }
}


extension TransactionViewController : CalculatorListener {
    
    func onCalculationCompleted(amount: String) {
        text_field_amount.text = amount
    }

}

// Collectionview delegates
extension TransactionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
//    override func viewWillLayoutSubviews() {
//        super.updateViewConstraints()
//        self.categoryCollectionHeight.constant = self.collection_view_category.contentSize.height
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collection_view_account {
            
            return arrayOfAccountsTo.count + 1
        
        } else {
            if vchType == "Transfer" {
                print("COUNT : " , arrayOfAccountsFrom.count)
               return arrayOfAccountsFrom.count + 1
            } else {
               return arrayOfCategories.count
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibCategoryName, for: indexPath) as! CategoryCell
        
        cell.bg_view.layer.borderColor = UIColor.lightGray.cgColor
        cell.categoryImage.tintColor = UIColor.lightGray
        
        if collectionView == collection_view_category {
            if vchType == "Transfer" {
                cell.cellType = "Account"
                print("Index : " , indexPath.row , arrayOfAccountsFrom.count)
                if indexPath.row == arrayOfAccountsFrom.count {
                    cell.categoryImage.image = UIImage(named: "ic_add")
                    cell.contentView.layer.cornerRadius = 8
                    cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
                    cell.contentView.layer.borderWidth = 1.0
                    
                    if accountType == "Person" {
                        cell.category_title.text = "Add Account"
                    } else {
                        cell.category_title.text = "Add Account"
                    }
                } else {
                    
                    cell.configureAccountsWithItemCells(account: arrayOfAccountsFrom[indexPath.row])
                }
            } else {
                
                cell.cellType = "Category"
                cell.configureCategoryWithItemCells(category: arrayOfCategories[indexPath.row])
            }
        }
       else
        {
            cell.cellType = "Account"
            
            if indexPath.row == arrayOfAccountsTo.count {
                cell.categoryImage.image = UIImage(named: "ic_add")
                cell.contentView.layer.cornerRadius = 8
                cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
                cell.contentView.layer.borderWidth = 1.0
                
                if accountType == "Person" {
                    cell.category_title.text = "Add Account"
                } else {
                    cell.category_title.text = "Add Account"
                }
            } else {
                
                cell.configureAccountsWithItemCells(account: arrayOfAccountsTo[indexPath.row])
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        
        self.view.endEditing(true)
        if collectionView == collection_view_category {
            if vchType == "Transfer" {
                
                let lastRowIndex = collectionView.numberOfItems(inSection: 0)
                if indexPath.row == lastRowIndex - 1 {
                    navigateToAddAccount()
                    self.shouldSetupView = true
                } else {
                    cell.isSelected = true
                    
                    self.accountId = arrayOfAccountsFrom[indexPath.row].account_id
                    self.accountName = arrayOfAccountsFrom[indexPath.row].title!
                }
        
            } else {
                cell.cellType = "Category"
                cell.isSelected = true
                self.categoryId = arrayOfCategories[indexPath.row].categoryId
                self.categoryName = arrayOfCategories[indexPath.row].title!
            }
        }
        else
        {
            let lastRowIndex = collectionView.numberOfItems(inSection: 0)
            if indexPath.row == lastRowIndex - 1 {
                navigateToAddAccount()
                self.shouldSetupView = true
            } else {
                cell.isSelected = true
                
                
                
                if vchType == Constants.TRANSFER {
                    self.accountToId = arrayOfAccountsTo[indexPath.row].account_id
                    self.accountToName = arrayOfAccountsTo[indexPath.row].title!
                } else {
                    self.accountName = arrayOfAccountsTo[indexPath.row].title!
                    self.accountId = arrayOfAccountsTo[indexPath.row].account_id
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        
        if collectionView == collection_view_category {
            if vchType == "Transfer" {
                cell.isSelected = false
            } else {
                cell.isSelected = false
            }
        }
        else
        {
            cell.isSelected = false
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collection_view_category.frame.size.width / 3
        let height : CGFloat = 80
        
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = collection_view_category.contentOffset.x
        let width = collection_view_category.frame.width
        let horizontalCenter = width / 2
        
        page_control.currentPage = Int(offSet + horizontalCenter) / Int(width)
    }
}


