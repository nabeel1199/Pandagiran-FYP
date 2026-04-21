

import UIKit

class NITSuccessScreen: BaseViewController {
    
    @IBOutlet weak var nameLbl: UILabel!
    
    var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        initVariable()
        initUI()
    }
    
    private func initVariable(){
         self.nameLbl.text = "\(userName!)!"
         self.navigationItem.setHidesBackButton(true, animated: false)
     }
    
    private func initUI(){
        self.view.backgroundColor = UIColor().hexCode(hex: "#F5F7FC")

    }
    
    @IBAction func homeBtn(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
 

}
