

import UIKit
import Firebase

class SkipRestoreMessage: UIViewController {

    @IBOutlet weak var descriptionLBL: UILabel!
    var delegate: AlertResponse?
    var logout = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if logout{
            self.descriptionLBL.text = "Are you sure you want to log out? We recommend you to backup your data before logging out otherwise your unbacked up records will be wiped out permanently."
        }
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func noPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesPressed(_ sender: Any) {
        if logout{
            self.logoutUser()
        } else {
            self.dismiss(animated: true) {
                self.delegate?.skipRestore()
            }
        }
        
    }

    func logoutUser(){
        Analytics.logEvent("App_Logout", parameters: nil)
        LocalPrefs.setIsDataWiped(isDataWiped: false)
        LocalPrefs.setIsRegistered(isRegistered: false)
        LocalPrefs.setIsVerified(isVerified: false)
        
        let fccmToken = LocalPrefs.getDeviceToken()
        
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)

        QueryUtils.deleteAllSavings()
        QueryUtils.deleteAllAccounts()
        QueryUtils.deleteAllCategories()
        QueryUtils.deleteSavingTransactions()
        QueryUtils.deleteAllTransaction()
        QueryUtils.deleteAllBudgets()
        QueryUtils.deleteAllEvents()
        
        LocalPrefs.setDeviceToken(deviceToken: fccmToken)
//        DbController.shared.clearDatabase {
            let navController = UINavigationController()
            let storyboard = UIUtils.getStoryboard(name: ViewIdentifiers.SB_ONBOARDING)
            if let dest = storyboard.instantiateViewController(withIdentifier: "GetStartedVC") as? GetStartedViewController{
                navController.viewControllers = [dest]
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
    }

}
