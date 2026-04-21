

import UIKit


protocol DealFilterSelectionListener {
    func onDealFilterApplied (percentage: Int,
                              amountRange: String,
                              brandName: String,
                              count: Int)
}

class DealsFilterViewController: BaseViewController {
    
    
    @IBOutlet weak var view_start_amount: CardView!
    @IBOutlet weak var view_end_amount: CardView!
    @IBOutlet weak var text_field_end_amount: AmountEnterTextField!
    @IBOutlet weak var text_field_start_amount: AmountEnterTextField!
    @IBOutlet weak var view_amount_end: CardView!
    @IBOutlet weak var view_amount_start: CardView!
    @IBOutlet weak var view_brand: CardView!
    @IBOutlet weak var label_brand: UILabel!
    @IBOutlet weak var view_date: CardView!
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var label_discount_max: UILabel!
    @IBOutlet weak var label_discount_initial: UILabel!
    @IBOutlet weak var seekbar_discount: UISlider!
    
    public var delegate : DealFilterSelectionListener?
    
    private var count = 0
    public var discountValue = 0
    public var brandName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        setAddedFilters()
    }
    
    private func initUI () {
        seekbar_discount.setThumbImage(UIImage(named: "ic_seekbar"), for: .normal)
        self.navigationItemColor = .light
        self.viewBackgroundColor = .white
        
        let clearAllBtn = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(onClearTapped))
        self.navigationItem.rightBarButtonItem = clearAllBtn
        
        let brandTapGest = UITapGestureRecognizer(target: self, action: #selector(onBrandTapped))
        view_brand.addGestureRecognizer(brandTapGest)
        
        let amountTapGest = UITapGestureRecognizer(target: self, action: #selector(onAmountStartTapped))
        view_amount_start.addGestureRecognizer(amountTapGest)
        
        let amountEndTapGest = UITapGestureRecognizer(target: self, action: #selector(onAmountEndTapped))
        view_amount_end.addGestureRecognizer(amountEndTapGest)
    }
    
    private func setAddedFilters () {
        seekbar_discount.value = Float(discountValue)
        label_discount_initial.text = "\(discountValue)%"
        
        if brandName != "" {
            label_brand.text = brandName
        }
    }

    private func getFilterCount () {
        if text_field_end_amount.text != "" {
            count += 1
        }
        
        if seekbar_discount.value > 0 {
            count += 1
        }
        
        if brandName != "" {
            count += 1
        }
    }
    
    @objc private func onClearTapped () {
        delegate?.onDealFilterApplied(  percentage: 0,
                                        amountRange: "",
                                        brandName: "",
                                        count: 0)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSliderValueChanged(_ sender: Any) {
        label_discount_initial.text = "\(Int(seekbar_discount.value))%"
    }
    
    @objc private func onBrandTapped () {
        let searchBrandVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SEARCH_BRAND) as! SearchBrandViewController
        searchBrandVC.delegate = self
        self.navigationController?.pushViewController(searchBrandVC, animated: true)
    }
    
    @IBAction func onApplyTapped(_ sender: Any) {
        let startAmount = Utils.removeComma(numberString: text_field_start_amount.text!)
        let endAmount = Utils.removeComma(numberString: text_field_end_amount.text!)
        let dealDiscount = Int(seekbar_discount.value)
        getFilterCount()
        
            if endAmount >= startAmount {
                delegate?.onDealFilterApplied(  percentage: dealDiscount,
                                                amountRange: "\(startAmount)~\(endAmount)",
                                                brandName: brandName,
                                                count: count)
                
                self.navigationController?.popViewController(animated: true)
            } else {
                UIUtils.showAlert(vc: self, message: "End amount should be greater than starting amount")
            }
        
    }
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationItemColor = .dark
    }
    
    @objc private func onAmountStartTapped () {
        text_field_start_amount.becomeFirstResponder()
    }
    
    @objc private func onAmountEndTapped () {
        text_field_end_amount.becomeFirstResponder()
    }

}

extension DealsFilterViewController : BrandSelectionListener {
    
    func onBrandSelected(brandName: String) {
        self.brandName = brandName
        label_brand.text = brandName
    }

}
