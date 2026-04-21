

import UIKit

class SignupContinueAlertVC: UIViewController {

    @IBOutlet weak var userNameLBL: UILabel!
    var delegate: AlreadySignUpUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userNameLBL.text = "Hey \(LocalPrefs.getUserName()) !"
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.continueSignUp()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
