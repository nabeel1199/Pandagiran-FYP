

import UIKit

protocol FlyerDealSelectionListener {
    func onDealFilterApplied (amountRange: String,
                              retailerName: String,
                              category: String,
                              expiryDate: Int64,
                              count: Int)
}

class FlyerFilterViewController: BaseViewController {

    @IBOutlet weak var view_amount_end: CardView!
    @IBOutlet weak var view_amount_start: CardView!
    @IBOutlet weak var view_retailer: CardView!
    @IBOutlet weak var label_retailer: UILabel!
    @IBOutlet weak var label_category: UILabel!
    @IBOutlet weak var view_category: CardView!
    @IBOutlet weak var label_expiry_date: UILabel!
    @IBOutlet weak var view_expiry_date: CardView!
    @IBOutlet weak var text_field_end_amount: AmountEnterTextField!
    @IBOutlet weak var text_field_start_amount: AmountEnterTextField!
    
    public var delegate : FlyerDealSelectionListener?
    public var categoryName = ""
    public var retailerName = ""
    public var expiryDate : Int64 = 0
    
    private var count = 0
    private var isCategorySelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()


        initUI()
    }
    
    private func initUI () {
        self.navigationItemColor = .light
        
        let clearAllBtn = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(onClearTapped))
        self.navigationItem.rightBarButtonItem = clearAllBtn
                
        let viewDateGest = UITapGestureRecognizer(target: self, action: #selector(onDateTapped))
        view_expiry_date.addGestureRecognizer(viewDateGest)
        
        let viewCategoryGest = UITapGestureRecognizer(target: self, action: #selector(onCategoryTapped))
        view_category.addGestureRecognizer(viewCategoryGest)
        
        let viewRetailerGest = UITapGestureRecognizer(target: self, action: #selector(onRetailerTapped))
        view_retailer.addGestureRecognizer(viewRetailerGest)
        
        let amountTapGest = UITapGestureRecognizer(target: self, action: #selector(onAmountStartTapped))
        view_amount_start.addGestureRecognizer(amountTapGest)
        
        let amountEndTapGest = UITapGestureRecognizer(target: self, action: #selector(onAmountEndTapped))
        view_amount_end.addGestureRecognizer(amountEndTapGest)
        
    }
    
    private func setAddedFilters () {
        if categoryName != "" {
            label_category.text = categoryName
        }
        
        if retailerName != "" {
            label_retailer.text = retailerName
        }
        
        if expiryDate != 0 {
            let date = Date(timeIntervalSince1970: TimeInterval(expiryDate))
            label_expiry_date.text = Utils.currentDateUserFormat(date: date)
        }
    }
    
    private func getFilterCount () {
        if text_field_end_amount.text != "" {
            count += 1
        }
        
        if categoryName != "" {
            count += 1
        }
        
        if retailerName != "" {
            count += 1
        }
        
        if expiryDate != 0 {
            count += 1
        }
    }
    
    private func showDateDialog() {
        let datePopup = DateSelectionPopup()
        datePopup.delegate = self
        datePopup.popupTitle = "Expiry Date"
        self.presentPopupView(popupView: datePopup)
    }

    @objc private func onDateTapped () {
        showDateDialog()
    }
    
    @objc private func onCategoryTapped () {
        isCategorySelected = true
        let filterCategoryVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_CATEGORY) as! FilterCategoryViewController
        filterCategoryVC.delegate = self
        self.navigationController?.pushViewController(filterCategoryVC, animated: true)
    }
    
    @objc private func onRetailerTapped () {
        isCategorySelected = false
        let filterRetailerVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_RETAILER) as! FilterRetailersViewController
        filterRetailerVC.delegate = self
        self.navigationController?.pushViewController(filterRetailerVC, animated: true)
    }
    
    @IBAction func onApplyTapped(_ sender: Any) {
        let startAmount = Utils.removeComma(numberString: text_field_start_amount.text!)
        let endAmount = Utils.removeComma(numberString: text_field_end_amount.text!)
        getFilterCount()
        
        if endAmount >= startAmount {
            delegate?.onDealFilterApplied(amountRange: "\(startAmount)~\(endAmount)",
                                          retailerName: retailerName,
                                          category: categoryName,
                                          expiryDate: expiryDate,
                                          count: count)
            
            self.navigationController?.popViewController(animated: true)
        } else {
            UIUtils.showAlert(vc: self, message: "End amount should be greater than starting amount")
        }
        
    }
    
    @objc private func onClearTapped () {
        delegate?.onDealFilterApplied(amountRange: "",
            retailerName: "",
            category: "",
            expiryDate: 0,
            count: 0)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func onAmountStartTapped () {
        text_field_start_amount.becomeFirstResponder()
    }
    
    @objc private func onAmountEndTapped () {
        text_field_end_amount.becomeFirstResponder()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationItemColor = .dark
    }
}

extension FlyerFilterViewController : DateSelectionListener, CategoryAndRetilerSelectionListener {
    
    func onCategoryOrRetailerSelected(selectedString: String) {
        if isCategorySelected {
            categoryName = selectedString
            label_category.text = selectedString
        } else {
            retailerName = selectedString
            label_retailer.text = selectedString
        }
    }
    
    func onDateSelected(date: Date) {
        expiryDate = Int64(date.timeIntervalSince1970)
        let dateString = Utils.currentDateUserFormat(date: date)
        label_expiry_date.text = dateString
    }
    
    
    
}
