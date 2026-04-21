

import UIKit
import SwiftyJSON
import Firebase

class RestoreVC: BaseViewController {

    @IBOutlet weak var failStateView: UIView!
    @IBOutlet weak var backupFoundLBL: UILabel!
    @IBOutlet weak var backupRestoreLBL: UILabel!
    @IBOutlet weak var emptyProgressBarVidth: NSLayoutConstraint!
    @IBOutlet weak var completeProgressBarWidth: NSLayoutConstraint!
    @IBOutlet weak var emptyProgressBar: UIView!
    @IBOutlet weak var completeProgressBar: UIView!
    @IBOutlet weak var continueButton: GradientButton!
    @IBOutlet weak var percentageLBL: UILabel!
    @IBOutlet weak var statusLBL: UILabel!
    @IBOutlet weak var goLBL: UILabel!
    var isCategorySynced = false
    var globalWorkFlow = ""
    var globalCount = 0
    let dispatchQueue = DispatchQueue(label: "BackUp", qos: .userInitiated, attributes: .concurrent)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.fetchRecords(workflow: "TRANSACTION", count: 0)
        self.continueButton.isHidden = true
        self.updateProgressBar()
        self.checkUnsyncedRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }

    func fetchRecords(workflow: String, count: Int){
        globalWorkFlow = workflow
        globalCount = count
        RestoreNetworkCalls.sharedInstance.getWorkFlowRecord(workFlow: workflow, count: count) { (status, message, response) in
            
            if status == 1 {
                print("Worked")
                if let responseArray = response["data"]["records"].arrayObject as NSArray? {
                    print(responseArray)
                    let totalCount = response["data"]["recordsLeft"].intValue
                    self.decodeData(arrayData: responseArray, workFlow: workflow, count: totalCount)
                }
                if workflow == "CATEGORY"{
                    if self.isCategorySynced == false {
                        if let defaultCat = response["data"]["defaultCategories"].arrayObject as NSArray? {
                            print(defaultCat)
                            self.decodeConstantCategory(arrayData: defaultCat)
                        }
                    }
                }
            } else {
                
//                if message == "The request timed out." {
                    self.retryState(workFlow: workflow, count: count)
//                } else {
                    print("Else Block")
                    self.failedState()
//                }
                
            }

        }
    }
    
    /*
    // MARK: - Navigation

    */

    
    func checkUnsyncedRecord(){
        
        if LocalPrefs.getAccountsTotalCount() != 0 {//LocalPrefs.getSyncAccountsTotalCount() {
//        if workFlow == "ACCOUNT" {//LocalPrefs.getSyncAccountsTotalCount() {
            self.fetchRecords(workflow: "ACCOUNT", count: LocalPrefs.getSyncAccountsTotalCount())
            return
        } else if LocalPrefs.getCategoriesTotal() != 0 { //LocalPrefs.getSyncCategoriesTotalCount() {
            self.fetchRecords(workflow: "CATEGORY", count: LocalPrefs.getSyncCategoriesTotalCount())
            return
        } else if LocalPrefs.getEventsTotal() != 0 { //LocalPrefs.getSyncEventsTotalCount() {
            self.fetchRecords(workflow: "EVENT", count: LocalPrefs.getSyncEventsTotalCount())
            return
        } else if LocalPrefs.getBudgetsTotal() != 0 { //LocalPrefs.getSyncBudgetsTotalCount() {
            self.fetchRecords(workflow: "BUDGET", count: LocalPrefs.getSyncBudgetsTotalCount())
            return
        } else if LocalPrefs.getSavingsTotal() != 0 { //LocalPrefs.getSyncSavingTotalCount(){
            self.fetchRecords(workflow: "SAVING", count: LocalPrefs.getSyncSavingTotalCount())
            return
        } else if LocalPrefs.getSavingTrxTotal() != 0 { //LocalPrefs.getSyncSavingTrxTotalCount() {
            self.fetchRecords(workflow: "SAVING_TRANSACTION", count: LocalPrefs.getSyncSavingTrxTotalCount())
            return
        } else if LocalPrefs.getTransactionTotal() != 0 { //LocalPrefs.getSyncTransactionTotalCount() {
            self.fetchRecords(workflow: "TRANSACTION", count: LocalPrefs.getSyncTransactionTotalCount())
            return
        } else {
            if !isCategorySynced{
                isCategorySynced = true
                QueryUtils.saveCategories()
            }
            self.continueButton.isHidden = false
            self.goLBL.isHidden = false
        }
    }
    
    
    func updateProgressBar(){
        self.failStateView.isHidden = true
        let progressPercentage = Double(LocalPrefs.getSyncedBackupTotalCount()) / Double(LocalPrefs.getBackupTotalCount())
        DispatchQueue.main.async {
            print(progressPercentage)
            UIView.animate(withDuration: 0.02) {
                self.percentageLBL.text = "\(Int((progressPercentage + 0.01) * 100))%"
                self.completeProgressBarWidth.constant = self.emptyProgressBar.frame.size.width * CGFloat(progressPercentage)
                print("Before If \(LocalPrefs.getSyncedBackupTotalCount())")
                print("Before If \(LocalPrefs.getBackupTotalCount())")
                if LocalPrefs.getSyncedBackupTotalCount() == LocalPrefs.getBackupTotalCount(){
                    self.percentageLBL.text = "100%"
                    self.continueButton.isHidden = false
                    self.statusLBL.isHidden = true
                    self.backupRestoreLBL.text = "Congratulations"
                    self.backupFoundLBL.text = "Backup Restored"
                    print(LocalPrefs.getSyncedBackupTotalCount())
                    print(LocalPrefs.getBackupTotalCount())
                    self.completeProgressBarWidth.constant = self.emptyProgressBar.frame.size.width
                }
            }
            
        }
    }
    
    func decodeData(arrayData: NSArray, workFlow: String, count: Int){
        do {

            //Convert to Data
            let jsonData = try JSONSerialization.data(withJSONObject: arrayData, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            do {
                let decoder = JSONDecoder()
                switch workFlow {
                case "ACCOUNT":
                    let synced = try decoder.decode([AccountsResponseData].self, from: jsonData)
                    print(synced)
                    if synced.count == 0{
                        UIUtils.showSnackbarNegative(message: "Unable to fetch \(workFlow)")
                        self.failedState()
                        self.retryState(workFlow: workFlow, count: count)
                        break
                    } else {
                        self.updateProgressBar()
                        self.checkUnsyncedRecord()
                    }
                    
                case "CATEGORY":
                    let synced = try decoder.decode([CategoryResponseData].self, from: jsonData)
                    print(synced)
//                    if synced.count == 0 && count > 0{
                    if synced.count == 0{
                        UIUtils.showSnackbarNegative(message: "Unable to fetch \(workFlow)")
                        self.failedState()
                        self.retryState(workFlow: workFlow, count: count)
                        break
                    } else {
                        self.updateProgressBar()
                        self.checkUnsyncedRecord()
                    }
                case "EVENT":
                    let synced = try decoder.decode([EventsResponseData].self, from: jsonData)
                    print(synced)
//                    if synced.count == 0 && count > 0{
                    if synced.count == 0{
                        UIUtils.showSnackbarNegative(message: "Unable to fetch \(workFlow)")
                        self.failedState()
                        self.retryState(workFlow: workFlow, count: count)
                        break
                    } else {
                        self.updateProgressBar()
                        self.checkUnsyncedRecord()
                    }
                case "BUDGET":
                    let synced = try decoder.decode([BudgetsResponseData].self, from: jsonData)
                    print(synced)
//                    if synced.count == 0 && count > 0{
                    if synced.count == 0{
                        UIUtils.showSnackbarNegative(message: "Unable to fetch \(workFlow)")
                        self.failedState()
                        self.retryState(workFlow: workFlow, count: count)
                        break
                    } else {
                        self.updateProgressBar()
                        self.checkUnsyncedRecord()
                    }
                case "SAVING":
                    let synced = try decoder.decode([SavingResponseData].self, from: jsonData)
                    print(synced)
//                    if synced.count == 0 && count > 0{
                    if synced.count == 0{
                        UIUtils.showSnackbarNegative(message: "Unable to fetch \(workFlow)")
                        self.failedState()
                        self.retryState(workFlow: workFlow, count: count)
                        break
                    } else {
                        self.updateProgressBar()
                        self.checkUnsyncedRecord()
                    }
                case "SAVING_TRANSACTION":
                    let synced = try decoder.decode([SavingTrxResponseData].self, from: jsonData)
                    print(synced)
//                    if synced.count == 0 && count > 0{
                    if synced.count == 0{
                        UIUtils.showSnackbarNegative(message: "Unable to fetch \(workFlow)")
                        self.failedState()
                        self.retryState(workFlow: workFlow, count: count)
                        break
                    } else {
                        self.updateProgressBar()
                        self.checkUnsyncedRecord()
                    }
                case "TRANSACTION":
                    let synced = try decoder.decode([TransactionResponseData].self, from: jsonData)
                    print(synced)
//                    if synced.count == 0 && count > 0{
                    if synced.count == 0{
                        UIUtils.showSnackbarNegative(message: "Unable to fetch \(workFlow)")
                        self.failedState()
                        self.retryState(workFlow: workFlow, count: count)
                        break
                    } else {
                        self.updateProgressBar()
                        self.checkUnsyncedRecord()
                    }
                default:
                    UIUtils.showSnackbarNegative(message: "Oops something went wrong")
                }
                
                
            } catch {
                print(error.localizedDescription)
                self.failedState()
                self.retryState(workFlow: workFlow, count: count)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func decodeConstantCategory(arrayData: NSArray){
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: arrayData, options: JSONSerialization.WritingOptions.prettyPrinted)
//
            do {
                let decoder = JSONDecoder()
                    let synced = try decoder.decode([ConstantCategoryData].self, from: jsonData)
                    print(synced)
                    self.isCategorySynced = true
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
            
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        if continueButton.titleLabel?.text == "PROCEED WITHOUT RESTORE"{
            Analytics.logEvent("Backup_Skip_Without_Restore", parameters: nil)
            self.continueWithoutRestore()
        } else {
            Analytics.logEvent("Backup_Restore_Success", parameters: nil)
            self.navigateToLocationVC()
        }
        
    }
    
    private func navigateToLocationVC() {
        let locationVC = getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_USER_LOCATION) as! UserLocationViewController
        self.navigationController?.pushViewController(locationVC, animated: true)
    }
    
    func failedState(){
//        self.continueButton.isHidden = false
        self.goLBL.isHidden = false
        self.goLBL.text = "Something went wrong\nUnable to restore back"
    }
    
    func retryState(workFlow: String, count: Int){
        self.failStateView.isHidden = false
        self.continueButton.setTitle("PROCEED WITHOUT RESTORE", for: .normal)
        self.continueButton.isHidden = false
        self.globalCount = count
        self.globalWorkFlow = workFlow
    }
    
    @IBAction func retryPressed(_ sender: Any) {
       
        if Reachability.isConnectedToNetwork(){
            self.goLBL.isHidden = true
            self.failStateView.isHidden = true
            self.continueButton.isHidden = true
            self.continueButton.setTitle("Continue", for: .normal)
            self.fetchRecords(workflow: globalWorkFlow, count: globalCount)
        } else {
            UIUtils.showSnackbarNegative(message: "Check your internet connection")
        }
    }
    
    
    func continueWithoutRestore(){
        QueryUtils.deleteAllSavings()
        QueryUtils.deleteAllAccounts()
        QueryUtils.deleteAllCategories()
        QueryUtils.deleteSavingTransactions()
        QueryUtils.deleteAllTransaction()
        QueryUtils.deleteAllBudgets()
        QueryUtils.deleteAllEvents()
        
        QueryUtils.saveAccounts()
        QueryUtils.saveCategories()
        
        LocalPrefs.setBackupTotalCount(totalBackupCount: 0)
        LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: 0)
        
        self.navigateToLocationVC()
    }
}


