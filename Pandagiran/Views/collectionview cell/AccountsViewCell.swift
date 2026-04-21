

import UIKit

class AccountsViewCell: UICollectionViewCell {

    @IBOutlet weak var view_add_account: UIView!
    @IBOutlet weak var view_amount_color: UIView!
    @IBOutlet weak var tv_account: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tv_amount: UILabel!
    @IBOutlet weak var addAccountBg: UIView!
    @IBOutlet weak var cellWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        view_amount_color.roundCorners([.topLeft , .bottomLeft], radius: 15.0)
    }

    public func configureAccountWithItem(account : Hkb_account, balance: Double) {
        
       
        if let accountTitle = account.title {
           tv_account.text = accountTitle
        }
        
        tv_amount.text = "\(Utils.formatDecimalNumber(number: balance, decimal: LocalPrefs.getDecimalFormat()))"
        
        if balance >= 0 {
            view_amount_color.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        } else {
            view_amount_color.backgroundColor = UIColor.red
        }
        
    }
    
}
