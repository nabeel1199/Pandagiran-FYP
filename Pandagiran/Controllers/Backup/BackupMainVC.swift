

import UIKit
import Firebase

protocol AlertResponse {
    func skipRestore()
}

class BackupMainVC: BaseViewController {

    @IBOutlet weak var backupDescriptionLBL: UILabel!
    @IBOutlet weak var nameLBL: UILabel!
    
    var workFlow_Count = [WorkFlow_Record]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nameLBL.text = "Hello, \(LocalPrefs.getUserData()[Constants.USER_NAME]?.capitalized ?? "")"
        self.backupDescriptionLBL.text = "This will restore Hysab Kytab data to your last backup.\nClick on restore to proceed.\nIn case of any problem, you can always skip this to have a fresh start."
        UIUtils.showLoader(view: self.view)
        self.fetchBackupRecord()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    

    func fetchBackupRecord(){
        RestoreNetworkCalls.sharedInstance.getTotalRecords { (status, message, response) in
            print(response)
            if status == 1{
                print(response)
                if LocalPrefs.getBackupTotalCount() == 0 {
                    if let totalcount = response["data"]["totalRecordsCount"].int{
                        print(totalcount)
                        LocalPrefs.setBackupTotalCount(totalBackupCount: totalcount)
                        
                        print(LocalPrefs.getBackupTotalCount())
                        if LocalPrefs.getBackupTotalCount() == 0 {
                            self.navigateToLocationVC()
                        }
                        
                    }
                    if let accountsTotalCount = response["data"]["breadkdown"]["accountsTotal"]["totalCount"].int{
                        print(accountsTotalCount)
                        LocalPrefs.setAccountsTotalCount(count: accountsTotalCount)
                        print(LocalPrefs.getAccountsTotalCount())
                        self.workFlow_Count.append(WorkFlow_Record.init(WORKFLOW_CONSTANT: "ACCOUNT", WROKFLOW_COUNT: LocalPrefs.getAccountsTotalCount()))
                        
                    }
                    if let categoryTotalCount = response["data"]["breadkdown"]["categoriesTotal"]["totalCount"].int{
                        print(categoryTotalCount)
                        LocalPrefs.setCategoriesTotal(count: categoryTotalCount)
                        print(LocalPrefs.getCategoriesTotal())
                        self.workFlow_Count.append(WorkFlow_Record.init(WORKFLOW_CONSTANT: "CATEGORY", WROKFLOW_COUNT: LocalPrefs.getCategoriesTotal()))
                    }
                    if let transactionTotalCount = response["data"]["breadkdown"]["transactionTotal"]["totalCount"].int{
                        print(transactionTotalCount)
                        LocalPrefs.setTransactionTotal(count: transactionTotalCount)
                        print(LocalPrefs.getTransactionTotal())
                        self.workFlow_Count.append(WorkFlow_Record.init(WORKFLOW_CONSTANT: "TRANSACTION", WROKFLOW_COUNT: LocalPrefs.getTransactionTotal()))
                    }
                    if let eventsTotalCount = response["data"]["breadkdown"]["eventsTotal"]["totalCount"].int{
                        print(eventsTotalCount)
                        LocalPrefs.setEventsTotal(count: eventsTotalCount)
                        print(LocalPrefs.getEventsTotal())
                        self.workFlow_Count.append(WorkFlow_Record.init(WORKFLOW_CONSTANT: "EVENT", WROKFLOW_COUNT: LocalPrefs.getEventsTotal()))
                    }
                    if let budgetTotalCount = response["data"]["breadkdown"]["budgetsTotal"]["totalCount"].int{
                        print(budgetTotalCount)
                        LocalPrefs.setBudgetsTotal(count: budgetTotalCount)
                        print(LocalPrefs.getBudgetsTotal())
                        self.workFlow_Count.append(WorkFlow_Record.init(WORKFLOW_CONSTANT: "BUDGET", WROKFLOW_COUNT: LocalPrefs.getBudgetsTotal()))
                    }
                    if let savingTrxTotalCount = response["data"]["breadkdown"]["savingTrxTotal"]["totalCount"].int{
                        print(savingTrxTotalCount)
                        LocalPrefs.setSavingTrxTotal(count: savingTrxTotalCount)
                        print(LocalPrefs.getSavingTrxTotal())
                        self.workFlow_Count.append(WorkFlow_Record.init(WORKFLOW_CONSTANT: "SAVING_TRANSACTION", WROKFLOW_COUNT: LocalPrefs.getSavingTrxTotal()))
                    }
                    if let savingTotalCount = response["data"]["breadkdown"]["savingsTotal"]["totalCount"].int{
                        print(savingTotalCount)
                        LocalPrefs.setSavingsTotal(count: savingTotalCount)
                        print(LocalPrefs.getSavingsTotal())
                        self.workFlow_Count.append(WorkFlow_Record.init(WORKFLOW_CONSTANT: "SAVING", WROKFLOW_COUNT: LocalPrefs.getSavingsTotal()))
                    }
                    UIUtils.dismissLoader(uiView: self.view)
                } else {
                    UIUtils.dismissLoader(uiView: self.view)
                    self.navigateToRestoreVC()
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    */
    @IBAction func skipButtonPressed(_ sender: Any) {
        Analytics.logEvent("Backup_Found_Skip", parameters: nil)
        if let destination = self.getStoryboard(name: ViewIdentifiers.SB_BACKUP).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SKIP_MESSAGE) as? SkipRestoreMessage{
            destination.delegate = self
            destination.modalPresentationStyle = .overCurrentContext
            present(destination, animated: true, completion: nil)
        }
//        QueryUtils.saveAccounts()
//        QueryUtils.saveCategories()
//        LocalPrefs.setBackupTotalCount(totalBackupCount: 0)
//        self.navigateToLocationVC()
    }
    
    @IBAction func restoreButtonPressed(_ sender: Any) {
        Analytics.logEvent("Backup_Found_Restore", parameters: nil)
        if Reachability.isConnectedToNetwork(){
            self.navigateToRestoreVC()
        } else {
            UIUtils.showSnackbarNegative(message: "Check your internet connection")
        }
        
    }
    
    private func navigateToLocationVC() {
        
        let locationVC = getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_USER_LOCATION) as! UserLocationViewController
        self.navigationController?.pushViewController(locationVC, animated: true)
    }
    
    private func navigateToRestoreVC() {
        let restoreVC = getStoryboard(name: ViewIdentifiers.SB_BACKUP).instantiateViewController(withIdentifier: ViewIdentifiers.VC_RESTOREVC) as! RestoreVC
        self.navigationController?.pushViewController(restoreVC, animated: true)
    }
}
extension BackupMainVC: AlertResponse{
    func skipRestore() {
        self.clearDataFromServer()
        QueryUtils.saveAccounts()
        QueryUtils.saveCategories()
        LocalPrefs.setBackupTotalCount(totalBackupCount: 0)
        self.navigateToLocationVC()
    }
    
    func clearDataFromServer(){
        Analytics.logEvent("Wipe_Server", parameters: nil)
        RestoreNetworkCalls.sharedInstance.getWipAllData(isRestore: false) { status, message, response in
            if status == 1{
                print(response)
                print(message)
            } else{
                print(response)
                print(message)
                UIUtils.showSnackbarNegative(message: "Failed to clear Data")
            }
        }
    }
    
}
