

import UIKit


protocol FilterAppliedListener {
    func onFilterApplied (categoryId: Int64,
                          accountId: Int64,
                          eventId: Int64,
                          vchType: String,
                          filterParams: String,
                          amountRange: String,
                          count: Int)
}

class ActivityFilterViewController: BaseViewController {

    @IBOutlet weak var label_event: UILabel!
    @IBOutlet weak var view_event: CardView!
    @IBOutlet weak var label_currency_end: UILabel!
    @IBOutlet weak var label_currency_start: UILabel!
    @IBOutlet weak var text_field_end_amount: AmountEnterTextField!
    @IBOutlet weak var text_field_start_amount: AmountEnterTextField!
    @IBOutlet weak var view_end_amount: CardView!
    @IBOutlet weak var view_start_amount: CardView!
    @IBOutlet weak var view_transaction_type: CardView!
    @IBOutlet weak var view_category: CardView!
    @IBOutlet weak var view_account: CardView!
    @IBOutlet weak var label_selected_category: UILabel!
    @IBOutlet weak var label_vch_type: UILabel!
    @IBOutlet weak var label_account: UILabel!
    @IBOutlet weak var label_max_amount: UILabel!
    @IBOutlet weak var label_min_amount: UILabel!
    @IBOutlet weak var btn_apply: GradientButton!
    @IBOutlet weak var label_transaction_type: CustomFontLabel!
    @IBOutlet weak var label_category: CustomFontLabel!
    @IBOutlet weak var label_source_account: CustomFontLabel!
    @IBOutlet weak var label_transaction: CustomFontLabel!
    
    private var hasViewLoaded = false
    
    public var categoryId : Int64 = 0
    public var categoryName : String = ""
    public var accountId : Int64 = 0
    public var eventId : Int64 = 0
    public var accountName : String = ""
    public var vchType: String = ""
    public var amountRange = ""
    public var delegate : FilterAppliedListener?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        initVariables()
        initUI()
        setAddedFilters()

    }
    
    private func initVariables () {
        
        let accountTapGest = UITapGestureRecognizer(target: self, action: #selector(onAccountTapped))
        view_account.addGestureRecognizer(accountTapGest)
        
        let categoryTapGest = UITapGestureRecognizer(target: self, action: #selector(onCategoryTapped))
        view_category.addGestureRecognizer(categoryTapGest)
        
        let transactionTypeGest = UITapGestureRecognizer(target: self, action: #selector(onTransactionTypeTapped))
        view_transaction_type.addGestureRecognizer(transactionTypeGest)
        
        let startAmmountGest = UITapGestureRecognizer(target: self, action: #selector(onStartAmountTapped))
        view_start_amount.addGestureRecognizer(startAmmountGest)
        
        let endAmountGest = UITapGestureRecognizer(target: self, action: #selector(onEndAmountTapped))
        view_end_amount.addGestureRecognizer(endAmountGest)
        
        let eventTapGest = UITapGestureRecognizer(target: self, action: #selector(onEventTapped))
        view_event.addGestureRecognizer(eventTapGest)
    }
    
    private func initUI () {
        self.viewBackgroundColor = .white
        self.navigationItemColor = .light
//        let navIconRight = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onCloseTapped))
//        self.navigationItem.rightBarButtonItem = navIconRight
        
        let clearAllBtn = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(onClearTapped))
        self.navigationItem.rightBarButtonItem = clearAllBtn
        
        label_currency_start.text = LocalPrefs.getUserCurrency()
        label_currency_end.text = LocalPrefs.getUserCurrency()
        
        label_source_account.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_account.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_category.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_selected_category.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_transaction_type.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_vch_type.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        btn_apply.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)

    }
    
    private func setAddedFilters () {
        if accountId != 0 {
            let account = QueryUtils.fetchSingleAccount(accountId: Int64(accountId))
            label_account.text = account?.title ?? Constants.NULL_TEXT
        } else {
            label_account.text = "All Accounts"
        }
        
        if categoryId != 0 {
            let category = QueryUtils.fetchSingleCategory(categoryId: Int64(categoryId))
            label_selected_category.text = category?.title ?? Constants.NULL_TEXT
        } else {
            label_selected_category.text = "All Categories"
        }
        
        if eventId != 0 {
            if let event = QueryUtils.fetchSingleEvent(eventId: eventId) {
                label_event.text = event.name
            }
        } else {
            label_event.text = "Select Event"
        }
        
        if vchType != "" {
            label_vch_type.text = vchType
        } else {
            label_vch_type.text = "All Vouchers"
        }
        
        if amountRange != "" {
            let addedAmount = amountRange.components(separatedBy: "-")
            text_field_start_amount.text = addedAmount[0]
            text_field_end_amount.text = addedAmount[1]
        }
    
    }
    
    private func getFilterCount () -> Int {
        var count = 0
        
        if accountId != 0 {
            count += 1
        }
        
        if categoryId != 0 {
            count += 1
        }
        
        if eventId != 0 {
            count += 1
        }
        
        if vchType != "" {
            count += 1
        }
        
        if text_field_end_amount.text != "" {
            count += 1
        }
        
        return count
    }

    @objc private func onAccountTapped () {
        let accountPopup = AccountSelectionPopup()
        accountPopup.delegate = self
        self.presentPopupView(popupView: accountPopup)
    }
    
    @objc private func onCategoryTapped () {
        let categoryPopup = CategorySelectionPopup()
        categoryPopup.delegate = self
        self.presentPopupView(popupView: categoryPopup)
    }
    
    @objc private func onEventTapped () {
        let eventPopup = EventSelectionPopup()
        eventPopup.delegate = self
        eventPopup.showActive = false
        eventPopup.isFilter = true
        self.presentPopupView(popupView: eventPopup)
    }
    
    @objc private func onTransactionTypeTapped () {
        let vchSelectionTypePopup = TransactionTypeSelectionPopup()
        vchSelectionTypePopup.delegate = self
        self.presentPopupView(popupView: vchSelectionTypePopup)
    }
    
    @IBAction func onApplyTapped(_ sender: Any) {
        let filterCount = getFilterCount()
        let startAmountText = text_field_start_amount.text!
        let endAmountText = text_field_end_amount.text!
        let startAmount = Utils.removeComma(numberString: startAmountText)
        let endAmount = Utils.removeComma(numberString: endAmountText)
        
        if endAmount != 0 {
            if startAmount <= endAmount {
                let filterString = "\(String(describing: label_selected_category.text!)) + \(String(describing: label_account.text!)) + \(String(describing: label_vch_type.text!))"
                delegate?.onFilterApplied(categoryId: categoryId,
                                          accountId: accountId,
                                          eventId: eventId,
                                          vchType: vchType,
                                          filterParams: filterString,
                                          amountRange: "\(startAmount)-\(endAmount)",
                                            count: filterCount)
                self.navigationController?.popViewController(animated: true)
            } else {
                UIUtils.showAlert(vc: self, message: "Starting amount can not be greater than limit amount")
            }
        } else {
            let filterString = "\(String(describing: label_selected_category.text!)) + \(String(describing: label_account.text!)) + \(String(describing: label_vch_type.text!))"
            delegate?.onFilterApplied(categoryId: categoryId,
                                      accountId: accountId,
                                      eventId: eventId,
                                      vchType: vchType,
                                      filterParams: filterString,
                                      amountRange: "",
                                      count: filterCount)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @objc private func onStartAmountTapped () {
        text_field_start_amount.becomeFirstResponder()
    }
    
    @objc private func onEndAmountTapped () {
        text_field_end_amount.becomeFirstResponder()
    }
    
    @objc private func onCloseTapped () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func onClearTapped () {
        delegate?.onFilterApplied(categoryId: 0, accountId: 0, eventId: 0, vchType: "", filterParams: "", amountRange: "", count: 0)
        self.navigationController?.popViewController(animated: true)
    }

    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationItemColor = .dark
    }
    
}

extension ActivityFilterViewController: CategorySelectionListener, AccountSelectionListener, TransactionTypeSelectionListener, EventSelectionListener {


    func onTypeSelected(vchType: String) {
        label_vch_type.text = vchType
        self.vchType = vchType
    }
    
    
    func onAccountSelected(accountTitle: String, accountId: Int64) {
        label_account.text = accountTitle
        self.accountId = accountId
    }

    func onCategorySelected(category: String, categoryId: Int64) {
        label_selected_category.text = category
        self.categoryId = categoryId
    }
    
    func onEventSelected(eventId: Int64, eventName: String) {
        self.eventId = eventId
        label_event.text = eventName
    }
    
}
