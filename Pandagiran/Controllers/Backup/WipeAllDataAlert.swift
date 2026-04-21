

import UIKit
import Firebase

class WipeAllDataAlert: UIViewController {
    
    @IBOutlet weak var wipeFromLocalButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func wipeFromServerPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            self.clearDataFromServer()
        } else {
            UIUtils.showSnackbarNegative(message: "Please check your internet connection")
        }
        
    }
    
    @IBAction func wipeFromLocalStoragePressed(_ sender: Any) {
        self.clearFromLocal()
    }
    
    
    func clearDataFromServer(){
        Analytics.logEvent("Wipe_Server", parameters: nil)
        RestoreNetworkCalls.sharedInstance.getWipAllData(isRestore: false) { status, message, response in
            if status == 1{
                print(response)
                print(message)
                self.clearFromLocal()
                UIUtils.showSnackbar(message: message)
            } else{
                print(response)
                print(message)
                UIUtils.showSnackbarNegative(message: "Failed to clear Data")
            }
        }
    }
    
    func clearFromLocal(){
        LocalPrefs.setIsDataWiped(isDataWiped: true)
        QueryUtils.deleteAllSavings()
        QueryUtils.deleteAllAccounts()
        QueryUtils.deleteAllCategories()
        QueryUtils.deleteSavingTransactions()
        QueryUtils.deleteAllTransaction()
        QueryUtils.deleteAllBudgets()
        QueryUtils.deleteAllEvents()
        let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
        let dest = storyboard.instantiateViewController(withIdentifier: "LandingViewController")
        dest.modalPresentationStyle = .fullScreen
        self.present(dest, animated: true, completion: nil)
    }
    
    

}
