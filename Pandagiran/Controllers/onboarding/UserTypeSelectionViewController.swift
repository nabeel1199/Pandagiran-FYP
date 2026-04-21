

import UIKit
import Kingfisher
import FirebaseAnalytics

class UserTypeSelectionViewController: BaseViewController {

    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var view_currency: UIView!
    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var iv_country_flag: UIImageView!
    @IBOutlet weak var table_view_user_types: UITableView!
    
    private let nibUserTypeName = "UserSelectionViewCell"
    private var userDescriptionArray : Array<UserDescription> = []
    private var userType = ""
    private var userCurrency = "PKR"
    private var currencyFlag = "http://bo.hysabkytab.com/HK_data_pics/country_flags/pk.png"
    
    public var user : UserData?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI ()
        populateUserDescriptionArray()

    }

    private func populateUserDescriptionArray () {
        userDescriptionArray.append(UserDescription(boxColor : "#2196f3", boxIcon : "bt_1", userOccupation : "Student"))
        userDescriptionArray.append(UserDescription(boxColor : "#795548", boxIcon : "bt_90", userOccupation : "Professional"))
        userDescriptionArray.append(UserDescription(boxColor : "#33691e", boxIcon : "bt_2", userOccupation : "Housewife"))
        userDescriptionArray.append(UserDescription(boxColor : "#e91e63", boxIcon : "bt_65", userOccupation : "Retired"))
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_user_types.delegate = self
        table_view_user_types.dataSource = self
    }
    
    private func initNibs () {
        let nibuserType = UINib(nibName: nibUserTypeName, bundle: nil)
        table_view_user_types.register(nibuserType, forCellReuseIdentifier: nibUserTypeName)
    }
    
    private func initUI () {
        iv_country_flag.kf.setImage(with: URL(string: currencyFlag))
        LocalPrefs.setCountryName(countryName: "PK")
        label_currency.text = userCurrency
        self.viewBackgroundColor = .white
        self.navigationItemColor = .light
        
        let currencyTapGest = UITapGestureRecognizer(target: self, action: #selector(onCurrencyTapped))
        view_currency.addGestureRecognizer(currencyTapGest)
    }
    
    @IBAction func onNextTapped(_ sender: Any) {
        if Utils.validateString(vc: self, string: userType, errorMsg: "Please select User Type") {
            user?.userCurrency = userCurrency
            user?.userType = userType
            user?.currencyFlag = currencyFlag
            user?.countryFlag = "http://bo.hysabkytab.com/HK_data_pics/country_flags/pk.png"
            
            Analytics.logEvent("USOB_6_profile_entered", parameters: nil)
            let userInterestsVC = getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_USER_INTERESTS) as! UserInterestsViewController
            userInterestsVC.user = user
            self.navigationController?.pushViewController(userInterestsVC, animated: true)
        }
      
    }
    
    @objc private func onCurrencyTapped () {
        let currencyVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SELECT_CURRENCY) as! AccountCurrencyViewController
        currencyVC.myDelegate = self
        self.navigationController?.pushViewController(currencyVC, animated: true)
    }
    
}

extension UserTypeSelectionViewController : UITableViewDelegate , UITableViewDataSource, CurrencySelectionListener {

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDescriptionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view_user_types.dequeueReusableCell(withIdentifier: nibUserTypeName, for: indexPath) as! UserSelectionViewCell
        
        let user = userDescriptionArray[indexPath.row]
        cell.iv_user.image = UIImage(named: user.boxIcon!)
        cell.label_profession_type.text = user.userOccupation
        
        tableViewHeight.constant = tableView.contentSize.height
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userType = userDescriptionArray[indexPath.row].userOccupation!
    }
    
    func onCurrencySelected(currency: String, country2dg: String, currencyFlag: String, countryName: String, decimal: Int) {
        self.userCurrency = currency
        self.currencyFlag = currencyFlag
        iv_country_flag.kf.setImage(with: URL(string: currencyFlag))
        LocalPrefs.setDecimalFormat(decimalFormat: decimal)
        label_currency.text = currency
    }
    
    
}
