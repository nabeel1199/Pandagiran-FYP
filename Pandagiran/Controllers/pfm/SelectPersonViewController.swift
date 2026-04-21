

import UIKit

class SelectPersonViewController: BaseViewController {

    @IBOutlet weak var table_view_person: UITableView!
    
    private let nibPersonName = "PersonAccountViewCell"
    private let headerTitles = ["People who use Hysab Kytab", "People in your contacts"]
    
    
    override func viewDidLoad() {


        initVariables()
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_person.delegate = self
        table_view_person.dataSource = self
    }
    
    private func initNibs () {
        let nibPerson = UINib(nibName: nibPersonName, bundle: nil)
        table_view_person.register(nibPerson, forCellReuseIdentifier: nibPersonName)
    }
}

extension SelectPersonViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibPersonName, for: indexPath) as! PersonAccountViewCell
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accountBalanceVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACCOUNT_BALANCE) as! AccountBalanceViewController
        
        accountBalanceVC.accountName = "Albus"
        accountBalanceVC.accountType = "Person"
        self.navigationController?.pushViewController(accountBalanceVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: self.table_view_person.frame.width, height: 60))
        returnedView.backgroundColor = UIColor.white
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.table_view_person.frame.width, height: 40))
        label.text = headerTitles[section]
        label.font = UIFont(name: "Montserrat", size: 12.0)
        returnedView.addSubview(label)
        
        return returnedView
    }
    
    
}
