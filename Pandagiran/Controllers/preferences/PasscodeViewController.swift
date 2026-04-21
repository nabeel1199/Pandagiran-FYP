

import UIKit
import PinCodeTextField
import AudioToolbox
import LocalAuthentication

class PasscodeViewController: BaseViewController {

    
    @IBOutlet weak var iv_logo: UIImageView!
    @IBOutlet weak var view_touch_id: UIView!
    @IBOutlet weak var btn_set_pin: UIButton!
    @IBOutlet weak var et_pass_code: PinCodeTextField!
    @IBOutlet weak var btn_clear: UIButton!
    
    var isUpdate : Bool = true
    
    
    override func viewDidLoad() {


        initVariables()
        initUI()
        aunthenticateWithTouchId()

    }
    
    func initVariables() {
        // Disable tap on passcode field
        et_pass_code.isUserInteractionEnabled = false
    }
    
    func initUI () {
        self.viewBackgroundColor = .dark
        et_pass_code.text = ""
        
        // isUpdate will be true when user is setting or changing the pin
        if !isUpdate {
            UIUtils.viewGone(view: btn_set_pin)
            btn_set_pin.isHidden = true
            view_touch_id.isHidden = false
            iv_logo.isHidden = true
        }

        if LocalPrefs.checkForNil(key: LocalPrefs.PASSCODE) {
            btn_set_pin.setTitle("CHANGE PIN", for: .normal)
        }
        
        view_touch_id.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onViewTouchIDTapped)))
    }
    
    private func aunthenticateWithTouchId () {
        if !isUpdate {
            let myContext = LAContext()
            let myLocalizedReasonString = "Biometric Authentication Required"
            
            var authError: NSError?
            if #available(iOS 8.0, macOS 10.12.1, *) {
                if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                    myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                        
                        DispatchQueue.main.async {
                            if success {
                                // User authenticated successfully, take appropriate action
                                //                            self.successLabel.text = "Awesome!!... User authenticated successfully"
                                print("SUCCESSFUL")
                                self.navigateToMainVC()
                            } else {
                                // User did not authenticate successfully, look at error and take appropriate action
                                print("FAILED TO AUTHENTICATE")
                            }
                        }
                    }
                } else {
                    // Could not evaluate policy; look at authError and present an appropriate message to user
                    print("POLICY EVALUATION")
                }
            } else {
                // Fallback on earlier versions
                
                print("FEATURE NOT SUPPORTED")
            }
        }
    }
    
    @objc private func onViewTouchIDTapped () {
        aunthenticateWithTouchId()
    }
    
    
    @IBAction func onLabel1Tapped(_ sender: Any) {
        et_pass_code.text = "\(et_pass_code.text!)1"
        textFieldCouldPerhapsReturn()
    }
    
    @IBAction func onLabel2Tapped(_ sender: Any) {
        et_pass_code.text = "\(et_pass_code.text!)2"
        textFieldCouldPerhapsReturn()
    }
    
    @IBAction func onLabel3Tapped(_ sender: Any) {
        et_pass_code.text = "\(et_pass_code.text!)3"
        textFieldCouldPerhapsReturn()
    }
    
    @IBAction func onLabel4Tapped(_ sender: Any) {
        et_pass_code.text = "\(et_pass_code.text!)4"
        textFieldCouldPerhapsReturn()
    }
    
    @IBAction func onLabel5Tapped(_ sender: Any) {
        et_pass_code.text = "\(et_pass_code.text!)5"
        textFieldCouldPerhapsReturn()
    }
    
    @IBAction func onLabel6Tapped(_ sender: Any) {
        et_pass_code.text = "\(et_pass_code.text!)6"
        textFieldCouldPerhapsReturn()
    }
    
    @IBAction func onLabel7Tapped(_ sender: Any) {
        et_pass_code.text = "\(et_pass_code.text!)7"
        textFieldCouldPerhapsReturn()
    }
    
    @IBAction func onLabel8Tapped(_ sender: Any) {
        et_pass_code.text = "\(et_pass_code.text!)8"
        textFieldCouldPerhapsReturn()
    }
    
    @IBAction func onLabel9Tapped(_ sender: Any) {
        et_pass_code.text = "\(et_pass_code.text!)9"
        textFieldCouldPerhapsReturn()
        
    }
    
    @IBAction func onLabel0Tapped(_ sender: Any) {
        et_pass_code.text = "\(et_pass_code.text!)0"
        textFieldCouldPerhapsReturn()
    }
    
    @IBAction func onClearTapped(_ sender: Any) {
        if (et_pass_code.text?.count)! >= 1 {
              et_pass_code.text = Utils.customSubstring(givenString: et_pass_code.text!, location: 0, endIndex: (et_pass_code.text?.count)! - 1)
        }
    }
    
    @IBAction func onSetPinTapped(_ sender: Any) {
        if et_pass_code.text?.count == 4 {
            LocalPrefs.setPasscode(passcode: et_pass_code.text!)
            self.navigationController?.popViewController(animated: true)
        } else {
            animateView()
            UIUtils.showSnackbarNegative(message: "Passcode must contain 4 digits")
        }
    }
    
    // Animate the passcode field on wrong passcode entered
    private func animateView () {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: et_pass_code.center.x - 10, y: et_pass_code.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: et_pass_code.center.x + 10, y: et_pass_code.center.y))
        
        et_pass_code.layer.add(animation, forKey: "position")
    }
    
    private func navigateToMainVC () {
        let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
        let dest = storyboard.instantiateViewController(withIdentifier: "MainVC")
        self.present(dest, animated: true, completion: nil)
    }
    
    // Check if maximum length reached and take action on the input provided.
    private func textFieldCouldPerhapsReturn () {
        if !isUpdate {
            if et_pass_code.text?.count == 4 {
                if et_pass_code.text! == LocalPrefs.getPasscode() {
                  navigateToMainVC()
                } else {
                    animateView()
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    animateView()
                    et_pass_code.text = ""
                    UIUtils.showSnackbarNegative(message: "Wrong passcode, please try again")
                }
            }
        }
    }
}



