

import UIKit
import Firebase
import GoogleSignIn
import Kingfisher


class SideMenu: BaseViewController , UITableViewDelegate , UITableViewDataSource /*, InviteDelegate*/ {
    
    
    var cellDataArray = [CellData] ()
    
    @IBOutlet weak var consumer_email: UILabel!
    @IBOutlet weak var label_consumer_id: UILabel!
    @IBOutlet weak var iv_user_image: UIImageView!
    @IBOutlet weak var tv_user_name: UILabel!
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var view_user_details: UIView!

    
     
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.setUserInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        populateCellData()
        initTapGestureUserDetails()
    }
    
    
    func initVariables() {
        table_view.delegate = self
        table_view.dataSource = self

    }
    

    
    func setUserInfo(){
        if let name = LocalPrefs.getUserData()[Constants.USER_NAME] {
           tv_user_name.text = name
        }
        
        if let email = LocalPrefs.getUserData()[Constants.EMAIL] {
            label_consumer_id.text = email
        }
        
        iv_user_image.layer.borderWidth = 1
        iv_user_image.layer.masksToBounds = false
        iv_user_image.layer.borderColor = UIColor.clear.cgColor
        iv_user_image.layer.cornerRadius = iv_user_image.frame.height/2
        iv_user_image.clipsToBounds = true
        iv_user_image.contentMode = .scaleAspectFill
        
        if LocalPrefs.checkForNil(key: LocalPrefs.USER_IMAGE) {
            let imageData = LocalPrefs.getUserImage()
            let fetchedImg = UIImage(data : imageData)
            iv_user_image.image = fetchedImg
        }
        
        self.view.layer.borderColor = UIColor.white.cgColor
    }
    
    func initUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    
    func populateCellData() {
        cellDataArray = [
            CellData(cell : 1 , text : "Accounts" , icon :  #imageLiteral(resourceName: "ic_account"), tag: "accounts") ,
            CellData(cell: 2, text: "Categories", icon: UIImage(named: "bt_14")!, tag: "categories"),
            CellData(cell : 3 , text : "Settings" , icon :  #imageLiteral(resourceName: "ic_settings") , tag: "settings") ]
    }
    
    func initTapGestureUserDetails () {
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(onUserDetailsViewTapped))
        view_user_details.addGestureRecognizer(tapGest)
    }
    
    
    @objc func onUserDetailsViewTapped () {
        let profileVC = getStoryboard(name: ViewIdentifiers.SB_SETTINGS).instantiateViewController(withIdentifier: ViewIdentifiers.VC_PROFILE) as! UserProfileViewController
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = Bundle.main.loadNibNamed("NavigationViewCell", owner: self, options: nil)?.first as! NavigationViewCell
            cell.navImage.image = cellDataArray[indexPath.row].icon?.withRenderingMode(.alwaysTemplate)
            cell.label_nav_text.text = cellDataArray[indexPath.row].text
            cell.selectionStyle = .none
            return cell
        }
        
    

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name : "Main" , bundle : nil)
        let tag = cellDataArray[indexPath.row].tag!

        switch tag {
        case "home" :
            dismiss(animated: true, completion: nil)
            break
        case "accounts":
            let dest = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: "AccountBalancesVC") as! AccountBalancesViewController
            self.navigationController?.pushViewController(dest, animated: true)
            break
        case "categories":
            let dest = getStoryboard(name: ViewIdentifiers.SB_CATEGORY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_CATEGORIES) as! CategoriesViewController
            self.navigationController?.pushViewController(dest, animated: true)
            break
        case "settings":
            let settingsVC = getStoryboard(name: ViewIdentifiers.SB_SETTINGS).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SETTINGS) as! SettingsViewController
            self.navigationController?.pushViewController(settingsVC, animated: true)
            break
        default:
            dismiss(animated: true, completion: nil)
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        table_view.reloadData()
        table_view.setContentOffset(CGPoint(x : 0 , y : 0), animated: false)
    }
    
}
