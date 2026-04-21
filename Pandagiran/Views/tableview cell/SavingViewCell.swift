

import UIKit

class SavingViewCell: UITableViewCell {

    
    @IBOutlet weak var iv_saving: UIImageView!
    @IBOutlet weak var btn_menu: UIButton!
    @IBOutlet weak var label_saved_percentage: UILabel!
    @IBOutlet weak var label_total_amount: UILabel!
    @IBOutlet weak var label_saved_amount: UILabel!
    @IBOutlet weak var label_saved: UILabel!
    @IBOutlet weak var label_target_date: UILabel!
    @IBOutlet weak var label_saving_title: UILabel!
    @IBOutlet weak var progress_View: UIProgressView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        progress_View.layer.cornerRadius = 3
        progress_View.layer.masksToBounds = true
        
        label_saving_title.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_target_date.regularFont(fontStyle: .regular, size: Style.dimen.SMALL_TEXT)
        label_saved.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_saved_amount.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_total_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_saved_percentage.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    public func configureSavingWithItem (saving: Hkb_goal) {
        let currency = LocalPrefs.getUserCurrency()
        
        let totalAmount = saving.amount
        let savedAmount = SavingDbUtils.fetchSavedAmount(goalId: Int(saving.goalId))        
        let goalPercentage = (savedAmount / totalAmount) * 100
        let progressValue: Double = savedAmount / totalAmount
        
        let savingDate = Utils.convertStringToDate(dateString: saving.targetenddate!)
        
        
        if let image = UIImage(named: saving.flex2 ?? "category"){
            iv_saving.image = image
        } else {
            iv_saving.image = UIImage(named: "category")
        }
//        iv_saving.image = UIImage(named: saving.flex2!)
        label_saving_title.text = saving.title!
        label_target_date.text = "Target Date: \(Utils.currentDateUserFormat(date: savingDate))"
        label_saved_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: savedAmount, decimal: LocalPrefs.getDecimalFormat()))"
        label_total_amount.text = "/\(Utils.formatDecimalNumber(number: totalAmount, decimal: LocalPrefs.getDecimalFormat()))"
        label_saved_percentage.text = "\(round(goalPercentage))%"
        progress_View.setProgress(Float(progressValue), animated: true)
    }
    
    @IBAction func onMenuItemTapped(_ sender: Any) {
    }
}
