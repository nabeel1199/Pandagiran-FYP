

import UIKit

class BudgetViewCell: UITableViewCell {

    @IBOutlet weak var iv_category: TintedImageView!
    @IBOutlet weak var label_spent_percentage: UILabel!
    @IBOutlet weak var progress_view: UIProgressView!
    @IBOutlet weak var label_category: UILabel!
    @IBOutlet weak var label_total_amount: UILabel!
    @IBOutlet weak var label_spent_amount: UILabel!
    @IBOutlet weak var label_left_amount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        progress_view.layer.cornerRadius = 3.0
        progress_view.layer.masksToBounds = true
        
        label_category.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_left_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_spent_amount.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_total_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_spent_percentage.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureBugetsWithItem (category: Hkb_category, month: String, year: Int) {
        let budgetAmount = BudgetDbUtils.fetchBudgetAmount(categoryId: category.categoryId, currentInterval: Constants.MONTHLY, month: month, year: year)
        let spentAmount = BudgetDbUtils.fetchAmountSpent(categoryId: category.categoryId, currentInterval: Constants.MONTHLY, month: month, year: year)
        let leftAmount = budgetAmount - abs(spentAmount)
        
        let progressValue : Double = Double(spentAmount / budgetAmount)
        let percentAmount = abs((spentAmount / budgetAmount) * 100)
        
        
        label_category.text = category.title!
        label_left_amount.text = "Left: \(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: leftAmount, decimal: LocalPrefs.getDecimalFormat()))"
        label_spent_amount.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(spentAmount), decimal: LocalPrefs.getDecimalFormat()))"
        label_total_amount.text = " /\(Utils.formatDecimalNumber(number: budgetAmount, decimal: LocalPrefs.getDecimalFormat()))"
        label_spent_percentage.text = "\(round(percentAmount))%"
        if let image = UIImage(named: category.box_icon ?? "category"){
            iv_category.image = image.withRenderingMode(.alwaysTemplate)
        } else {
            iv_category.image = UIImage(named: "category")
        }
        
        iv_category.tintColor = UIColor.lightGray
        progress_view.setProgress(Float(abs(progressValue)), animated: true)
        
        if percentAmount > 80 && percentAmount < 100 {
            progress_view.progressTintColor = UIColor().hexCode(hex: "#FFFFE76D")
            label_spent_percentage.textColor = UIColor().hexCode(hex: "#FFFFE76D")
        } else if percentAmount >= 100 {
            progress_view.progressTintColor = UIColor.red
            label_spent_percentage.textColor = UIColor.red
            label_left_amount.text = "Budget Consumed"
            label_spent_percentage.text = "100%"
        } else {
            progress_view.progressTintColor = UIColor().hexCode(hex: AppColors.PRIMARY_COLOR)
            label_spent_percentage.textColor = UIColor().hexCode(hex: AppColors.PRIMARY_COLOR)
        }
    }
    
}
