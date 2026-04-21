

import UIKit
import XLPagerTabStrip
import Alamofire
import SwiftyJSON
import Instructions

class PfmLandingViewController: BaseViewController {

    @IBOutlet weak var view_all_placeholder_button: GradientView!
    @IBOutlet weak var view_place_holder_transactions: UIView!
    @IBOutlet weak var view_expense: UIView!
    @IBOutlet weak var view_income: UIView!
    @IBOutlet weak var btn_view_transactions: UIButton!
    @IBOutlet weak var label_recent_transactions: CustomFontLabel!
    @IBOutlet weak var label_expense: UILabel!
    @IBOutlet weak var label_income: UILabel!
    @IBOutlet weak var label_expense_amount: UILabel!
    @IBOutlet weak var label_events: UILabel!
    @IBOutlet weak var label_income_amount: UILabel!
    @IBOutlet weak var label_history: UILabel!
    @IBOutlet weak var label_goal: UILabel!
    @IBOutlet weak var label_budget: UILabel!
    @IBOutlet weak var view_budgets: UIView!
    @IBOutlet weak var view_goals: UIView!
    @IBOutlet weak var view_history: UIView!
    @IBOutlet weak var view_events: UIView!
    @IBOutlet weak var collection_view_accounts: UICollectionView!
    @IBOutlet weak var accountsCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var view_income_expense: CardView!
    @IBOutlet weak var table_view_transactions: UITableView!
    @IBOutlet weak var trasactionsTableHeight: NSLayoutConstraint!
    
    private let nibPersonName = "PersonLandingViewCell"
    private let nibBankName = "BankLandingViewCell"
    private let nibTransactionName = "TransactionViewCell"
    private let nibAddAccountName = "AddAccountViewCell"
    private var arrayOfAccounts: Array<Hkb_account> = []
    private var arrayOfVouchers: Array<Hkb_voucher> = []
    private var netWorth : Double = 0
    private let interval = LocalPrefs.getCurrentInterval()

    private let requestGroup = DispatchGroup()
    private let coachMarksController = CoachMarksController()
    
    public var tabTitle = ""
    public var intervalIndex = 0
    public var month : String = ""
    public var year = Utils.getCurrentYear()
    
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        initVariables()

//        setIncomeAndExpenseAmount()
//        fetchAccounts(accountType: [])
//
//        fetchTransactions()
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        setIncomeAndExpenseAmount()
        fetchAccounts(accountType: [])

        fetchTransactions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        
        if !LocalPrefs.getIsPfmOnboardingShown() {
            if intervalIndex != 0 {
                self.coachMarksController.start(in: .window(over: self))
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        self.table_view_transactions.frame.size = self.table_view_transactions.contentSize
        self.trasactionsTableHeight.constant = self.table_view_transactions.contentSize.height

    }
    
    private func initVariables () {
        
        self.coachMarksController.overlay.isUserInteractionEnabled = true
        self.coachMarksController.dataSource = self
        initNibs()
        
        table_view_transactions.delegate = self
        table_view_transactions.dataSource = self
        
        collection_view_accounts.delegate = self
        collection_view_accounts.dataSource = self
        
        let budgetTapGest = UITapGestureRecognizer(target: self, action: #selector(onBudgetTapped))
        view_budgets.addGestureRecognizer(budgetTapGest)
        
        let atmTapGest = UITapGestureRecognizer(target: self, action: #selector(onAtmTapped))
        view_events.addGestureRecognizer(atmTapGest)
        
        let eventTapGest = UITapGestureRecognizer(target: self, action: #selector(onEventTapped))
        view_goals.addGestureRecognizer(eventTapGest)
        
        let activityTapGest = UITapGestureRecognizer(target: self, action: #selector(onActivitiesTapped))
        view_history.addGestureRecognizer(activityTapGest)
    }
    
    private func initUI () {
        let incomeTapGest = UITapGestureRecognizer(target: self, action: #selector(onIncomeTapped))
        view_income.addGestureRecognizer(incomeTapGest)
        
        let expenseTapGest = UITapGestureRecognizer(target: self, action: #selector(onExpenseTapped))
        view_expense.addGestureRecognizer(expenseTapGest)
        
        label_budget.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_goal.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_history.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_events.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_income_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_income.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_expense.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_expense_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_recent_transactions.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        btn_view_transactions.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
    }
    
    
    private func initNibs () {
        let nibBank = UINib(nibName: nibBankName, bundle: nil)
        let nibPerson = UINib(nibName: nibPersonName, bundle: nil)
        let nibTransaction = UINib(nibName: nibTransactionName, bundle: nil)
        let nibAddAccount = UINib(nibName: nibAddAccountName, bundle: nil)
        
        table_view_transactions.register(nibTransaction, forCellReuseIdentifier: nibTransactionName)
        collection_view_accounts.register(nibPerson, forCellWithReuseIdentifier: nibPersonName)
        collection_view_accounts.register(nibAddAccount, forCellWithReuseIdentifier: nibAddAccountName)
        collection_view_accounts.register(nibBank, forCellWithReuseIdentifier: nibBankName)
    }
    
    func setIncomeAndExpenseAmount () {
        let currency = LocalPrefs.getUserCurrency()
        let inflowAmount = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.INCOME, currentInterval: LocalPrefs.getCurrentInterval(), month: month, year: year)
        let outflowAmount = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.EXPENSE, currentInterval: LocalPrefs.getCurrentInterval(), month: month, year: year)
        
        label_income_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: inflowAmount, decimal: LocalPrefs.getDecimalFormat()))"
        label_expense_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: abs(outflowAmount), decimal: LocalPrefs.getDecimalFormat()))"
    }
    
    private func fetchAccounts (accountType: [String]) {
        arrayOfAccounts.removeAll()
        arrayOfAccounts = QueryUtils.fetchAllAccounts()
        self.collection_view_accounts.reloadData()
    }
    
    private func fetchTransactions () {
        arrayOfVouchers.removeAll()
        arrayOfVouchers = ActivitiesDbUtils.fetchVouchers(accountId: 0,
                                                          categoryId: 0,
                                                          type: "",
                                                          currentInterval: LocalPrefs.getCurrentInterval(),
                                                          month: month,
                                                          year: year,
                                                          offset: 0,
                                                          limit: 4)
        
        
        showPlaceholder()
        self.table_view_transactions.layoutIfNeeded()
        self.table_view_transactions.reloadData()
        
        
        
    }
    
    private func calculateClosingBalance (accountId: Int64) -> Double {
        var sum1 : Double = 0
        let interval = LocalPrefs.getCurrentInterval()
        if interval.lowercased() != Constants.YEARLY.lowercased() && interval.lowercased() != Constants.ALL_TIME.lowercased() {
            sum1 = ActivitiesDbUtils.getClosingBalance(accountId: accountId, categoryId: 0, type: "", firstValue: true , currentInterval: LocalPrefs.getCurrentInterval(), month: month, year: year)
        }
        
        let sum2 = ActivitiesDbUtils.getClosingBalance(accountId: accountId, categoryId: 0, type: "" ,firstValue: false , currentInterval: LocalPrefs.getCurrentInterval(), month: "12", year: year)
        return (sum1 + sum2)
    }
    
    private func fetchAllAccountsBalance () -> Double {
        var sum : Double = 0
        
        for account in arrayOfAccounts {
            sum += calculateClosingBalance(accountId: Int64(account.account_id))
        }
        
        return sum
    }
    
    private func showPlaceholder () {

//        self.table_view_transactions.frame.size = self.table_view_transactions.contentSize
        self.trasactionsTableHeight.constant = self.table_view_transactions.contentSize.height
        if arrayOfVouchers.count == 0 {
            view_place_holder_transactions.isHidden = false
            view_all_placeholder_button.isHidden = true
        } else {
            view_place_holder_transactions.isHidden = true
            view_all_placeholder_button.isHidden = false
        }
    }
    
    private func navigateToActivitiesVC (accountId: Int64, vchType: String) {
        let acitivityPageVC = getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACTIVITY_PAGE) as! ActivityPageViewController
        acitivityPageVC.intervalIndex = self.intervalIndex
        acitivityPageVC.accountId = accountId
        acitivityPageVC.vchType = vchType
        self.navigationController?.pushViewController(acitivityPageVC, animated: true)
    }
    
    @objc private func onIncomeTapped () {
        navigateToActivitiesVC(accountId: 0, vchType: Constants.INCOME)
    }
    
    @objc private func onExpenseTapped () {
        navigateToActivitiesVC(accountId: 0, vchType: Constants.EXPENSE)
    }
    
    @objc private func onBudgetTapped () {
        let budgetVC = UIUtils.getStoryboard(name: ViewIdentifiers.SB_BUDGET).instantiateViewController(withIdentifier: "BudgetPageVC")
        self.navigationController?.pushViewController(budgetVC, animated: true)
    }

    @objc private func onAtmTapped () {
        let transactionVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: "TransactionLoggingVC") as! TransactionLoggingViewController
        transactionVC.isExpense = 2
        transactionVC.useCaseType = "ATM"
        transactionVC.vchType = "Transfer"
        let navController = UINavigationController()
        navController.viewControllers = [transactionVC]
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc private func onEventTapped () {
        let eventsVC = UIUtils.getStoryboard(name: ViewIdentifiers.SB_EVENT).instantiateViewController(withIdentifier: "EventsVC")
        self.navigationController?.pushViewController(eventsVC, animated: true)
    }
    

 
    @objc private func onActivitiesTapped () {
        navigateToActivitiesVC(accountId: 0, vchType: "")
    }
    
    @IBAction func onAllTransactionsTapped(_ sender: Any) {
        navigateToActivitiesVC(accountId: 0, vchType: "")
    }
    
}

extension PfmLandingViewController: UITableViewDelegate, UITableViewDataSource {
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        self.table_view_transactions.frame.size = self.table_view_transactions.contentSize
//        self.trasactionsTableHeight.constant = self.table_view_transactions.contentSize.height
//
//    }
//    override func viewWillLayoutSubviews() {
//        super.updateViewConstraints()
//
//        table_view_transactions.frame.size = table_view_transactions.contentSize
//        self.trasactionsTableHeight.constant = self.table_view_transactions.contentSize.height
//
//
////        if arrayOfVouchers.count > 0 {
////            self.trasactionsTableHeight.constant = self.table_view_transactions.contentSize.height
//////           self.trasactionsTableHeight?.constant = self.table_view_transactions.contentSize.height
////        }
//    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return arrayOfVouchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: nibTransactionName, for: indexPath) as! TransactionViewCell
        
        cell.configureWithItem(accountId: 0, voucher: arrayOfVouchers[indexPath.row])
        
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let voucher = arrayOfVouchers[indexPath.row]
        
        if voucher.use_case != "Savings" && voucher.vch_description != "Transfer for Account Deletion" {
            let transactionVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: ViewIdentifiers.VC_TRANSACTION_DETAILS) as! TransactionDetailsViewController
            transactionVC.viewVoucher = voucher
            transactionVC.showViewMode = true
            self.navigationController?.pushViewController(transactionVC, animated: true)
        } else if voucher.vch_description == "Transfer for Account Deletion" {
            UIUtils.showAlert(vc: self, message: "System created transactions can not be modify")
        } else {
            UIUtils.showAlert(vc: self, message: "Saving transactions can only be modified from savings module")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.trasactionsTableHeight.constant = self.table_view_transactions.contentSize.height
        }
    }
}

extension PfmLandingViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GenericPopupSelection {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfAccounts.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if indexPath.row == 0
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibAddAccountName, for: indexPath) as! AddAccountViewCell
            
            
            return cell
        }
        
        else if indexPath.row == 1
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibBankName, for: indexPath) as! BankLandingViewCell
            
            let totalOpeningBalance = QueryUtils.fetchOpeningBalanceAllAccounts()
            let closingBalance = fetchAllAccountsBalance() + totalOpeningBalance
            cell.label_balance_amount.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: closingBalance, decimal: LocalPrefs.getDecimalFormat()))"
            cell.configureAccountWithItem(balanceAmount: closingBalance, type: "All", account: nil)
            
            cell.btn_menu.addTarget(self, action: #selector(onBankCellMenuTapped(sender:)), for: .touchUpInside)
            cell.btn_menu.tag = indexPath.row
            cell.btn_menu.isHidden = true
            
            return cell
        }
            
            
        else
        {
            let account = arrayOfAccounts[indexPath.row - 2]
            var accountType = ""
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibBankName, for: indexPath) as! BankLandingViewCell
            
            if account.acctype != nil {
                accountType = account.acctype!
            }
            
            var closingBalance = calculateClosingBalance(accountId: account.account_id)
            closingBalance = closingBalance + account.openingbalance
            cell.configureAccountWithItem(balanceAmount: closingBalance, type: accountType, account: account)
            
            cell.btn_menu.addTarget(self, action: #selector(onBankCellMenuTapped(sender:)), for: .touchUpInside)
            cell.btn_menu.tag = indexPath.row - 2
            cell.btn_menu.isHidden = true
                
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let activitiesVC = getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACTIVITY_PAGE) as! ActivityPageViewController
        
        if indexPath.row == 0 {
            let navController = UINavigationController()
            let addAccountVC = UIUtils.getStoryboard(name:ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_ACCOUNT) as! AddAccountViewController
            navController.viewControllers = [addAccountVC]
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            let allAccountsVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ALL_ACCOUNTS) as! AccountBalancesViewController
//            allAccountsVC.passedInterval = LocalPrefs.getCurrentInterval()
//            allAccountsVC.month = self.month
//            allAccountsVC.year = self.year
            self.navigationController?.pushViewController(allAccountsVC, animated: true)
            
            
        } else if indexPath.row > 1 {
            if let accountType = arrayOfAccounts[indexPath.row - 2].acctype {
                activitiesVC.accountType = accountType
            }
            
            activitiesVC.passedInterval = LocalPrefs.getCurrentInterval()
            activitiesVC.intervalIndex = self.intervalIndex
            activitiesVC.accountId = arrayOfAccounts[indexPath.row - 2].account_id
            self.navigationController?.pushViewController(activitiesVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height: CGFloat = 150.0
        let width: CGFloat?

        if indexPath.row == 0 {
            width = 100
        } else {
            width = 240
        }
        
        return CGSize(width: width!, height: height)
    }
    

    
    @objc private func onBankCellMenuTapped(sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: {action in
            let index = sender.tag
            let navController = UINavigationController()
            let editAccountVC = self.getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACCOUNT_BALANCE) as! AccountBalanceViewController
            editAccountVC.editAccount = self.arrayOfAccounts[index]
            navController.viewControllers = [editAccountVC]
            self.present(navController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: {action in
            let deletePopup = GenericPopup()
            deletePopup.delegate = self
            deletePopup.btnText = "DELETE ACCOUNT"
            deletePopup.popupTitle = "DELETE ACCOUNT"
            deletePopup.message = "Are you sure you want to delete this account?"
            deletePopup.objectIndex = sender.tag
            self.presentPopupView(popupView: deletePopup)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onButtonTapped(index: Int, objectIndex: Int) {
        let account = arrayOfAccounts[objectIndex]
        account.active = 0
        arrayOfAccounts.remove(at: objectIndex)
        DbController.saveContext()
        UIUtils.showSnackbar(message: "Account deleted successfully")
        self.collection_view_accounts.reloadData()
    }
}

extension PfmLandingViewController : IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabTitle)
    }
}

extension PfmLandingViewController : CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 5
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        
       
        
        switch index {
            
        case 0:
            let pof = collection_view_accounts.cellForItem(at: IndexPath(item: 0, section: 0))
            return coachMarksController.helper.makeCoachMark(for: pof)
        case 1:
            let pof = view_budgets
            return coachMarksController.helper.makeCoachMark(for: pof)
        case 2:
            let pof = view_goals
            return coachMarksController.helper.makeCoachMark(for: pof)
        case 3:
            let pof = view_history
            return coachMarksController.helper.makeCoachMark(for: pof)
        default:
            LocalPrefs.setIsPfmOnboardingShown(isShown: true)
            
            let pof = view_events
            return coachMarksController.helper.makeCoachMark(for: pof)
        }
  
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        
        coachViews.arrowView?.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        coachViews.bodyView.hintLabel.textColor = UIColor.black
        coachViews.bodyView.nextLabel.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        coachViews.bodyView.hintLabel.font = UIFont(name: Style.font.REGULAR_FONT, size: 12.0)
        coachViews.bodyView.nextLabel.font = UIFont(name: "\(Style.font.REGULAR_FONT)-Bold", size: 14.0)
        
        
        switch index {
       
        case 0:
            coachViews.bodyView.hintLabel.text = "An account can be bank, cash or a person with whom you want to record transactions"
            coachViews.bodyView.nextLabel.text = "NEXT"
            break
        case 1:
            coachViews.bodyView.hintLabel.text = "Create budgets for specific categories so that you can track your expense"
            coachViews.bodyView.nextLabel.text = "NEXT"
        case 2:
            coachViews.bodyView.hintLabel.text = "Create and monitor your saving goals, Hysab Kytab will help you acheive them"
            coachViews.bodyView.nextLabel.text = "NEXT"
        case 3:
            coachViews.bodyView.hintLabel.text = "We keep track of all your past transactions so that you dont have to"
            coachViews.bodyView.nextLabel.text = "NEXT"
        default:
            coachViews.bodyView.hintLabel.text = "Tracking expense against a real life event? Create them here to combine all related transactions"
            coachViews.bodyView.nextLabel.text = "GOT IT"
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
//    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
//
//
//        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
//
//
//        coachViews.arrowView?.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
//        coachViews.bodyView.hintLabel.textColor = UIColor.black
//        coachViews.bodyView.nextLabel.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
//        coachViews.bodyView.hintLabel.font = UIFont(name: Style.font.REGULAR_FONT, size: 12.0)
//        coachViews.bodyView.nextLabel.font = UIFont(name: "\(Style.font.REGULAR_FONT)-Bold", size: 14.0)
//
//
//        switch index {
//
//        case 0:
//            coachViews.bodyView.hintLabel.text = "An account can be bank, cash or a person with whom you want to record transactions"
//            coachViews.bodyView.nextLabel.text = "NEXT"
//            break
//        case 1:
//            coachViews.bodyView.hintLabel.text = "Create budgets for specific categories so that you can track your expense"
//            coachViews.bodyView.nextLabel.text = "NEXT"
//        case 2:
//            coachViews.bodyView.hintLabel.text = "Create and monitor your saving goals, Hysab Kytab will help you acheive them"
//            coachViews.bodyView.nextLabel.text = "NEXT"
//        case 3:
//            coachViews.bodyView.hintLabel.text = "We keep track of all your past transactions so that you dont have to"
//            coachViews.bodyView.nextLabel.text = "NEXT"
//        default:
//            coachViews.bodyView.hintLabel.text = "Tracking expense against a real life event? Create them here to combine all related transactions"
//            coachViews.bodyView.nextLabel.text = "GOT IT"
//        }
//
//        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
//    }
}
