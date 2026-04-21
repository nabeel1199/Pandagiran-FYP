

import UIKit
import GooglePlaces

class BankLandingViewCell: UICollectionViewCell {

    
    
    @IBOutlet weak var label_inactive: UILabel!
    @IBOutlet weak var bg_view: CardView!
    @IBOutlet weak var btn_menu: UIButton!
    @IBOutlet weak var view_cell: CardView!
    @IBOutlet weak var label_outflow_amount: UILabel!
    
    @IBOutlet weak var label_balance_amount: UILabel!
    @IBOutlet weak var label_inflow_amount: UILabel!
    @IBOutlet weak var iv_bank_logo: UIImageView!
    @IBOutlet weak var inflowOutflowHeight: NSLayoutConstraint!
    @IBOutlet weak var label_bank_name: UILabel!
    @IBOutlet weak var label_available_balance: UILabel!
    @IBOutlet weak var label_net_woth: UILabel!
    @IBOutlet weak var view_inflow_outflow: UIView!
    
    public var cellType = "" {
        didSet {
            configureCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        configureCell()
        
        self.bg_view.backgroundColor = UIColor(patternImage: UIImage(named: "bg_card")!)
        
        label_bank_name.regularFont(fontStyle: .bold, size: Style.dimen.SMALL_TEXT)
        label_net_woth.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_available_balance.regularFont(fontStyle: .bold, size: Style.dimen.LARGE_TEXT)
        label_available_balance.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_inflow_amount.regularFont(fontStyle: .regular, size: Style.dimen.SMALL_TEXT)
        label_outflow_amount.regularFont(fontStyle: .regular, size: Style.dimen.SMALL_TEXT)
   
    }
    
    private func configureCell () {
        if cellType == "" {
            inflowOutflowHeight.constant = 0
            view_inflow_outflow.isHidden = true
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
//        layoutIfNeeded()
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
//        let screenWidth = UIScreen.main.bounds.width
        let targetSize = CGSize(width: self.contentView.frame.width - 20, height: self.contentView.frame.height)
        
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        
        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    public func configureAccountWithItem (balanceAmount: Double, type: String, account: Hkb_account?) {
        inflowOutflowHeight.constant = 0
        view_inflow_outflow.isHidden = true
        label_available_balance.isHidden = true
        label_net_woth.isHidden = false
        

        
        if type == "All" {
            label_bank_name.text = "All Accounts"
            label_balance_amount.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: balanceAmount, decimal: LocalPrefs.getDecimalFormat()))"
            label_available_balance.isHidden = true
            label_net_woth.text = "Balance"
            iv_bank_logo.image = UIImage(named: "ic_cash_account")
            label_inactive.isHidden = true
//            iv_bank_logo.tintColor = UIColor.lightGray
            
        } else {
            if let pfmAccount = account {
                var title = ""
                
                if let accountTitle = pfmAccount.title {
                    title = accountTitle
                    label_bank_name.text = accountTitle
                }
                
                label_balance_amount.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: balanceAmount, decimal: LocalPrefs.getDecimalFormat()))"
                
                if let accountIcon = pfmAccount.boxicon {
                    iv_bank_logo.image = UIImage(named: accountIcon)
                    
                    if type != "Bank" {
                        let image = UIImage(named: accountIcon)?.withRenderingMode(.alwaysTemplate)
                        iv_bank_logo.image = image
                        iv_bank_logo.tintColor = UIColor.lightGray
                    } else {
                        let image = UIImage(named: accountIcon)
                        iv_bank_logo.image = image
                    }
                }
                
                if pfmAccount.active == 1 {
                    label_inactive.isHidden = true
                } else {
                    label_inactive.isHidden = false
                }
            
                
                if type == "Person"
                {
                    
                    if balanceAmount == 0 {
                        label_net_woth.text = "No Pendig debts"
                    } else if balanceAmount > 0 {
                        label_net_woth.text = "\(title) owes you"
                    } else {
                        label_net_woth.text = "You owe \(title)"
                    }
                    
                }
                else
                {
                    label_net_woth.text = "Available Balance"
                    
                }
            }
        }
   
    }

    
    public func configureAccountDetailsWithItem (account: Hkb_account, inflow: Double, outflow: Double, opening: Double) {
        var type = ""
        
        let currency = LocalPrefs.getUserCurrency()
        
        if account.acctype != nil {
            type = account.acctype!
        }
        
        if account.acctype == "Savings"{
            btn_menu.isHidden = true
        } else {
            btn_menu.isHidden = false
        }
        
        let openingBalance = opening + inflow + outflow
        
        label_inflow_amount.text = "\(Utils.formatDecimalNumber(number: inflow, decimal: LocalPrefs.getDecimalFormat()))"
        label_outflow_amount.text = "\(Utils.formatDecimalNumber(number: abs(outflow), decimal: LocalPrefs.getDecimalFormat()))"
        label_balance_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: openingBalance, decimal: LocalPrefs.getDecimalFormat()))"
        label_available_balance.isHidden = true
        label_net_woth.isHidden = false
        
        if let title = account.title {
            label_bank_name.text = title
        }
        
        if type == "Person" {
            label_net_woth.text = "Pending debts"
        } else {
            label_net_woth.text = "Available balance"
        }
        
        if let accountIcon = account.boxicon {
            if type == "Bank" {
                if let image = UIImage(named: accountIcon){
                    iv_bank_logo.image = image
                } else {
                    iv_bank_logo.image = UIImage(named: "accounts")
                }
                
            } else {
                if let image = UIImage(named: accountIcon){
                    iv_bank_logo.image = image.withRenderingMode(.alwaysTemplate)
                } else {
                    iv_bank_logo.image = UIImage(named: "accounts")
                }
//                iv_bank_logo.image = UIImage(named: accountIcon)?.withRenderingMode(.alwaysTemplate)
            }
        }
    
        if account.active == 1 {
            label_inactive.isHidden = true
        } else {
            label_inactive.isHidden = false
        }
       
    }
    
    public func configurePlaceWithItem (place : GMSPlace) {
        view_inflow_outflow.isHidden = true
        inflowOutflowHeight.constant = 0
        
        label_balance_amount.isHidden = true
        label_net_woth.isHidden = false
        label_available_balance.isHidden = true
        
        label_bank_name.text = place.name!
        label_net_woth.numberOfLines = 2
        label_net_woth.text = place.formattedAddress!
    }
}
