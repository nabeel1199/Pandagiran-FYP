
import UIKit

class BudgetDashboardViewCell: UITableViewCell {

    @IBOutlet weak var label_category_title: UILabel!
    @IBOutlet weak var progress_view: UIProgressView!
    @IBOutlet weak var label_amount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        label_category_title.regularFont(fontStyle: .regular, size: Style.dimen.SMALL_TEXT)
        label_amount.regularFont(fontStyle: .regular, size: Style.dimen.SMALL_TEXT)
        progress_view.layer.cornerRadius = 5
        progress_view.clipsToBounds = true
  
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureBudgetsWithItem (category: Hkb_category) {
        var progressValue : Double = 0
        var percentAmount : Double = 0
        let month = Utils.getCurrentMonth()
        let year = Utils.getCurrentYear()
        let budgetAmount = BudgetDbUtils.fetchBudgetAmount(categoryId: category.categoryId, currentInterval: Constants.MONTHLY, month: String(month), year: year)
        let spentAmount = BudgetDbUtils.fetchAmountSpent(categoryId: category.categoryId, currentInterval: Constants.MONTHLY, month: String(month), year: year)
        
        if budgetAmount != 0 {
            progressValue = (abs(spentAmount) / budgetAmount)
            percentAmount = abs((spentAmount / budgetAmount) * 100)
        }
        
        
        
        
        label_category_title.text = category.title!
        label_amount.text = "\(Utils.getAmountNotation(amount: abs(spentAmount), decimal: 2))/\(Utils.getAmountNotation(amount: budgetAmount, decimal: 2))"
        progress_view.setProgress(Float(progressValue), animated: true)
        progress_view.trackTintColor = UIColor.groupTableViewBackground
        
        if percentAmount > 80 && percentAmount < 100 {
            progress_view.progressTintColor = UIColor().hexCode(hex: "#FFFFE76D")
        } else if percentAmount >= 100 {
            progress_view.progressTintColor = UIColor.red
        } else {
            progress_view.progressTintColor = UIColor().hexCode(hex: AppColors.PRIMARY_COLOR)
        }
        
        
    }
    
}
