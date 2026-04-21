

import UIKit
import Alamofire
import SwiftyJSON

class UserProfileViewController: BaseViewController {
    
    @IBOutlet weak var iv_user_type: TintedImageView!
    @IBOutlet weak var viewStatsHeight: NSLayoutConstraint!
    @IBOutlet weak var btn_save: GradientButton!
    @IBOutlet weak var btn_female: GradientButton!
    @IBOutlet weak var btn_male: GradientButton!
    @IBOutlet weak var label_phone_no: DecimalTextField!
    @IBOutlet weak var label_country_2dg: UILabel!
    @IBOutlet weak var iv_country_flag: UIImageView!
    @IBOutlet weak var text_field_password: UITextField!
    @IBOutlet weak var text_field_email: UITextField!
    @IBOutlet weak var btn_dob: UIButton!
    @IBOutlet weak var view_dob: CardView!
    @IBOutlet weak var view_user_type: CardView!
    @IBOutlet weak var btn_user_type: UIButton!
    @IBOutlet weak var text_field_name: UITextField!
    @IBOutlet weak var view_stats: UIView!
    @IBOutlet weak var label_join_date: UILabel!
    @IBOutlet weak var label_user_name: UILabel!
    @IBOutlet weak var iv_user: CircularImageView!

    private let picker = UIImagePickerController()
    private var userDescriptionArray: Array<UserDescription> = []
    private var gender = ""
    private var userDob = ""
    private var userType = ""
    private var userPhone = ""
            
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        imageSelectGest()
        populateUserDescriptionArray()
        setUserDetails()
    }
    
    private func initVariables () {
        text_field_name.delegate = self
        text_field_email.delegate = self
        picker.delegate = self
    }
    
    
    private func initUI () {
        // TEMPORARY REMOVAL
        viewStatsHeight.constant = 0
        view_stats.isHidden = true
        text_field_email.isUserInteractionEnabled = false
        
        enableEditing(shouldEnable: false)
        self.navigationItem.title = "Profile Info"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_edit"), style: .plain, target: self, action: #selector(onEditTapped))
        self.viewBackgroundColor = .white

        
        let viewDobGest = UITapGestureRecognizer(target: self, action: #selector(onDobTapped))
        view_dob.addGestureRecognizer(viewDobGest)
        
        let userTypeGest = UITapGestureRecognizer(target: self, action: #selector(onUserTypeTapped))
        view_user_type.addGestureRecognizer(userTypeGest)
        
        if LocalPrefs.checkForNil(key: LocalPrefs.USER_IMAGE) {
            let imageData = LocalPrefs.getUserImage()
            let fetchedImg = UIImage(data : imageData)
            iv_user.image = fetchedImg
        }
        
        btn_user_type.isUserInteractionEnabled = false
    }
    
    private func populateUserDescriptionArray () {
        userDescriptionArray.append(UserDescription(boxColor : "#2196f3", boxIcon : "bt_1", userOccupation : "Student"))
        userDescriptionArray.append(UserDescription(boxColor : "#795548", boxIcon : "bt_90", userOccupation : "Professional"))
        userDescriptionArray.append(UserDescription(boxColor : "#33691e", boxIcon : "bt_2", userOccupation : "Housewife"))
        userDescriptionArray.append(UserDescription(boxColor : "#e91e63", boxIcon : "bt_65", userOccupation : "Retired"))
    }
    
    private func setUserDetails ()  {
        let userDetails : [String:String] = LocalPrefs.getUserData()
        
        if let name = userDetails[Constants.USER_NAME] {
            text_field_name.text = name
            label_user_name.text = name
        }
        
        if let email = userDetails[Constants.EMAIL] {
            text_field_email.text = email
            label_join_date.text = email
        }
        
        label_join_date.text = LocalPrefs.getUserPhone()
        
        if let userType = userDetails[Constants.USER_TYPE] {
            self.userType = userType
            if let user = userDescriptionArray.first(where: {$0.userOccupation == userType}) {
                btn_user_type.setTitle(user.userOccupation!, for: .normal)
                iv_user_type.image = UIImage(named: user.boxIcon!)?.withRenderingMode(.alwaysTemplate)
            }
        }
        
        if let dob = userDetails[Constants.USER_DOB] {
            self.userDob = dob
            let dobDate = Utils.convertStringToDate(dateString: dob)
            btn_dob.setTitle(Utils.currentDateUserFormat(date: dobDate), for: .normal)
        }
        
        if let gender = userDetails[Constants.GENDER] {
            configureGenderButtons(userGender: gender)
        }
        
        if let phone = userDetails[Constants.USER_PHONE] {
            userPhone = phone
        }
    }
    
    private func imageSelectGest () {
        iv_user.isUserInteractionEnabled = true
        let profileGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageDialog))
        iv_user.addGestureRecognizer(profileGesture)
    }
    
    @objc private func selectImageDialog () {
        var alert = UIAlertController()
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: "Profile picture", message: "Select image from photos or camera to set a profile picture : ", preferredStyle: UIAlertController.Style.alert)
        } else {
            alert = UIAlertController(title: "Profile picture", message: "Select image from photos or camera to set a profile picture : ", preferredStyle: UIAlertController.Style.actionSheet)
        }
        
        alert.view.superview?.isUserInteractionEnabled = true
        //        alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alertClose)))
        alert.addAction(UIAlertAction(title: "Photos", style: UIAlertAction.Style.default, handler: {action in
            self.picker.allowsEditing = false
            self.picker.sourceType = .photoLibrary
            self.picker.mediaTypes = ["public.image"]
            self.present(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: {action in
            self.picker.allowsEditing = false
            self.picker.sourceType = UIImagePickerController.SourceType.camera
            self.picker.cameraCaptureMode = .photo
            self.picker.mediaTypes = ["public.image"]
            self.picker.modalPresentationStyle = .fullScreen
            self.present(self.picker,animated: true,completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateProfileNetworkCall () {
        UIUtils.showLoader(view: self.view)
        let URL = "\(Constants.BASE_URL_SYNC)/consumers/profile/update"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        let dictToEncrypt = [  "device_type" : "Ios",
                        "profession_type" : userType,
                        "consumer_id" : "\(LocalPrefs.getConsumerId())",
                        "currency" : LocalPrefs.getUserCurrency(),
                        "gender" : gender,
                        "dob" : userDob,
                        "email" : text_field_email.text!,
                        "name" : text_field_name.text!]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
//                UIUtils.dismissLoader(uiView: self.view)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
//                    let responseObj = JSON(response.result.value!)
//                    let status = responseObj["status"].intValue
//                    let message = responseObj["message"].stringValue
                    
                    if status == 1 {
                        let userDetails : [String : String] = [
                            Constants.CONSUMER_ID : "\(LocalPrefs.getConsumerId())",
                            Constants.GENDER : self.gender,
                            Constants.EMAIL : self.text_field_email.text!,
                            Constants.TOKEN : LocalPrefs.getDeviceToken(),
                            Constants.USER_NAME : self.text_field_name.text!,
                            Constants.USER_PHONE : self.userPhone,
                            Constants.CURRENCY : LocalPrefs.getUserCurrency(),
                            Constants.USER_DOB : self.userDob,
                            Constants.USER_TYPE : self.userType]
                        
                        UIUtils.dismissLoader(uiView: self.view)
                        LocalPrefs.setUserData(userDetails: userDetails)
                        LocalPrefs.setProfessionType(professionType: self.userType)
                        UIUtils.showSnackbar(message: "Profile updated successfully!")
                        
 
                        self.navigationController?.popViewController(animated: true)
                        
                        
                    } else {
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }

    private func enableEditing (shouldEnable: Bool) {
        text_field_name.isUserInteractionEnabled = shouldEnable
        text_field_email.isUserInteractionEnabled = false
        view_user_type.isUserInteractionEnabled = shouldEnable
        view_dob.isUserInteractionEnabled = shouldEnable
        btn_male.isUserInteractionEnabled = shouldEnable
        btn_female.isUserInteractionEnabled = shouldEnable
    }
    
    private func configureGenderButtons (userGender : String) {
        if userGender == (btn_male.titleLabel?.text)! {
            gender = (btn_male.titleLabel?.text)!
            btn_male.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            btn_female.backgroundColor = UIColor.groupTableViewBackground
            btn_male.setTitleColor(UIColor.white, for: .normal)
            btn_female.setTitleColor(UIColor.black, for: .normal)
        } else if userGender == (btn_female.titleLabel?.text)! {
            gender = (btn_female.titleLabel?.text)!
            btn_male.backgroundColor =  UIColor.groupTableViewBackground
            btn_female.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            btn_male.setTitleColor(UIColor.black, for: .normal)
            btn_female.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    @objc private func onDobTapped () {
        let datePopup = DialogSelectDate()
        datePopup.myDelegate = self
        datePopup.customDate = Utils.convertStringToDate(dateString: userDob)
        self.presentPopupView(popupView: datePopup)
    }
    
    @objc private func onUserTypeTapped () {
        let userSelectionPopup = UserTypeSelectionPopup()
        userSelectionPopup.delegate = self
        self.presentPopupView(popupView: userSelectionPopup)
    }
    
    @objc private func onEditTapped () {
        enableEditing(shouldEnable: true)
//        viewStatsHeight.constant = 0
//        view_stats.isHidden = true
        btn_save.isHidden = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onClearTapped))
    }
    
    @objc private func onClearTapped () {
        enableEditing(shouldEnable: false)
//        viewStatsHeight.constant = 60
//        view_stats.isHidden = false
        btn_save.isHidden = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_edit"), style: .plain, target: self, action: #selector(onEditTapped))
    }
    
    @objc private func onBackTapped () {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func onMaleTapped(_ sender: Any) {
        configureGenderButtons(userGender: (btn_male.titleLabel?.text)!)
    }
    
    @IBAction func onFemaleTapped(_ sender: Any) {
        configureGenderButtons(userGender: (btn_female.titleLabel?.text)!)
    }
    
    @IBAction func onSaveChangesTapped(_ sender: Any) {
        let trimmedEmail = text_field_email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utils.validateString(vc: self, string: text_field_name.text!, errorMsg: "Please enter your name") &&
            Utils.validateString(vc: self, string: userType, errorMsg: "Please select user type") && Utils.validateString(vc: self, string: userDob, errorMsg: "Please select your date of birth") && Utils.isValidEmail(vc: self, string: trimmedEmail, errorMsg: "Email is invalid") {
            
            updateProfileNetworkCall()
            
        }
    }
}

extension UserProfileViewController: DateSelectionListener, UserTypeSelectionListener, UITextFieldDelegate {
    
    
    func onUserTypeSelected(user: UserDescription) {
        userType = user.userOccupation!
        btn_user_type.setTitle(userType, for: .normal)
        iv_user_type.image = UIImage(named: user.boxIcon!)?.withRenderingMode(.alwaysTemplate)
    }
    
    func onDateSelected(date: Date) {
        userDob = Utils.currentDateDbFormat(date: date)
        btn_dob.setTitle(Utils.currentDateUserFormat(date: date), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == text_field_email {
            self.animateTextField(up: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == text_field_email {
            self.animateTextField(up: false)
        }
    }
}

extension UserProfileViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    // image picker delegates here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var chosenImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
        iv_user.contentMode = .scaleAspectFill
        iv_user.image = chosenImage
        chosenImage = Utils.resizeImage(image: chosenImage, targetSize: CGSize(width : 200 , height : 200))
        let data = chosenImage.jpegData(compressionQuality: 0.3)
        LocalPrefs.setUserImage(data: data!)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
