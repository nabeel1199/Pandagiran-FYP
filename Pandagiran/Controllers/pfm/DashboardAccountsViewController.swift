

import UIKit

class DashboardAccountsViewController: BaseViewController {
    
    @IBOutlet weak var collection_view_accounts: UICollectionView!
    
    private let nibAccountName = "AccountsViewCell"
    private var arrayOfAccounts : Array<Hkb_account> = []
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAccounts()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        initVariables()
        initUI()
        
        
        
    }
    
    private func initVariables () {
        
        collection_view_accounts.delegate = self
        collection_view_accounts.dataSource = self
        
        
        initNibs()
    }
    
    private func initUI () {
        self.viewBackgroundColor = .white
    }
    
    private func initNibs () {
        let nibAccount = UINib(nibName: nibAccountName, bundle: nil)
        collection_view_accounts.register(nibAccount, forCellWithReuseIdentifier: nibAccountName)
    }
    
    private func calculateClosingBalance (index : Int, accountId: Int64) -> Double {
        let month = Utils.getCurrentMonth()
        let year = Utils.getCurrentYear()

        let sum = ActivitiesDbUtils.getClosingBalance(accountId: accountId, categoryId: 0, type: "" ,firstValue: false , currentInterval: Constants.ALL_TIME, month: "", year: year)
        
        return sum
    }

    private func fetchAccounts () {
        arrayOfAccounts.removeAll()
        let accountsArray = QueryUtils.fetchAccounts(accountType: [])
        
        for i in 0 ..< accountsArray.count {
            accountsArray[i].balance_amount = ActivitiesDbUtils.getAccountBalance(accountID: accountsArray[i].account_id) + accountsArray[i].openingbalance
        }
        
        arrayOfAccounts = accountsArray.sorted { (obj1 , obj2) -> Bool in
            return Float(obj1.balance_amount) > Float(obj2.balance_amount)
        }

        DispatchQueue.main.async {
            self.collection_view_accounts.reloadData()
        }
    }
    
    @IBAction func onViewAllTapped(_ sender: Any) {
        let allAccountsVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ALL_ACCOUNTS) as! AccountBalancesViewController
        self.navigationController?.pushViewController(allAccountsVC, animated: true)
    }
    

}

extension DashboardAccountsViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrayOfAccounts.count >= 5 {
            return 6
        } else {
            return arrayOfAccounts.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collection_view_accounts.dequeueReusableCell(withReuseIdentifier: nibAccountName, for: indexPath) as! AccountsViewCell
        
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "bg_card_small")!)
        cell.layer.cornerRadius = 5.0
        cell.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        cell.layer.borderWidth = 1.0
        
        if indexPath.row == (collectionView.numberOfItems(inSection: 0) - 1) {
            cell.view_add_account.isHidden = false
            cell.bgView.isHidden = true
      
        } else {
            cell.view_add_account.isHidden = true
            cell.bgView.isHidden = false
  
            
            
            let account = arrayOfAccounts[indexPath.row]
            let openingBalance = calculateClosingBalance(index: indexPath.row, accountId: account.account_id) + account.openingbalance
            cell.configureAccountWithItem(account : account, balance: openingBalance)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if indexPath.row == (collectionView.numberOfItems(inSection: 0) - 1) {
            let navController = UINavigationController()
            let addAccountVC = UIUtils.getStoryboard(name:ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_ACCOUNT) as! AddAccountViewController
            navController.viewControllers = [addAccountVC]
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        } else {
            let activitiesVC = getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACTIVITY_PAGE) as! ActivityPageViewController
            if let accountType = arrayOfAccounts[indexPath.row].acctype {
                activitiesVC.accountType = accountType
            }
            let intervalIndex = Utils.getInitialIntervalIndex(currentInterval: LocalPrefs.getCurrentInterval())
            activitiesVC.intervalIndex = intervalIndex
            activitiesVC.accountId = arrayOfAccounts[indexPath.row].account_id
            self.navigationController?.pushViewController(activitiesVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collection_view_accounts.frame.width / 3.2
        let height = 60

        return CGSize(width: width, height: CGFloat(height))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let parentView = self.parent as? DashboardViewController {
            parentView.view_accounts_height.constant = self.collection_view_accounts.contentSize.height
        }
    }
    
}
