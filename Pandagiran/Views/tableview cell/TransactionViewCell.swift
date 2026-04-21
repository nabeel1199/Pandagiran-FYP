

import UIKit
import SwiftyJSON

class TransactionViewCell: UITableViewCell {
    
    @IBOutlet weak var btn_menu: UIButton!
    @IBOutlet weak var label_description: UILabel!
    @IBOutlet weak var label_travel_amount: UILabel!
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var label_amount: UILabel!
    @IBOutlet weak var label_account: UILabel!
    @IBOutlet weak var label_type: UILabel!
    @IBOutlet weak var iv_transaction: UIImageView!
    @IBOutlet weak var view_transaction_color: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
 
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func configureWithItem (accountId : Int64, voucher: Hkb_voucher) {
//        view_transaction_color.roundCorners([.topLeft, .bottomLeft], radius: 15.0)
        
        let curreny = LocalPrefs.getUserCurrency()
        label_amount.text = "\(curreny) \(Utils.formatDecimalNumber(number: voucher.vch_amount, decimal: LocalPrefs.getDecimalFormat()))"
        iv_transaction.tintColor = UIColor.lightGray
        
        if voucher.vch_amount > 0 {
            label_amount.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        } else {
            label_amount.textColor = UIColor.black
        }
        
        if voucher.vch_description! != "" {
            label_description.text = voucher.vch_description!
            label_description.isHidden = false
        } else {
            label_description.isHidden = true
        }
        
    
        
//        label_account.text = voucher.accountname!
        let voucherDate = voucher.vch_date ?? voucher.updated_on ?? ""
        let month = Utils.monthArray[Int(voucher.month - 1)]
        let dayOfWeek = Utils.getDayString(today : voucherDate)
        let day = voucher.vch_day
        let dayString = Utils.daysOfWeek[dayOfWeek]
        
        if LocalPrefs.getCurrentInterval() == Constants.MONTHLY {
            label_date.text = "\(day) \(month), \(String(describing: dayString!))"
        } else {
            label_date.text = Utils.currentDateUserFormat(date: Utils.convertStringToDate(dateString: voucherDate))
        }
    
        
        switch voucher.vch_type {
            
        case Constants.TRANSFER:
            
            
            if let refNo = voucher.ref_no {
                print( "Reference Number: \(voucher.vch_amount)")
               print( "Reference Number: \(voucher.ref_no)")
                guard let voucherTo = QueryUtils.fetchSingleVoucher(voucherId: Int64(refNo)!) else {
                    iv_transaction.image = UIImage(named: "no-image")
                    return
                }
                
                let accountFrom = QueryUtils.fetchSingleAccount(accountId: voucher.account_id)
                let accountTo = QueryUtils.fetchSingleAccount(accountId: voucherTo.account_id)
                
                if accountId != 0 {
                    label_amount.text = "\(curreny) \(Utils.formatDecimalNumber(number: voucher.vch_amount, decimal: LocalPrefs.getDecimalFormat()))"
                } else {
                    label_amount.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
                    label_amount.text = "\(curreny) \(Utils.formatDecimalNumber(number: abs(voucher.vch_amount), decimal: LocalPrefs.getDecimalFormat()))"
                }
                
                let accountFromTitle = NSMutableAttributedString()
                let accountToTitle = NSMutableAttributedString()
         
                if let title = accountFrom?.title  {
                    accountFromTitle.append(NSAttributedString(string: title))
                    
                    if accountFrom?.active == 2 {
                        
                        accountFromTitle.append(NSAttributedString(string: "(Deleted)", attributes: [.foregroundColor : UIColor.red]))
                    }
                }
                    
                if let title = accountTo?.title {
                    accountToTitle.append(NSAttributedString(string: title))
                    
                    if accountTo?.active == 2 {
                        accountToTitle.append(NSAttributedString(string: "(Deleted)", attributes: [.foregroundColor : UIColor.red]))
                    }
                }
                
                if voucher.vch_amount > 0 {
                    let accountTitle = NSMutableAttributedString()
                    accountTitle.append(accountToTitle)
                    accountTitle.append(NSAttributedString(string: " > ", attributes: [.foregroundColor : UIColor.black]))
                    accountTitle.append(accountFromTitle)
                    label_account.attributedText = accountTitle
                } else {
                    let accountTitle = NSMutableAttributedString()
                    accountTitle.append(accountFromTitle)
                    accountTitle.append(NSAttributedString(string: " > ", attributes: [.foregroundColor : UIColor.black]))
                    accountTitle.append(accountToTitle)
                    
                    label_account.attributedText = accountTitle
                }
                
            }
            
            if voucher.use_case == "Lend" {
                label_type.text = "Money Lent"
            } else if voucher.use_case == "Borrow" {
                label_type.text = "Money Borrowed"
            } else if voucher.use_case == "Pay" {
                label_type.text = "Money Paid"
            } else if voucher.use_case == "Receive" {
                label_type.text = "Money Received"
            } else if voucher.use_case == "ATM" {
                label_type.text = "ATM Withdrawal"
            } else if voucher.use_case == "Savings" {
                label_type.text = "Savings"
            } else if voucher.use_case == "Transfer" {
                label_type.text = "Transfer"
            } else {
                label_type.text = "Something went Wrong"
            }
            
            label_travel_amount.isHidden = true
            iv_transaction.image = UIImage(named: "transfer_inactive")
            view_transaction_color.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        break
            
        default:
            if voucher.travelmode != nil && voucher.travelmode == 1 {
                label_travel_amount.isHidden = false
                label_travel_amount.text = "\(voucher.fccurrency!) \(Utils.formatDecimalNumber(number: voucher.fcamount, decimal: LocalPrefs.getDecimalFormat()))"
                
                if voucher.fcamount > 0 {
                    label_travel_amount.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
                } else {
                    label_travel_amount.textColor = UIColor.black
                }
            } else {
                label_travel_amount.isHidden = true
            }
            
            let account = QueryUtils.fetchSingleAccount(accountId: Int64(voucher.account_id))
            let category = QueryUtils.fetchSingleCategory(categoryId: Int64(voucher.category_id))
            
            if let image = UIImage(named: category?.box_icon ?? "no-image"){
                iv_transaction.image = image.withRenderingMode(.alwaysTemplate)
            } else {
                iv_transaction.image = UIImage(named: "no-image")
            }
//            iv_transaction.image = UIImage(named: category?.box_icon ?? "no-image")?.withRenderingMode(.alwaysTemplate)
            
            let accountTitle = NSMutableAttributedString()
            
            if let title = account?.title {
                accountTitle.append(NSAttributedString(string: title))
                
                if account?.active == 2 {
                    accountTitle.append(NSAttributedString(string: "(Deleted)", attributes: [.foregroundColor : UIColor.red]))
                }
                
                label_account.attributedText = accountTitle
            }
            
            
            if voucher.vch_type == Constants.EXPENSE {
                let category = QueryUtils.fetchSingleCategory(categoryId: Int64(voucher.category_id))
                label_type.text = category?.title ?? Constants.NULL_TEXT
                view_transaction_color.backgroundColor = UIColor.red
            } else {
                view_transaction_color.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
                let category = QueryUtils.fetchSingleCategory(categoryId: Int64(voucher.category_id))
                label_type.text = "\(category?.title ?? Constants.NULL_TEXT) Income"
            }
        }
        
    
    }
    
    public func configureSavingTransactionWithItem (savingTrx: Hkb_goal_trx, goalTitle: String) {
        btn_menu.isHidden = false
        let account = QueryUtils.fetchSingleAccount(accountId: Int64(savingTrx.accountid))
        let vchDate = Utils.convertStringToDate(dateString: savingTrx.trxdate!)
        let currency = LocalPrefs.getUserCurrency()
        let decimal = LocalPrefs.getDecimalFormat()
        iv_transaction.image = UIImage(named: "transfer_inactive")
        label_type.text = goalTitle
        label_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: savingTrx.amount, decimal: decimal))"
        label_date.text = Utils.currentDateUserFormat(date: vchDate)
        
        let accountTitle = NSMutableAttributedString()
        
        if let title = account?.title {
            accountTitle.append(NSAttributedString(string: title))
            
            if account?.active == 2 {
                accountTitle.append(NSAttributedString(string: "(Deleted)", attributes: [.foregroundColor : UIColor.red]))
            }
            
            label_account.attributedText = accountTitle
        }
    }
}
