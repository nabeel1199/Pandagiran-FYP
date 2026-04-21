

import UIKit

protocol UserTypeSelectionListener {
    func onUserTypeSelected (user: UserDescription)
}

class UserTypeSelectionPopup: BasePopup {

    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var table_view_user_type: UITableView!
    
    private var nibUserName = "UserSelectionViewCell"
    private var userDescriptionArray : Array<UserDescription> = []
    
    public var delegate : UserTypeSelectionListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()


        initVariables()
        populateUserDescriptionArray()

    }

    private func initVariables () {
        initNibs()
        
        table_view_user_type.delegate = self
        table_view_user_type.dataSource = self
    }
    
    private func initNibs () {
        let nibUserType = UINib(nibName: nibUserName, bundle: nil)
        table_view_user_type.register(nibUserType, forCellReuseIdentifier: nibUserName)
    }
    
    private func populateUserDescriptionArray () {
        userDescriptionArray.append(UserDescription(boxColor : "#2196f3", boxIcon : "bt_1", userOccupation : "Student"))
        userDescriptionArray.append(UserDescription(boxColor : "#795548", boxIcon : "bt_90", userOccupation : "Professional"))
        userDescriptionArray.append(UserDescription(boxColor : "#33691e", boxIcon : "bt_2", userOccupation : "Housewife"))
        userDescriptionArray.append(UserDescription(boxColor : "#e91e63", boxIcon : "bt_65", userOccupation : "Retired"))
    }

    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension UserTypeSelectionPopup : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDescriptionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view_user_type.dequeueReusableCell(withIdentifier: nibUserName, for: indexPath) as! UserSelectionViewCell
        
        let user = userDescriptionArray[indexPath.row]
        cell.iv_user.image = UIImage(named: user.boxIcon!)
        cell.label_profession_type.text = user.userOccupation
        cell.bg_view.backgroundColor = UIColor.clear
        
        tableHeight.constant = tableView.contentSize.height
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userDescriptionArray[indexPath.row]
        delegate?.onUserTypeSelected(user: user)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
