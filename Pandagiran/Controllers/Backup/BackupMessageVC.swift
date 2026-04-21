

import UIKit

class BackupMessageVC: UIViewController {

    @IBOutlet weak var detailLBL: UILabel!
    var delegate: NormalState?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        
    }

    @IBAction func privacyPressed(_ sender: Any) {
        if let url = URL(string: "http://hysabkytab.com/policy.html") {
            UIApplication.shared.open(url)
        }
    }
    

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true){
            self.delegate?.normalState()
        }
    }
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true){
            self.delegate?.normalState()
        }
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
