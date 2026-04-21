

import UIKit




class AccountSelectionPopup: BasePopup {

    @IBOutlet weak var accountsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var label_choose_account: CustomFontLabel!
    @IBOutlet weak var table_view_accounts: UITableView!
    
    private let nibAccountName = "CategorySelectionViewCell"
    private var arrayOfAccounts : Array<Hkb_account> = []
    
    public var delegate: AccountSelectionListener?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        fetchAccounts()
        
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_accounts.dataSource = self
        table_view_accounts.delegate = self
    }
    
    private func initNibs () {
        let nibAccount = UINib(nibName: nibAccountName, bundle: nil)
        table_view_accounts.register(nibAccount, forCellReuseIdentifier: nibAccountName)
    }
    
    private func fetchAccounts () {
//        let accountType = ["Cash","Bank","Person"]
        arrayOfAccounts = QueryUtils.fetchAllAccounts()
        self.table_view_accounts.reloadData()
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AccountSelectionPopup: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfAccounts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibAccountName, for: indexPath) as! CategorySelectionViewCell
        
        cell.iv_selection.image = UIImage(named: "ic_radio_unchecked")
        
        if indexPath.row == 0 {
            cell.label_category.text = "All Accounts"
        } else {
            let account = arrayOfAccounts[indexPath.row - 1]
            
            if let accountTitle = account.title {
                cell.label_category.text = accountTitle
            }
            
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! CategorySelectionViewCell
        
        cell.iv_selection.image = UIImage(named: "ic_radio_checked")
        
        if indexPath.row == 0 {
            delegate?.onAccountSelected(accountTitle: "All Accounts", accountId: 0)
        } else {
            delegate?.onAccountSelected(accountTitle: arrayOfAccounts[indexPath.row - 1].title!, accountId: Int64(Int(arrayOfAccounts[indexPath.row - 1].account_id)))
        }
        

        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! CategorySelectionViewCell
        
        cell.iv_selection.image = UIImage(named: "ic_radio_unchecked")
    }
    
    
}
