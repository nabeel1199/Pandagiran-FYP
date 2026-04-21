

import UIKit

class CategoryBreakdownViewCell: UICollectionViewCell {

    @IBOutlet weak var btn_menu: UIButton!
    @IBOutlet weak var iv_category: CircularImageView!
    @IBOutlet weak var progress_view: UIProgressView!
    @IBOutlet weak var label_category: UILabel!
    @IBOutlet weak var label_total_budget_spent: UILabel!
    
    @IBOutlet weak var label_left_amount: UILabel!
    @IBOutlet weak var label_left: UILabel!
    @IBOutlet weak var label_total_amount: UILabel!
    @IBOutlet weak var label_spent_amount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        progress_view.layer.cornerRadius = 5.0
        progress_view.layer.masksToBounds = true
        
    }
    
    public func configureCategoryDetailsWithItem (category: Hkb_category, passedInterval: String, month: String, year: Int) {
        let currency = LocalPrefs.getUserCurrency()
        let spentAmount = BudgetDbUtils.fetchAmountSpent(categoryId: category.categoryId , currentInterval: passedInterval, month: month, year: year)
        let totalAmount = BudgetDbUtils.fetchBudgetAmount(categoryId: category.categoryId , currentInterval: passedInterval, month: month, year: year)
        let leftAmount = totalAmount + spentAmount
        let progressValue = spentAmount / totalAmount
        
        iv_category.image = UIImage(named: category.box_icon!)?.withRenderingMode(.alwaysTemplate)
        iv_category.tintColor = UIColor.lightGray
        label_category.text = category.title!
        label_spent_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: abs(spentAmount), decimal: LocalPrefs.getDecimalFormat()))"
        label_total_amount.text = "/\(Utils.formatDecimalNumber(number: abs(totalAmount), decimal: LocalPrefs.getDecimalFormat()))"
        label_left_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: leftAmount, decimal: LocalPrefs.getDecimalFormat()))"
        progress_view.setProgress(Float(round(progressValue)), animated: true)
    }

}
