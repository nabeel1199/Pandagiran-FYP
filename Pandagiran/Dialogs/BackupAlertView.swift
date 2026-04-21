

import UIKit
import Foundation
import Firebase

protocol StartSync {
    func syncNow()
}
protocol NormalState {
    func normalState()
}


class BackupAlertView: UIView {
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var backupTitleLBL: UILabel!
    @IBOutlet weak var unsyncRecordLBL: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var syncingCountLBL: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var backupButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    //    static let instance = BackupAlertView()
    var unsyncedRecordCount: Int = 0
    var syncedRecord: Int = 0
    var backupCount: Int = 0
    var failedCount: Int = 0
    private var accountData = [Hkb_account]()
    private var categoryData = [Hkb_category]()
    private var voucherData = [Hkb_voucher]()
    private var eventsData = [Hkb_event]()
    private var goalsData = [Hkb_goal]()
    private var goalTransaction = [Hkb_goal_trx]()
    private var budgetData = [Hkb_budget]()
    var record = [BackupRecord]()
    var afterSyncRecord = [BackupRecord]()
    var delegate: StartSync?
    var popUpRequired = true
    static let sharedInstance = BackupAlertView()
    let group = DispatchGroup()
    let queue = DispatchQueue.global(qos: .background)
    let dispatchGroup = DispatchGroup()
//    let dispatchSemaphore = DispatchSemaphore(value: 0)
    static var isSyncing = false
    
    @IBOutlet var mainView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("BackupAlertView", owner: self, options: nil)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit(){
        //        mainView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: frame.height)
        //        mainView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "ic_clear")
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(tintedImage, for: .normal)
        closeButton.tintColor = .darkGray
        
        mainView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height / 6, width: UIScreen.main.bounds.width, height: mainView.frame.height)
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backupButton.addTarget(self, action: #selector(backupButtonPressed), for: .touchUpInside)
        detailButton.addTarget(self, action: #selector(detailButtonPressed), for: .touchUpInside)
        activityIndicatorView.hidesWhenStopped = true
    }
    
    func showAlert(){
        //        self.mainView.setNeedsDisplay()
        self.checkDBRecord {
            if self.unsyncedRecordCount > 0 {
                if self.failedCount == 0{
                    print("Records Unsynced \(self.unsyncedRecordCount)")
                    //                self.unsyncRecordLBL.text = "\(self.unsyncedRecordCount) Records Unsynced"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                        self.setUnsyncState()
                        //                        mainView.isHidden = false
                        self.popUpRequired = true
                    }
                } else {
                    self.setFailedState()
                    print("Records Unsynced \(self.unsyncedRecordCount)")
                    self.popUpRequired = true
                }
            } else {
                print("Unsynced Count: \(self.unsyncedRecordCount)")
                self.popUpRequired = false
            }
        }
    }
    
    
    func animateIn(viewController: UIViewController?){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewController?.view.addSubview(self.mainView)
            //            UIApplication.shared.keyWindow?.addSubview(self.mainView)
            self.mainView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height / 6)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) {
                self.mainView.transform = .identity
                self.mainView.alpha = 1
            }
        }
    }
    
    
    func animateOut(){
        //        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) {
        //            self.mainView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height / 6)
        //            self.mainView.alpha = 0
        //        } completion: { completion in
        //            if completion{
        Analytics.logEvent("Backup_Alert_Close", parameters: nil)
        self.popUpRequired = false
        self.mainView.isHidden = true
        //            }
        //        }
        
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.popUpRequired = false
        animateOut()
    }
    
    @objc func backupButtonPressed(sender: UIButton){
        print("Backup")
        
        if self.backupButton.titleLabel?.text == "DONE" {
            Analytics.logEvent("Backup_Alert_Done", parameters: nil)
            animateOut()
            self.failedCount = 0
        } else if self.backupButton.titleLabel?.text == "CANCEL" {
            VoucherNetworkCalls.sharedInstance.stopTheDamnRequests()
            Analytics.logEvent("Backup_Alert_Cancel", parameters: nil)
            self.failedCount = 0
            queue.suspend()
            self.checkDBRecord {
                self.setUnsyncState()
            }
            
            
        }else {
            
            if Reachability.isConnectedToNetwork(){
                self.failedCount = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.setSyncStates()
                }
            } else {
                UIUtils.showSnackbarNegative(message: "Check your internet connection")
            }
        }
        
        
        
    }
    
    @objc func detailButtonPressed(sender: UIButton){
        print("Backup")
        
        activityIndicatorView.stopAnimating()
        if detailButton.titleLabel?.text == "HIDE" || detailButton.titleLabel?.text == "CANCEL" {
            Analytics.logEvent("Backup_Alert_Cancel", parameters: nil)
            mainView.isHidden = true
        } else {
            Analytics.logEvent("Backup_Alert_Details", parameters: nil)
            self.detailButton.isUserInteractionEnabled = false
            let storyBoard: UIStoryboard = UIStoryboard(name: ViewIdentifiers.SB_MAIN, bundle: nil)
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if let vc = storyBoard.instantiateViewController(withIdentifier: ViewIdentifiers.VC_BACKUPDETAIL) as? BackupDetailsVC {
                    
                    if self.syncedRecord == self.unsyncedRecordCount {
                        vc.record = self.record
                        vc.queryRequired = false
                    }
                    vc.delegate = self
                    vc.normalStateDelegate = self
                    vc.modalPresentationStyle = .overCurrentContext
                    topController.present(vc, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func setSyncStates(){
        syncingCountLBL.isHidden = false
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
        self.infoButton.isHidden = true
        self.unsyncRecordLBL.text = "Syncing Records"
//        self.syncingCountLBL.text = "\(self.syncedRecord)/\(self.unsyncedRecordCount)"
        self.syncingCountLBL.text = "\(1)/\(self.unsyncedRecordCount)"
        self.detailButton.isHidden = false
        self.detailButton.setTitle("HIDE", for: .normal)
        self.backupTitleLBL.text = "Backup in progress"
        self.backupButton.setTitle("CANCEL", for: .normal)
        self.backupTitleLBL.textColor = #colorLiteral(red: 0.1620312035, green: 0.4843192101, blue: 0.5410712957, alpha: 1)
        self.closeButton.isHidden = true
        self.backupButton.setTitleColor(.red, for: .normal)
        
        self.startBackupSyncronization {
            
            print("Sync Started")
            if self.failedCount == 0 {
                self.setCompletionState()
            }
            
            
        }
    }
    
    func setUnsyncState(){
        self.closeButton.isHidden = false
        syncingCountLBL.isHidden = true
        activityIndicatorView.stopAnimating()
        self.infoButton.isHidden = false
        self.backupTitleLBL.text = "Backup Alert"
        self.backupTitleLBL.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        self.unsyncRecordLBL.text = "\(self.unsyncedRecordCount) Records Unsynced"
        self.backupButton.setTitle("BACKUP", for: .normal)
        self.backupButton.setTitleColor(#colorLiteral(red: 0.1620312035, green: 0.4843192101, blue: 0.5410712957, alpha: 1), for: .normal)
        self.detailButton.isHidden = false
        self.detailButton.setTitle("DETAILS", for: .normal)
        self.detailButton.isUserInteractionEnabled = true
    }
    
    func setFailedState(){
        VoucherNetworkCalls.sharedInstance.stopTheDamnRequests()
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.isHidden = true
        self.syncingCountLBL.isHidden = true
        self.infoButton.isHidden = false
        self.backupTitleLBL.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        self.backupTitleLBL.text = "Backup Unsuccessful"
        self.unsyncRecordLBL.text = "Record Failed to Sync"
        self.backupButton.setTitle("RETRY", for: .normal)
        self.backupButton.setTitleColor(#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), for: .normal)
        self.detailButton.setTitle("CANCEL", for: .normal)
    }
    
    func checkDBRecord(completion: ()->()){
        self.syncedRecord = 0
        self.unsyncedRecordCount = 0
        self.record.removeAll()
        self.accountData.removeAll()
        self.categoryData.removeAll()
        self.voucherData.removeAll()
        self.eventsData.removeAll()
        self.goalsData.removeAll()
        self.goalTransaction.removeAll()
        self.budgetData.removeAll()
        if QueryUtils.fetchUnsyncedAllAccounts().count > 0 {
            self.record.append(BackupRecord(title: "Accounts", entries_count: QueryUtils.fetchUnsyncedAllAccounts().count, isSynced: false))
            self.unsyncedRecordCount += QueryUtils.fetchUnsyncedAllAccounts().count
            print("Records Unsynced \(self.unsyncedRecordCount)")
            self.accountData = QueryUtils.fetchUnsyncedAllAccounts()
        }
        if QueryUtils.fetchUnsyncedAllVouchers().count > 0 {
            self.record.append(BackupRecord(title: "Transactions", entries_count: QueryUtils.fetchUnsyncedAllVouchers().count, isSynced: false))
            self.unsyncedRecordCount += QueryUtils.fetchUnsyncedAllVouchers().count
            print("Records Unsynced \(self.unsyncedRecordCount)")
            self.voucherData = QueryUtils.fetchUnsyncedAllVouchers()
        }
        if QueryUtils.fetchUnsyncedAllEvents().count > 0 {
            self.record.append(BackupRecord(title: "Events", entries_count: QueryUtils.fetchUnsyncedAllEvents().count, isSynced: false))
            self.unsyncedRecordCount += QueryUtils.fetchUnsyncedAllEvents().count
            print("Records Unsynced \(self.unsyncedRecordCount)")
            self.eventsData = QueryUtils.fetchUnsyncedAllEvents()
        }
        if QueryUtils.fetchUnsyncedAllCategories().count > 0 {
            self.record.append(BackupRecord(title: "Categories", entries_count: QueryUtils.fetchUnsyncedAllCategories().count, isSynced: false))
            self.unsyncedRecordCount += QueryUtils.fetchUnsyncedAllCategories().count
            print("Records Unsynced \(self.unsyncedRecordCount)")
            self.categoryData = QueryUtils.fetchUnsyncedAllCategories()
        }
        if QueryUtils.fetchUnsyncedAllSavingGoal().count > 0 {
            self.record.append(BackupRecord(title: "Saving Goals", entries_count: QueryUtils.fetchUnsyncedAllSavingGoal().count, isSynced: false))
            self.unsyncedRecordCount += QueryUtils.fetchUnsyncedAllSavingGoal().count
            print("Records Unsynced \(self.unsyncedRecordCount)")
            self.goalsData = QueryUtils.fetchUnsyncedAllSavingGoal()
        }
        if QueryUtils.fetchUnsyncedAllSavingTrx().count > 0 {
            self.record.append(BackupRecord(title: "Saving Transactions", entries_count: QueryUtils.fetchUnsyncedAllSavingTrx().count, isSynced: false))
            self.unsyncedRecordCount += QueryUtils.fetchUnsyncedAllSavingTrx().count
            print("Records Unsynced \(self.unsyncedRecordCount)")
            self.goalTransaction = QueryUtils.fetchUnsyncedAllSavingTrx()
        }
        if QueryUtils.fetchUnsyncedAllBudget().count > 0 {
            self.record.append(BackupRecord(title: "Budget", entries_count: QueryUtils.fetchUnsyncedAllBudget().count, isSynced: false))
            self.unsyncedRecordCount += QueryUtils.fetchUnsyncedAllBudget().count
            print("Records Unsynced \(self.unsyncedRecordCount)")
            self.budgetData = QueryUtils.fetchUnsyncedAllBudget()
        }
        
        //        fetchUnsyncedAllBudget
        completion()
    }
    
    func startBackupSyncronization(completion: @escaping () -> ()){
        print("Backup Started")
        self.backupCount = 0
        self.syncedRecord = 0
        self.failedCount = 0
        BackupAlertView.isSyncing = true
        queue.async {
            self.accountSync {
                print("Account Method Called")
            self.categorySync {
                print("Category Method Called")
                self.eventSync {
                    print("Event Method Called")
                    self.budgetSync {
                        print("Budget Method Called")
                        self.goalSync {
                            print("Goal Method Called")
                            self.goalTransactionSync {
                                print("Goal Transactions Method Called")
                                self.voucherSync {
                                    print("Transactions Method Called")
                                    completion()
                                }
                            }
                        }
                    }
                }
            }
        }
        }

    }
    
    func accountSync(completion: @escaping () -> ()){
        var i = 0
         
//        queue.async {
            //            dispatchSemaphore.wait()
            while i < self.accountData.count {
                print(self.accountData[i].account_id)
                self.backupCount += 1
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                VoucherNetworkCalls.sharedInstance.backupAccounts(account: self.accountData[i]) { (status, message, error) in
                    print("Account Response: \(status), \(message)")
                    if status == 1{
                        self.syncedRecord += 1
                        self.setSyncCount(syncedCount: self.syncedRecord)
                        dispatchSemaphore.signal()
                    } else {
                        if message == "Record Already Exist" {
                            self.syncedRecord += 1
                            self.setSyncCount(syncedCount: self.syncedRecord)
                             
                        } else {
                            self.failedCount += 1
                            self.setFailedState()
                             
                            return
                            
                        }
                        dispatchSemaphore.signal()
                    }
                    dispatchSemaphore.wait()
                }

                i += 1
                
            }
        if i == self.accountData.count{
            //            group.notify(queue: .main) {
            completion()
            //            }
        }
    }
    
    func categorySync(completion: @escaping () -> ()){
        var i = 0
         
//        queue.async {
            while i < self.categoryData.count {
                print(self.categoryData[i].categoryId)
                self.backupCount += 1
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                VoucherNetworkCalls.sharedInstance.backupCategory(category: self.categoryData[i]) { (status, message, error) in
                    print("Category Response: \(status), \(message)")
                    if status == 1{
                        self.syncedRecord += 1
                        self.setSyncCount(syncedCount: self.syncedRecord)
                        dispatchSemaphore.signal()
                    } else {
                        if message == "Record Already Exist" {
                            self.syncedRecord += 1
                            self.setSyncCount(syncedCount: self.syncedRecord)
                             
                        } else {
                            self.failedCount += 1
                            self.setFailedState()
                             
                            return
                            
                        }
                        dispatchSemaphore.signal()
                    }
                }
                 dispatchSemaphore.wait()
                i += 1
            }
//        }
        //        while i < categoryData.count {
        //            print(categoryData[i].categoryId)
        //            self.backupCount += 1
        //            self.group.enter() // enter the group just before create the request
        //             self.dispatchSemaphore.wait()
        //                VoucherNetworkCalls.sharedInstance.backupCategory(category: self.categoryData[i]) { (status, message, error) in
        //                    print("API Response: \(status), \(message)")
        //                    if status == 1{
        //                        self.syncedRecord += 1
        //                        self.setSyncCount(syncedCount: self.syncedRecord)
        //                        self.group.leave()//leave the group on completion closure
        //                        dispatchSemaphore.signal()
        //                    } else {
        //                        if message == "Record Already Exist" {
        //                            self.syncedRecord += 1
        //                            self.setSyncCount(syncedCount: self.syncedRecord)
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                        } else {
        //                            self.failedCount += 1
        //                            self.setFailedState()
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                            return
        //
        //                        }
        //                    }
        //                }
        //                i += 1
        //            }
        if i == categoryData.count{
            //            self.group.notify(queue: .main) {
            completion()
            //            }
        }
    }
    
    func eventSync(completion: @escaping () -> ()){
        var i = 0
        
//        queue.async {
            while i < self.eventsData.count {
                print(self.eventsData[i].eventid)
                self.backupCount += 1
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                VoucherNetworkCalls.sharedInstance.backupEvents(event: self.eventsData[i]) { (status, message, error) in
                    print("Event Response: \(status), \(message)")
                    if status == 1{
                        self.syncedRecord += 1
                        self.setSyncCount(syncedCount: self.syncedRecord)
                        dispatchSemaphore.signal()
                    } else {
                        if message == "Record Already Exist" {
                            self.syncedRecord += 1
                            self.setSyncCount(syncedCount: self.syncedRecord)
                             
                        } else {
                            self.failedCount += 1
                            self.setFailedState()
                             
                            return
                            
                        }
                        dispatchSemaphore.signal()
                    }
                }
                 dispatchSemaphore.wait()
                i += 1
            }
//        }
        //        while i < eventsData.count {
        //            print(eventsData[i].eventid)
        //            self.backupCount += 1
        //            self.group.enter() // enter the group just before create the request
        //            dispatchSemaphore.wait()
        //                VoucherNetworkCalls.sharedInstance.backupEvents(event: self.eventsData[i]) { (status, message, error) in
        //                    print("API Response: \(status), \(message)")
        //                    if status == 1{
        //                        self.syncedRecord += 1
        //                        self.setSyncCount(syncedCount: self.syncedRecord)
        //                        self.group.leave()//leave the group on completion closure
        //                        dispatchSemaphore.signal()
        //                    } else {
        //                        if message == "Record Already Exist" {
        //                            self.syncedRecord += 1
        //                            self.setSyncCount(syncedCount: self.syncedRecord)
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                        } else {
        //                            self.failedCount += 1
        //                            self.setFailedState()
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                            return
        //
        //                        }
        //                    }
        //                }
        //                i += 1
        //        }
        if i == eventsData.count{
            //            self.group.notify(queue: .main) {
            completion()
            //            }
        }
    }
    
    func budgetSync(completion: @escaping () -> ()){
        var i = 0
         
//        queue.async {
            while i < self.budgetData.count {
                print(self.budgetData[i].budget_id)
                self.backupCount += 1
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                VoucherNetworkCalls.sharedInstance.backupBudget(budget: self.budgetData[i]) { (status, message, error) in
                    print("Budget Response: \(status), \(message)")
                    if status == 1{
                        self.syncedRecord += 1
                        self.setSyncCount(syncedCount: self.syncedRecord)
                        dispatchSemaphore.signal()
                    } else {
                        if message == "Record Already Exist" {
                            self.syncedRecord += 1
                            self.setSyncCount(syncedCount: self.syncedRecord)
                             
                        } else {
                            self.failedCount += 1
                            self.setFailedState()
                             
                            return
                            
                        }
                        dispatchSemaphore.signal()
                    }
                }
                 dispatchSemaphore.wait()
                i += 1
            }
//        }
        //        while i < budgetData.count {
        //            print(budgetData[i].budget_id)
        //            self.backupCount += 1
        //            self.group.enter() // enter the group just before create the request
        //            dispatchSemaphore.wait()
        //                VoucherNetworkCalls.sharedInstance.backupBudget(budget: self.budgetData[i]) { (status, message, error) in
        //                    print("API Response: \(status), \(message)")
        //                    if status == 1{
        //                        self.syncedRecord += 1
        //                        self.setSyncCount(syncedCount: self.syncedRecord)
        //                        self.group.leave()//leave the group on completion closure
        //                        dispatchSemaphore.signal()
        //                    } else {
        //                        if message == "Record Already Exist" {
        //                            self.syncedRecord += 1
        //                            self.setSyncCount(syncedCount: self.syncedRecord)
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                        } else {
        //                            self.failedCount += 1
        //                            self.setFailedState()
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                            return
        //
        //                        }
        //                    }
        //                }
        //                i += 1
        //        }
        if i == budgetData.count{
            //            self.group.notify(queue: .main) {
            completion()
            //            }
        }
    }
    
    func goalSync(completion: @escaping () -> ()){
        var i = 0
         
//        queue.async {
            while i < self.goalsData.count {
                print(self.goalsData[i].goalId)
                self.backupCount += 1
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                VoucherNetworkCalls.sharedInstance.backupGoal(goal: self.goalsData[i]) { (status, message, error) in
                    print("Goal Response: \(status), \(message)")
                    if status == 1{
                        self.syncedRecord += 1
                        self.setSyncCount(syncedCount: self.syncedRecord)
                        dispatchSemaphore.signal()
                    } else {
                        if message == "Record Already Exist" {
                            self.syncedRecord += 1
                            self.setSyncCount(syncedCount: self.syncedRecord)
                        } else {
                            self.failedCount += 1
                            self.setFailedState()
                             
                            return
                            
                        }
                        dispatchSemaphore.signal()
                    }
                }
                dispatchSemaphore.wait()
                i += 1
                
            }
//        }
        //        while i < goalsData.count {
        //            print(goalsData[i].goalId)
        //            self.backupCount += 1
        //            self.group.enter() // enter the group just before create the request
        //            dispatchSemaphore.wait()
        //                VoucherNetworkCalls.sharedInstance.backupGoal(goal: self.goalsData[i]) { (status, message, error) in
        //                    print("API Response: \(status), \(message)")
        //                    if status == 1{
        //                        self.syncedRecord += 1
        //                        self.setSyncCount(syncedCount: self.syncedRecord)
        //                        self.group.leave()//leave the group on completion closure
        //                        dispatchSemaphore.signal()
        //                    } else {
        //                        if message == "Record Already Exist" {
        //                            self.syncedRecord += 1
        //                            self.setSyncCount(syncedCount: self.syncedRecord)
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                        } else {
        //                            self.failedCount += 1
        //                            self.setFailedState()
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                            return
        //
        //                        }
        //
        //                    }
        //                }
        //                i += 1
        //
        //        }
        if i == goalsData.count{
            //            self.group.notify(queue: .main) {
            completion()
            //            }
        }
    }
    
    func goalTransactionSync(completion: @escaping () -> ()){
        var i = 0
         
//        queue.async {
            while i < self.goalTransaction.count {
                print(self.goalTransaction[i].goalid)
                self.backupCount += 1
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                VoucherNetworkCalls.sharedInstance.backupGoalSavingTrx(goalTrx: self.goalTransaction[i]) { (status, message, error) in
                    print("Goal Transaction Response: \(status), \(message)")
                    if status == 1{
                        self.syncedRecord += 1
                        self.setSyncCount(syncedCount: self.syncedRecord)
                        dispatchSemaphore.signal()
                    } else {
                        if message == "Record Already Exist" {
                            self.syncedRecord += 1
                            self.setSyncCount(syncedCount: self.syncedRecord)
                             
                        } else {
                            self.failedCount += 1
                            self.setFailedState()
                             
                            return
                            
                        }
                        dispatchSemaphore.signal()
                    }
                }
                 dispatchSemaphore.wait()
                i += 1
            }
//        }
        //        while i < goalTransaction.count {
        //            print(goalTransaction[i].goalid)
        //            self.backupCount += 1
        //            self.group.enter() // enter the group just before create the request
        //            dispatchSemaphore.wait()
        //                VoucherNetworkCalls.sharedInstance.backupGoalSavingTrx(goalTrx: self.goalTransaction[i]) { (status, message, error) in
        //                    print("API Response: \(status), \(message)")
        //                    if status == 1{
        //                        self.syncedRecord += 1
        //                        self.setSyncCount(syncedCount: self.syncedRecord)
        //                        self.group.leave()//leave the group on completion closure
        //                        dispatchSemaphore.signal()
        //                    } else {
        //                        if message == "Record Already Exist" {
        //                            self.syncedRecord += 1
        //                            self.setSyncCount(syncedCount: self.syncedRecord)
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                        } else {
        //                            self.failedCount += 1
        //                            self.setFailedState()
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                            return
        //
        //                        }
        //                    }
        //
        //                }
        //                i += 1
        //            }
        if i == goalTransaction.count{
            //            self.group.notify(queue: .main) {
            completion()
            //            }
        }
    }
    
    func voucherSync(completion: @escaping () -> ()){
        var i = 0
         
//        queue.async {
            while i < self.voucherData.count {
                print(self.voucherData[i].voucher_id)
                self.backupCount += 1
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                VoucherNetworkCalls.sharedInstance.backupVoucher(voucher: self.voucherData[i]) { (status, message, error) in
                    print("Voucher Response: \(status), \(message)")
                    if status == 1{
                        self.syncedRecord += 1
                        self.setSyncCount(syncedCount: self.syncedRecord)
                        dispatchSemaphore.signal()
                    } else {
                        if message == "Record Already Exist" {
                            self.syncedRecord += 1
                            self.setSyncCount(syncedCount: self.syncedRecord)
                             
                        } else {
                            self.failedCount += 1
                            self.setFailedState()
                             
                            return
                            
                        }
                        dispatchSemaphore.signal()
                    }
                   
                }
                 dispatchSemaphore.wait()
                i += 1
            }
//        }
        //        while i < voucherData.count {
        //            print(voucherData[i].voucher_id)
        //            self.backupCount += 1
        //            self.group.enter() // enter the group just before create the request
        //            dispatchSemaphore.wait()
        //                VoucherNetworkCalls.sharedInstance.backupVoucher(voucher: self.voucherData[i]) { (status, message, error) in
        //                    print("API Response: \(status), \(message)")
        //                    if status == 1{
        //                        self.syncedRecord += 1
        //                        self.setSyncCount(syncedCount: self.syncedRecord)
        //                        self.group.leave()//leave the group on completion closure
        //                        dispatchSemaphore.signal()
        //                    } else {
        //                        if message == "Record Already Exist" {
        //                            self.syncedRecord += 1
        //                            self.setSyncCount(syncedCount: self.syncedRecord)
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                        } else {
        //                            self.failedCount += 1
        //                            self.setFailedState()
        //                            self.group.leave()//leave the group on completion closure
        //                            dispatchSemaphore.signal()
        //                            return
        //
        //                        }
        //                    }
        //                }
        //                i += 1
        //        }
        if i == voucherData.count{
            //            self.group.notify(queue: .main) {
            completion()
            //            }
        }
    }
    
    func setSyncCount(syncedCount: Int){
        self.syncingCountLBL.text = "\(syncedCount)/\(self.unsyncedRecordCount)"
        //        if syncedCount == self.unsyncedRecordCount {
        //            DispatchQueue.main.async {
        //                if self.mainView.isHidden{
        //                    self.mainView.isHidden = false
        //                }
        //                self.syncingCountLBL.isHidden = true
        //                self.activityIndicatorView.stopAnimating()
        //                self.detailButton.isHidden = true
        //                self.infoButton.isHidden = false
        //                self.backupTitleLBL.text = "Backup Successful"
        //                self.backupTitleLBL.textColor = #colorLiteral(red: 0.1620312035, green: 0.4843192101, blue: 0.5410712957, alpha: 1)
        //                self.unsyncRecordLBL.text = "All Records Synced"
        //                self.backupButton.setTitle("DONE", for: .normal)
        //                self.backupButton.setTitleColor(#colorLiteral(red: 0.1620312035, green: 0.4843192101, blue: 0.5410712957, alpha: 1), for: .normal)
        //                self.detailButton.setTitle("DETAILS", for: .normal)
        //            }
        //        }
        // only for non-ARC projects, handled automatically in ARC-enabled projects.
        //        dispatchGroup.notify(queue: .main) { [unowned self] in
        //            print("Notified")
        //        }
    }
    
    func setCompletionState(){
        DispatchQueue.main.async {
            BackupAlertView.isSyncing = true
            if self.mainView.isHidden{
                self.mainView.isHidden = false
                
            }
            self.syncingCountLBL.isHidden = true
            self.activityIndicatorView.stopAnimating()
            self.detailButton.isHidden = true
            self.infoButton.isHidden = false
            self.backupTitleLBL.text = "Backup Successful"
            self.backupTitleLBL.textColor = #colorLiteral(red: 0.1620312035, green: 0.4843192101, blue: 0.5410712957, alpha: 1)
            self.unsyncRecordLBL.text = "All Records Synced"
            self.backupButton.setTitle("DONE", for: .normal)
            self.backupButton.setTitleColor(#colorLiteral(red: 0.1620312035, green: 0.4843192101, blue: 0.5410712957, alpha: 1), for: .normal)
            self.detailButton.setTitle("DETAILS", for: .normal)
        }
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        Analytics.logEvent("Backup_Information", parameters: nil)
        self.infoButton.isUserInteractionEnabled = false
        let storyBoard: UIStoryboard = UIStoryboard(name: ViewIdentifiers.SB_BACKUP, bundle: nil)
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            if let vc = storyBoard.instantiateViewController(withIdentifier: ViewIdentifiers.VC_BACKUP_MESSAGE) as? BackupMessageVC {
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                topController.present(vc, animated: true, completion: nil)
            }
        }
    }
    
}
extension BackupAlertView: StartSync, NormalState{
    
    func syncNow() {
        self.setSyncStates()
    }
    
    func normalState(){
        self.detailButton.isUserInteractionEnabled = true
        self.infoButton.isUserInteractionEnabled = true
    }
}
