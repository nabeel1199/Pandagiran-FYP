

import UIKit

class NITIntroductionController: BaseViewController {
    
    @IBOutlet weak var introText: UITextView!
    
    var introductionText: String?
    var id : Int?
    var investmentPlanId : Int?
    var ivestmentTitle : String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = ivestmentTitle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
    }
    
    private func initUI(){
        let button = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(onCloseTapped))
        navigationItem.leftBarButtonItem = button
        self.introText.text = self.introductionText
        introText.isEditable = false
        self.view.backgroundColor = UIColor().hexCode(hex: "#F5F7FC")
    }
    
    
    
    @objc func onCloseTapped(){
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnTapped(_ sender: Any){
        let dest = getStoryboard(name: ViewIdentifiers.SB_HKNIT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_HK_NIT_INVESTMENTFORM) as! InvestmentForm
        dest.id = self.id
        dest.ivestmentTitle = self.ivestmentTitle
        dest.investmentPlanId = self.investmentPlanId
        navigationItem.title = ""
        self.navigationController?.pushViewController(dest, animated: true)
    }

}

