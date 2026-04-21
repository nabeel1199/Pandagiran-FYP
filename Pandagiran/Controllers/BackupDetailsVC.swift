

import UIKit
import Alamofire
import SwiftyJSON

class BackupDetailsVC: UIViewController {

    @IBOutlet weak var syncNowButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleHeading: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var record = [BackupRecord]()
    private var accountData = [Hkb_account]()
    private var categoryData = [Hkb_category]()
    private var voucherData = [Hkb_voucher]()
    private var eventsData = [Hkb_event]()
    private var goalsData = [Hkb_goal]()
    private var goalTransaction = [Hkb_goal_trx]()
    private var budgetData = [Hkb_budget]()
    var queryRequired = true
    var delegate: StartSync?
    var normalStateDelegate: NormalState?
    
//    private var voucherNetworkManager : VoucherNetworkCalls!
    
    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let image = UIImage(named: "ic_clear")
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(tintedImage, for: .normal)
        closeButton.tintColor = .darkGray
        
        tableView.register(UINib(nibName: "BackupDetailViewCell", bundle: nil),forCellReuseIdentifier:"BackupDetailViewCell")
        
        if queryRequired {
            self.checkDBRecord {
                tableView.reloadData()
            }
        } else {
            self.titleHeading.text = "Synced Records"
            self.cancelButton.setTitle("DISMISS", for: .normal)
            self.syncNowButton.isHidden = true
            tableView.reloadData()
        }
        

    }
    
    
    func checkDBRecord(completion: ()->()){
        if QueryUtils.fetchUnsyncedAllAccounts().count > 0 {
            self.record.append(BackupRecord(title: "Accounts", entries_count: QueryUtils.fetchUnsyncedAllAccounts().count))
            self.accountData = QueryUtils.fetchUnsyncedAllAccounts()
        }
        if QueryUtils.fetchUnsyncedAllVouchers().count > 0 {
            self.record.append(BackupRecord(title: "Transactions", entries_count: QueryUtils.fetchUnsyncedAllVouchers().count))
            self.voucherData = QueryUtils.fetchUnsyncedAllVouchers()
        }
        if QueryUtils.fetchUnsyncedAllEvents().count > 0 {
            self.record.append(BackupRecord(title: "Events", entries_count: QueryUtils.fetchUnsyncedAllEvents().count))
            self.eventsData = QueryUtils.fetchUnsyncedAllEvents()
        }
        if QueryUtils.fetchUnsyncedAllCategories().count > 0 {
            self.record.append(BackupRecord(title: "Categories", entries_count: QueryUtils.fetchUnsyncedAllCategories().count))
            self.categoryData = QueryUtils.fetchUnsyncedAllCategories()
        }
        if QueryUtils.fetchUnsyncedAllSavingGoal().count > 0 {
            self.record.append(BackupRecord(title: "Saving Goals", entries_count: QueryUtils.fetchUnsyncedAllSavingGoal().count))
            self.goalsData = QueryUtils.fetchUnsyncedAllSavingGoal()
        }
        if QueryUtils.fetchUnsyncedAllSavingTrx().count > 0 {
            self.record.append(BackupRecord(title: "Saving Transactions", entries_count: QueryUtils.fetchUnsyncedAllSavingTrx().count))
            self.goalTransaction = QueryUtils.fetchUnsyncedAllSavingTrx()
        }
        if QueryUtils.fetchUnsyncedAllBudget().count > 0 {
            self.record.append(BackupRecord(title: "Budget", entries_count: QueryUtils.fetchUnsyncedAllBudget().count))
            self.budgetData = QueryUtils.fetchUnsyncedAllBudget()
        }
        
        completion()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func syncNowPressed(_ sender: UIButton) {
//        BackupAlertView.instance.backupButtonPressed(sender: sender)
        if Reachability.isConnectedToNetwork(){
            self.dismiss(animated: true) {
                self.delegate?.syncNow()
            }
        } else {
            UIUtils.showSnackbarNegative(message: "Check your internet connection")
        }
        

    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true){
            self.normalStateDelegate?.normalState()
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true){
            self.normalStateDelegate?.normalState()
        }
    }
    
}
extension BackupDetailsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.record.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BackupDetailViewCell", for: indexPath) as? BackupDetailViewCell else {
            return UITableViewCell()
        }
        
        if !self.queryRequired{
            cell.countLBL.textColor = #colorLiteral(red: 0.1620312035, green: 0.4843192101, blue: 0.5410712957, alpha: 1)
        }
        cell.configureCell(recordType: self.record[indexPath.row].title ?? "", recordCount: "\(self.record[indexPath.row].entries_count ?? 0)")
        return cell
    }
    
    
}
