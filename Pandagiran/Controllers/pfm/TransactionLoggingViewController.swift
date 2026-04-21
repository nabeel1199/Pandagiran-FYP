

import UIKit

class TransactionLoggingViewController: BaseViewController {

    @IBOutlet weak var container_view: UIView!
    @IBOutlet weak var segment_view: SignatureSegmentedControl!
    
    
    public var vchType = "Expense"
    public var isExpense = 0
    public var useCaseType = "Lend"
    public var accountType = ""
    public var vchAmount: Double = 0
    public var accountToName = ""
    public var categoryName = ""
    public var accountName = ""
    public var editVoucher : Hkb_voucher?
    
    private var controller = TransactionViewController()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        initVariables()
        voucherEdit()
        initUI()
        embedTransactionVc()
        
  
    }
    
    private func initVariables () {
        segment_view.delegate = self
    }
    
    private func initUI () {
//        segment_view.useGradient = true
//        segment_view.thumbGradientColors = [Utils.hexStringToUIColor(hex: "FF3CB9AD"), Utils.hexStringToUIColor(hex: "#FF1E576A")]
        
        
        let rightNavIcon = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onNavRightTapped))
        self.navigationItem.rightBarButtonItem = rightNavIcon
        
        if vchType == Constants.EXPENSE {
            segment_view.selectedSegmentIndex = 0
        } else if vchType == Constants.INCOME {
            segment_view.selectedSegmentIndex = 1
        } else  if vchType == Constants.TRANSFER {
            if accountType == "Person" {
                segment_view.selectedSegmentIndex = 3
            } else {
               segment_view.selectedSegmentIndex = 2
            }
        } else {
            segment_view.selectedSegmentIndex = 3
        }
        
    }
    
    private func onSegmentsTapped () {
//        segment_view.didSelectItemWith = { (index, title) -> () in
//            self.controller.vchType = title!
//            self.vchType = title!
//        }
    }
    
    private func voucherEdit () {
        print("USE CASE : " , editVoucher?.use_case)
        if useCaseType == "Lend" || useCaseType == "Pay" || useCaseType == "Borrow" || useCaseType == "Receive" {
            self.accountType = "Person"
        }
        
        if editVoucher != nil {
            self.navigationItem.title = "Edit Transaction"
            segment_view.isUserInteractionEnabled = false
            self.vchType = (editVoucher?.vch_type)!
        } else {
            self.navigationItem.title = "Add Transaction"
        }
    }
    
    private func embedTransactionVc () {
        controller = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: ViewIdentifiers.VC_TRANSACTION) as! TransactionViewController
        addChild(controller)
        
        container_view.addSubview(controller.view)
        container_view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.frame.size.width = container_view.frame.width
        controller.view.frame.size.height = container_view.frame.height
        
        controller.accountName = accountName
        controller.categoryName = categoryName
        controller.accountToName = accountToName
        controller.vchAmount = self.vchAmount
        controller.isExpense = self.isExpense
        controller.useCaseType = self.useCaseType
        controller.accountType = self.accountType
        controller.vchType = self.vchType
        controller.editVoucher = self.editVoucher

    }
    
    
    @objc private func onNavRightTapped () {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension TransactionLoggingViewController : SegmentButtonTappedListener {
    
    func onSegmentTapped(btnTitle: String) {
        self.controller.accountType = ""
        
        switch btnTitle {
        case "PERSON":
            self.controller.useCaseType = "Lend"
            self.controller.accountType = "Person"
            self.controller.vchType = Constants.TRANSFER
            self.vchType = Constants.TRANSFER
            self.useCaseType = Constants.INCOME
        case "INCOME":
            self.controller.isExpense = 0
            self.controller.vchType = Constants.INCOME
            self.vchType = Constants.INCOME
            self.useCaseType = Constants.INCOME
        case "TRANSFER":
            self.controller.vchType = Constants.TRANSFER
            self.controller.useCaseType = Constants.TRANSFER
            self.vchType = Constants.TRANSFER
        default:
            self.controller.isExpense = 1
            self.controller.vchType = Constants.EXPENSE
            self.vchType = Constants.EXPENSE
        }
    }
    
    
}
