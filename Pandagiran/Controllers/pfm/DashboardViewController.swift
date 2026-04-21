

import UIKit
import Alamofire
import Firebase
import CoreData



class DashboardViewController: BaseViewController  {
    
    @IBOutlet weak var budgetContainer: UIView!
    @IBOutlet weak var label_budget_amount: UILabel!
    @IBOutlet weak var label_budget: UILabel!
    @IBOutlet weak var label_expense_amount: UILabel!
    @IBOutlet weak var label_expense: UILabel!
    @IBOutlet weak var view_budget_height: NSLayoutConstraint!
    @IBOutlet weak var view_expense_height: NSLayoutConstraint!
    @IBOutlet weak var view_accounts_height: NSLayoutConstraint!
    @IBOutlet weak var label_net_worth_amount: UILabel!
    @IBOutlet weak var label_net_worth: UILabel!
    @IBOutlet weak var label_currency_net_worth: UILabel!
    @IBOutlet weak var label_currency_expense: UILabel!
    @IBOutlet weak var label_currency_budget: UILabel!
    @IBOutlet weak var container_view: UIView!
    
    private var incomeAmount : Double = 0
    private var spendingAmount : Double = 0
    private var accountBalance : Double = 0
    private var totalBudget : Double = 0
    private var spentBudget : Double = 0
    var dasboardBudgetVC = DashboardBudgetsViewController()
//    var nitResponse: Nit?

//    var isPopUpRequired: Bool?
//
//    lazy var backupAlert: BackupAlertView = {
//        let backupAlertview = BackupAlertView()
//
//        return backupAlertview
//    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        dasboardBudgetVC.fetchAllCategories()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        print("Device UDID - \(UIDevice.current.identifierForVendor!.uuidString)")
        print("Email Address - \(LocalPrefs.getUserEmail())")
//        getNITData()

    }
    
//    func getNITData(){
//        NITNetworkCalls.sharedInstance.getPartnerData { responseData in
//            self.nitResponse = responseData
//            print(self.nitResponse)
//
//        } failureHandler: { error in
//            UIUtils.showSnackbarNegative(message: "\(error.localizedDescription)")
//        }
//
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        (self.tabBarController as? TabBarViewController)?.popupAppear()
        incomeAmount = fetchIncomeAmount()
        spendingAmount = fetchSpendingAmount()
        totalBudget = fetchTotalBudget()
        spentBudget = fetchSpentBudget()
        accountBalance = fetchAccountsBalance() + QueryUtils.fetchOpeningBalanceAllAccounts()
        fetchSpendingTitle()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(true)
        (self.tabBarController as? TabBarViewController)?.popupDisappear()
    }
    

    
    private func initUI () {
        self.addSideMenu()
        self.navigationItem.title = "Home"
        self.addDashboardBudget()
    }
    
    
    private func addDashboardBudget(){
//        DashboardBudgetVC
        dasboardBudgetVC = storyboard?.instantiateViewController(withIdentifier: "DashboardBudgetVC") as! DashboardBudgetsViewController //{
            
                addChild(dasboardBudgetVC)
//                controller.view.translatesAutoresizingMaskIntoConstraints = false
                budgetContainer.addSubview(dasboardBudgetVC.view)
                budgetContainer.translatesAutoresizingMaskIntoConstraints = false
        dasboardBudgetVC.view.frame.size.width = budgetContainer.frame.width
        dasboardBudgetVC.view.frame.size.height = budgetContainer.frame.height
        dasboardBudgetVC.fetchAllCategories()
        dasboardBudgetVC.didMove(toParent: self)
//        }
    }
    
    private func fetchTotalBudget()-> Double{
        let month = Utils.getCurrentMonth()
        let year = Utils.getCurrentYear()
        let totalBudgetAmount = BudgetDbUtils.fetchBudgetAmount(categoryId: 0, currentInterval: Constants.MONTHLY, month: String(month), year: year)
        return totalBudgetAmount
    }
    
    private func fetchSpentBudget()-> Double{
        let month = Utils.getCurrentMonth()
        let year = Utils.getCurrentYear()
        let spentAmount = BudgetDbUtils.fetchAmountSpent(categoryId: 0, currentInterval: Constants.MONTHLY, month: String(month), year: year)
        return spentAmount
    }
    
    private func fetchSpendingAmount () -> Double {
        let month = Utils.getCurrentMonth()
        let year = Utils.getCurrentYear()
        return ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.EXPENSE, currentInterval: Constants.MONTHLY, month: String(month), year: year)
        
    }
    
    private func fetchIncomeAmount () -> Double {
        let month = Utils.getCurrentMonth()
        let year = Utils.getCurrentYear()
        return ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.INCOME, currentInterval: Constants.MONTHLY, month: String(month), year: year)
    }
    
    private func fetchSpendingTitle () {
        label_net_worth.text = "What You Have"
        label_currency_net_worth.text = "\(LocalPrefs.getUserCurrency())"
        label_net_worth_amount.text = " \(Utils.formatDecimalNumber(number: accountBalance, decimal: LocalPrefs.getDecimalFormat()))"
        
        label_expense.text = "Your Monthly Expense"
        label_currency_expense.text = "\(LocalPrefs.getUserCurrency())"
        label_expense_amount.text = "\(Utils.formatDecimalNumber(number: abs(spendingAmount), decimal: LocalPrefs.getDecimalFormat()))"
        
        label_budget.text = "Your Budget"
        label_currency_budget.text = "\(LocalPrefs.getUserCurrency())"
        label_budget_amount.text = "\(Utils.formatDecimalNumber(number: abs(spentBudget), decimal: LocalPrefs.getDecimalFormat()))" + "/" + "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(totalBudget), decimal: LocalPrefs.getDecimalFormat()))"
    }
    
    private func fetchAccountsBalance () -> Double {
        var sum : Double = 0
        let arrayOfAccounts = QueryUtils.fetchAllAccounts()
        
        for account in arrayOfAccounts {
            sum += ActivitiesDbUtils.getAccountBalance(accountID: account.account_id)
        }
        
        return sum
    }
    
    @objc private func onSearchTapped () {
        let searchVC = getStoryboard(name: ViewIdentifiers.SB_SEARCH).instantiateViewController(withIdentifier: ViewIdentifiers.VC_GLOBAL_SEARCH) as! GlobalSearchViewController
        let navController = UINavigationController()
        navController.viewControllers = [searchVC]
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc private func onNotificationTapped () {
        let notificationVC = getStoryboard(name: ViewIdentifiers.SB_DASHBOARD).instantiateViewController(withIdentifier: ViewIdentifiers.VC_NOTIFICATION) as! NotificationViewController
        let navController = UINavigationController(rootViewController: notificationVC)
        self.present(navController, animated: false, completion: nil)
    }
    
    @IBAction func onAccountsViewMoreTapped(_ sender: Any) {
//        fatalError()
        let allAccountsVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ALL_ACCOUNTS) as! AccountBalancesViewController
//        let allAccountsVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER) as! AccountBalancesViewController
        self.navigationController?.pushViewController(allAccountsVC, animated: true)
        //        self.navigateToBackupVC()
    }
    
    @IBAction func onExpenseViewMoreTapped(_ sender: Any) {
        let activitiesVC = getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACTIVITY_PAGE) as! ActivityPageViewController
        let intervalIndex = Utils.getInitialIntervalIndex(currentInterval: Constants.MONTHLY)
        activitiesVC.intervalIndex = intervalIndex
        activitiesVC.passedInterval = Constants.MONTHLY
        activitiesVC.vchType = Constants.EXPENSE
        self.navigationController?.pushViewController(activitiesVC, animated: true)
    }
    
    @IBAction func onBudgetViewMoreTapped(_ sender: Any) {
        let budgetVC = getStoryboard(name: ViewIdentifiers.SB_BUDGET).instantiateViewController(withIdentifier: ViewIdentifiers.VC_BUDGET_PAGE)
        self.navigationController?.pushViewController(budgetVC, animated: true)
    }
    
    private func navigateToBackupVC() {
        let backupMainVC = getStoryboard(name: ViewIdentifiers.SB_BACKUP).instantiateViewController(withIdentifier: ViewIdentifiers.VC_BACKMAINVC) as! BackupMainVC
        self.navigationController?.pushViewController(backupMainVC, animated: true)
    }
    
}

