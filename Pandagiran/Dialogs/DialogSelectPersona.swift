

import UIKit

class DialogSelectPersona: UIViewController {

    @IBOutlet weak var table_view: UITableView!
    
    var userDescriptionArray : Array<UserDescription> = []
    public var myDelegate : PersonaSelectionListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()

  
        initVariables()
        populatePersonaArray()
        initUI ()
    }
    
    private func initVariables () {
        table_view.dataSource = self
        table_view.delegate = self
        
        let nibTimeInterval = UINib(nibName : "VoucherAccountViewCell" , bundle : nil)
        table_view.register(nibTimeInterval, forCellReuseIdentifier: "VoucherAccountsViewCell")
    }
    
    private func initUI () {
        overLayBlurredBg()
    }
    
    private func overLayBlurredBg () {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = self.view.bounds
        blurredBackgroundView.effect = UIBlurEffect(style: .regular)
        blurredBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurredBackgroundView, at: 0)
    }
    
    func populatePersonaArray () {
        userDescriptionArray.append(UserDescription(boxColor : "#2196f3", boxIcon : "bt_1", userOccupation : "Student"))
        userDescriptionArray.append(UserDescription(boxColor : "#795548", boxIcon : "bt_90", userOccupation : "Professional"))
        userDescriptionArray.append(UserDescription(boxColor : "#33691e", boxIcon : "bt_2", userOccupation : "Housewife"))
        userDescriptionArray.append(UserDescription(boxColor : "#e91e63", boxIcon : "bt_65", userOccupation : "Retired"))
    }

    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DialogSelectPersona : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDescriptionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view.dequeueReusableCell(withIdentifier: "VoucherAccountsViewCell", for: indexPath) as! VoucherAccountViewCell
        let persona = userDescriptionArray[indexPath.row]
        cell.accountTitle.text = persona.userOccupation
        cell.accountImage.image = UIImage(named : persona.boxIcon!)?.withRenderingMode(.alwaysTemplate)
        cell.accountImage.tintColor = Utils.hexStringToUIColor(hex: persona.boxColor!)
        cell.bgView.layer.borderColor = Utils.hexStringToUIColor(hex: persona.boxColor!).cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myDelegate?.onPersonaSelected(personaType: userDescriptionArray[indexPath.row].userOccupation!)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
