

import UIKit
import XLPagerTabStrip
import SwiftyJSON
import Alamofire

class BudgetViewController: BaseViewController {

    @IBOutlet weak var extendedViewHeight: NSLayoutConstraint!
    @IBOutlet weak var totalBudgetHeight: NSLayoutConstraint!
    @IBOutlet weak var view_total_budget: CardView!
    @IBOutlet weak var view_placeholder_budget: UIView!
    @IBOutlet weak var budgetTableHeight: NSLayoutConstraint!
    @IBOutlet weak var label_no_budget: UILabel!
    @IBOutlet weak var noBudgetTableHeight: NSLayoutConstraint!
    @IBOutlet weak var table_view_no_budget: UITableView!
    @IBOutlet weak var label_create_new: UILabel!
    @IBOutlet weak var label_my_budgets: CustomFontLabel!
    @IBOutlet weak var label_left_amount: UILabel!
    @IBOutlet weak var label_left: UILabel!
    @IBOutlet weak var label_total_budget: UILabel!
    @IBOutlet weak var label_budget_spent_amount: UILabel!
    @IBOutlet weak var label_remaining_amount: UILabel!
    @IBOutlet weak var view_progress_aggregate: UIProgressView!
    @IBOutlet weak var view_create_budget: CardView!
    @IBOutlet weak var table_view_budgets: UITableView!
    
    private var noBudgetCategories : Array<Hkb_category> = []
    private var arrayOfCategories : Array<Hkb_category> = []
    private let nibBudgetName = "BudgetViewCell"
    private let nibNoBudgetName = "NoBudgetViewCell"
    
    public var year = 2019
    public var tabTitle = ""
    public var intervalIndex = 0
    public var month : String = ""
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchBudgets(month: month, year: year, interval: Constants.MONTHLY)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        
    }

    private func initVariables () {
        initNibs()
        table_view_budgets.delegate = self
        table_view_budgets.dataSource = self
        
        table_view_no_budget.delegate = self
        table_view_no_budget.dataSource = self
        
        let createTapGesture = UITapGestureRecognizer(target: self, action: #selector(onCreateBudgetTapped))
        view_create_budget.addGestureRecognizer(createTapGesture)
    }
    
    private func initUI () {
        view_progress_aggregate.layer.cornerRadius = 5
        view_progress_aggregate.clipsToBounds = true
        self.view.backgroundColor = UIColor.clear
        
        label_total_budget.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_budget_spent_amount.regularFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_remaining_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_left.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_left_amount.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_my_budgets.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_create_new.regularFont(fontStyle: .bold, size: Style.dimen.SMALL_TEXT)
        label_no_budget.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
    }
    
    private func initNibs () {
        let nibBudget = UINib(nibName: nibBudgetName, bundle: nil)
        let nibBoBudget = UINib(nibName: nibNoBudgetName, bundle: nil)
        table_view_budgets.register(nibBudget, forCellReuseIdentifier: nibBudgetName)
        table_view_no_budget.register(nibBoBudget, forCellReuseIdentifier: nibNoBudgetName)
    }
    
    private func fetchBudgets (month: String, year: Int, interval: String) {
        arrayOfCategories.removeAll()
        noBudgetCategories.removeAll()
        var spentAmount : Double = 0
        var progressValue : Double = 0
   
        
        let totalBudgetAmount = BudgetDbUtils.fetchBudgetAmount(categoryId: 0, currentInterval: Constants.MONTHLY, month: month, year: year)
        
        
        DispatchQueue.global(qos: .background).async {
            let categoriesArray = QueryUtils.fetchCategories(type: Constants.EXPENSE)
            
            for i in 0 ..< categoriesArray.count {
                let budgetAmount = BudgetDbUtils.fetchBudgetAmount(categoryId: categoriesArray[i].categoryId, currentInterval: Constants.MONTHLY, month: month, year: year)
                
                
                
                if budgetAmount > 0 {
                    self.arrayOfCategories.append(categoriesArray[i])
                    // fetch spent amount for only budget set categories
                    spentAmount += BudgetDbUtils.fetchAmountSpent(categoryId: categoriesArray[i].categoryId, currentInterval: Constants.MONTHLY, month: month, year: year)
                } else {
                    self.noBudgetCategories.append(categoriesArray[i])
                }
            }
            
            DispatchQueue.main.async {
                let totalLeftAmount = totalBudgetAmount - abs(spentAmount)
                
                if totalBudgetAmount != 0 {
                    progressValue = abs(spentAmount) / totalBudgetAmount
                }
    
                self.label_budget_spent_amount.text = Utils.formatDecimalNumber(number: abs(spentAmount), decimal: LocalPrefs.getDecimalFormat())
                self.label_remaining_amount.text = "/\(Utils.formatDecimalNumber(number: totalBudgetAmount, decimal: 0))"
                self.label_left_amount.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: totalLeftAmount, decimal: 0))"
                self.view_progress_aggregate.setProgress(Float(progressValue), animated: true)
                
                self.table_view_budgets.reloadData()
                self.table_view_no_budget.reloadData()
                self.showPlaceholder()
            }
        }
        

    
   
    }
    
    private func showPlaceholder () {
        if arrayOfCategories.count == 0 {
            view_placeholder_budget.isHidden = false
            totalBudgetHeight.constant = 0
            view_total_budget.isHidden = true
            budgetTableHeight.constant = 200
            extendedViewHeight.constant = 0
            table_view_budgets.isHidden = true
        } else {
            view_placeholder_budget.isHidden = true
            totalBudgetHeight.constant = 100
            view_total_budget.isHidden = false
            budgetTableHeight.constant = 0
            extendedViewHeight.constant = 60
            table_view_budgets.isHidden = false
        }
    }
    
    @objc private func onCreateBudgetTapped () {
        let addBudgetVC = getStoryboard(name: ViewIdentifiers.SB_BUDGET).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_BUDGET) as! AddBudgetViewController
        addBudgetVC.budgetMonth = Int(month)!
        let navController = UINavigationController()
        navController.viewControllers = [addBudgetVC]
        navController.modalPresentationStyle = .currentContext
        self.present(navController, animated: true, completion: nil)
    }
}

extension BudgetViewController : IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabTitle)
    }
}

extension BudgetViewController: UITableViewDelegate, UITableViewDataSource {

    
    
//    override func viewWillLayoutSubviews() {
//
//        budgetTableHeight.constant = table_view_budgets.contentSize.height
//        noBudgetTableHeight.constant = table_view_no_budget.contentSize.height
//
//        print("HEIGHT : " , table_view_no_budget.contentSize.height)
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == table_view_budgets {
            return arrayOfCategories.count
        } else {
            return noBudgetCategories.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == table_view_budgets {
            let cell = tableView.dequeueReusableCell(withIdentifier: nibBudgetName, for: indexPath) as! BudgetViewCell
            
            cell.configureBugetsWithItem(category: arrayOfCategories[indexPath.row], month: month, year: year)
            

            
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: nibNoBudgetName, for: indexPath) as! NoBudgetViewCell
            
            cell.configureBudgetWithItem(category: noBudgetCategories[indexPath.row], month: month, year: year)
            
            cell.view_set_budget.tag = indexPath.row
            let setBudgetTap = UITapGestureRecognizer(target: self, action: #selector(onBudgetSetTapped))
            cell.view_set_budget.addGestureRecognizer(setBudgetTap)
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == table_view_budgets {            
            let activitiesVC = getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACTIVITY_PAGE) as! ActivityPageViewController
            activitiesVC.passedInterval = Constants.MONTHLY
            activitiesVC.categoryId = arrayOfCategories[indexPath.row].categoryId
            activitiesVC.intervalIndex = self.intervalIndex
            self.navigationController?.pushViewController(activitiesVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == table_view_budgets {
            DispatchQueue.main.async {
                self.budgetTableHeight.constant = self.table_view_budgets.contentSize.height
            }
        }
        else
        {
            DispatchQueue.main.async {
                self.noBudgetTableHeight.constant = self.table_view_no_budget.contentSize.height
            }
        }
    }
    
    @objc private func onBudgetSetTapped (sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            let navController = UINavigationController()
            let addBudgetVC = getStoryboard(name: ViewIdentifiers.SB_BUDGET).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_BUDGET) as! AddBudgetViewController
            navController.viewControllers = [addBudgetVC]
            addBudgetVC.categoryId = noBudgetCategories[index].categoryId
            addBudgetVC.budgetMonth = Int(month)!
            addBudgetVC.budgetYear = year
            addBudgetVC.isUpdate = false
            navController.modalPresentationStyle = .currentContext
            self.present(navController, animated: true, completion: nil)
        }
    }
    
}
