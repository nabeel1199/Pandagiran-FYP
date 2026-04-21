

import UIKit

class DialogSelectAccount: UIViewController , UITableViewDelegate , UITableViewDataSource {
    @IBOutlet weak var accountsTableView: UITableView!
    @IBOutlet weak var label_close: UILabel!
    
    // Class Variables
    var accountId : Int64 = 1
    var accountTitle : String = ""
    var accountDelegate : AccountSelectionListener?
    private var sortedArray : Array<Hkb_account> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        
    }
    
    func initVariables() {
        accountsTableView.dataSource = self
        accountsTableView.delegate = self
        
        let nibTimeInterval = UINib(nibName : "VoucherAccountViewCell" , bundle : nil)
        accountsTableView.register(nibTimeInterval, forCellReuseIdentifier: "VoucherAccountsViewCell")
        
        fetchAccounts()
    }
    
    func initUI() {
        overlayBlurredBackgroundView()
        let indexPath = IndexPath(item: Int(accountId) , section : 0)
//        accountsTableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition(rawValue: accountId)!)
    }
    
    private func fetchAccounts () {
        let accountsArray = QueryUtils.fetchAccounts(accountType: [])
        
        for i in 0 ..< accountsArray.count {
            accountsArray[i].balance_amount = ActivitiesDbUtils.getAccountBalance(accountID: accountsArray[i].account_id) + accountsArray[i].openingbalance
        }
        
        sortedArray = accountsArray.sorted { (obj1 , obj2) -> Bool in
            return Float(obj1.balance_amount) > Float(obj2.balance_amount)
        }
    }
    
    func overlayBlurredBackgroundView() {
        
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = self.view.bounds
        blurredBackgroundView.effect = UIBlurEffect(style: .regular)
        blurredBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurredBackgroundView, at: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == sortedArray.count {
            let cell = accountsTableView.dequeueReusableCell(withIdentifier: "VoucherAccountsViewCell", for: indexPath) as! VoucherAccountViewCell
            cell.accountTitle.text = "Add Account"
            cell.accountImage.image = UIImage(named : "ic_add")?.withRenderingMode(.alwaysTemplate)
            cell.accountImage.tintColor = UIColor.black
            cell.bgView.layer.borderColor = UIColor.black.cgColor
            
            return cell
        } else {
            let cell = accountsTableView.dequeueReusableCell(withIdentifier: "VoucherAccountsViewCell", for: indexPath) as! VoucherAccountViewCell
            
            let account = sortedArray[indexPath.row]
            
            if account.balance_amount >= 0 {
//                cell.label_balance.textColor = Utils.hexStringToUIColor(hex: AppColors.hk_green)
            } else {
                cell.label_balance.textColor = UIColor.red
            }
            
            cell.label_balance.isHidden = false
            cell.label_balance.text = Utils.formatDecimalNumber(number: account.balance_amount, decimal: LocalPrefs.getDecimalFormat()) 
            cell.accountTitle.text = account.title
            cell.accountImage.image = UIImage(named : account.boxicon!)?.withRenderingMode(.alwaysTemplate)
            cell.accountImage.tintColor = Utils.hexStringToUIColor(hex: account.boxcolor!)
            cell.bgView.layer.borderColor = Utils.hexStringToUIColor(hex: account.boxcolor!).cgColor
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == sortedArray.count {
            accountDelegate?.onAccountSelected(accountTitle: "", accountId: 0)
            self.dismiss(animated: false, completion: nil)
            return
        }
        
        
        let cell : VoucherAccountViewCell = accountsTableView.cellForRow(at: indexPath) as! VoucherAccountViewCell
        cell.accountImage.tintColor = UIColor.white
        cell.bgView.backgroundColor = Utils.hexStringToUIColor(hex: sortedArray[indexPath.row].boxcolor!)
        
        accountId = Int64(sortedArray[indexPath.row].account_id)
        accountTitle = sortedArray[indexPath.row].title!
        
        accountDelegate?.onAccountSelected(accountTitle: accountTitle, accountId: accountId)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell : VoucherAccountViewCell = accountsTableView.cellForRow(at: indexPath) as! VoucherAccountViewCell
        cell.accountImage.tintColor = Utils.hexStringToUIColor(hex: sortedArray[indexPath.row].boxcolor!)
        cell.bgView.backgroundColor = UIColor.white
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
