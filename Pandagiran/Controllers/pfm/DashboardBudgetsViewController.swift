

import UIKit
import Charts

class DashboardBudgetsViewController: BaseViewController {

    @IBOutlet weak var view_add_budget: UILabel!
    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var table_view_budgets: UITableView!
    
    private let nibBudget = "BudgetDashboardViewCell"
    private let arrayOfColors = ["f8c826", "f56c6c", "39afa7"]
    private var arrayOfCategories : Array<Hkb_category> = []
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.fetchAllCategories()
//        showPlaceholder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()

   
    }
    
    private func initVariables () {
        initNibBudgets()
    }
    
    private func initUI () {
        let addBudgetGest = UITapGestureRecognizer(target: self, action: #selector(onAddBudgetTapped))
        view_add_budget.addGestureRecognizer(addBudgetGest)
    }

    private func initNibBudgets () {
        let nib = UINib(nibName: nibBudget, bundle: nil)
        table_view_budgets.register(nib, forCellReuseIdentifier: nibBudget)
        
        table_view_budgets.delegate = self
        table_view_budgets.dataSource = self
    }
    
    func fetchAllCategories(){
        arrayOfCategories.removeAll()
        let month = Utils.getCurrentMonth()
        let year = Utils.getCurrentYear()
        let categoriesArray = QueryUtils.fetchCategories(type: Constants.EXPENSE)
        
        for i in 0 ..< categoriesArray.count {
            let spentAmount = abs(BudgetDbUtils.fetchAmountSpent(categoryId: categoriesArray[i].categoryId, currentInterval: Constants.MONTHLY, month: String(month), year: year))
            let budgetAmount = BudgetDbUtils.fetchBudgetAmount(categoryId: categoriesArray[i].categoryId , currentInterval: Constants.MONTHLY, month: String(month), year: year)
            
            if budgetAmount > 0 {
                categoriesArray[i].budgetAmount = spentAmount
                arrayOfCategories.append(categoriesArray[i])
            }
            
        }
        self.showPlaceholder()
        self.table_view_budgets.reloadData()
//        arrayOfCategories = categoriesArray.sorted { (obj1 , obj2) -> Bool in
//            return Float(obj1.budgetAmount!) < Float(obj2.budgetAmount!)
//        }
    }
    
    private func showPlaceholder () {
        if arrayOfCategories.count == 0 {
            view_placeholder.isHidden = false
        } else {
            view_placeholder.isHidden = true
        }
    }

    @objc private func onAddBudgetTapped () {
        let addBudgetVC = getStoryboard(name: ViewIdentifiers.SB_BUDGET).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_BUDGET) as! AddBudgetViewController
        let navController = UINavigationController()
        navController.viewControllers = [addBudgetVC]
//        navController.modalPresentationStyle = .overCurrentContext
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func onViewAllTapped(_ sender: Any) {
        let budgetVC = getStoryboard(name: ViewIdentifiers.SB_BUDGET).instantiateViewController(withIdentifier: ViewIdentifiers.VC_BUDGET_PAGE)
        self.navigationController?.pushViewController(budgetVC, animated: true)
    }
}


extension DashboardBudgetsViewController : UITableViewDelegate, UITableViewDataSource {
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayOfCategories.count > 3 {
           return 3
        } else {
            return arrayOfCategories.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibBudget, for: indexPath) as! BudgetDashboardViewCell
        
     
        
        
        cell.configureBudgetsWithItem(category: arrayOfCategories[indexPath.row])
        

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let parentView = self.parent as? DashboardViewController {
            parentView.view_budget_height.constant = self.table_view_budgets.contentSize.height
        }
        
    }
}
