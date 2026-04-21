

import UIKit

protocol onAgreeTap: AnyObject{
    func agreeTapped()
}

class NITConfrimationPopup: BasePopup {
    
    weak var agreeTap: onAgreeTap?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func agreeBtn(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        agreeTap?.agreeTapped()
    }
    

    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissBtn(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
}
