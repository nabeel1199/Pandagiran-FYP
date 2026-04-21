

import UIKit

protocol BudgetSetTapListener {
    func onSetBudgetTapped ()
}

class NoBudgetViewCell: UITableViewCell {

    
    @IBOutlet weak var label_set_budget: UILabel!
    @IBOutlet weak var view_set_budget: CardView!
    @IBOutlet weak var iv_category: UIImageView!
    @IBOutlet weak var label_spent: UILabel!
    @IBOutlet weak var label_category: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        label_category.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_spent.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_set_budget.regularFont(fontStyle: .bold, size: Style.dimen.SMALL_TEXT)
        
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    public func configureBudgetWithItem (category: Hkb_category, month: String, year: Int) {
        let spentAmount = BudgetDbUtils.fetchAmountSpent(categoryId: category.categoryId, currentInterval: Constants.MONTHLY, month: month, year: year)
        
        label_category.text = category.title ?? "Category Name Not Found"
        label_spent.text = "You spent \(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(spentAmount), decimal: LocalPrefs.getDecimalFormat()))"
        if let image = UIImage(named: category.box_icon ?? "category"){
            iv_category.image = image.withRenderingMode(.alwaysTemplate)
            iv_category.tintColor = UIColor.lightGray
        } else {
            iv_category.image = UIImage(named: "category")
        }
//        iv_category.image = UIImage(named: category.box_icon ?? "no-image")?.withRenderingMode(.alwaysTemplate)
//        iv_category.tintColor = UIColor.lightGray
    }
    
   
}
