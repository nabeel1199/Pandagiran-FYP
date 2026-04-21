

import UIKit

class AboutViewController: BaseViewController {

    @IBOutlet weak var label_app_version: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    func initUI () {        
       label_app_version.text = getAppVersion()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @IBAction func onPrivacyPolicyTapped(_ sender: Any) {
        guard let url = URL(string: "http://hysabkytab.com/policy.html") else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func getAppVersion () -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        let appVersion = nsObject as! String
        return appVersion
    }
    
    @objc private func onBackTapped () {
        self.dismiss(animated: false, completion: nil)
    }
    
}
