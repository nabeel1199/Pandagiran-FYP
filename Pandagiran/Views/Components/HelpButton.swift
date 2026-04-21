

import UIKit

class HelpButton: UIButton {

    
    public struct DialogDetails {
        public var dialogTitle: String?
        public var dialogText: String?
    }
    
    public var dialogDetails = DialogDetails()
    
    override func prepareForInterfaceBuilder() {
        self.configure()
        self.addTarget(self, action: #selector(showHelpDialog), for: .touchUpInside)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configure()
        self.addTarget(self, action: #selector(showHelpDialog), for: .touchUpInside)
    }
    
    @IBInspectable override var tintColor: UIColor! {
        didSet {
            self.configure()
        }
    }
    
    private func configure() {
        let image = UIImage(named : "ic_help")?.withRenderingMode(.alwaysTemplate)
        self.setImage(image, for: .normal)
    }
    
    @objc private func showHelpDialog () {
        let vc = getCurrentViewController()
        let alert = UIAlertController(title: dialogDetails.dialogTitle, message: dialogDetails.dialogText, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        vc?.present(alert, animated: true, completion: nil)
    }
    
    func getCurrentViewController() -> UIViewController? {
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
        
    }

}
