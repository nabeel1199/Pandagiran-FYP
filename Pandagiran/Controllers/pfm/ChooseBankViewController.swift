

import UIKit
import SwiftyJSON

class ChooseBankViewController: BaseViewController {

    
    @IBOutlet weak var table_view_banks: UITableView!
    private let nibPersonName = "PersonAccountViewCell"
    private var arrayOfBanks : Array<Bank> = []
    
    
    override func viewDidLoad() {
        
        
        initVariables()
        fetchBanksFromJson()
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_banks.delegate = self
        table_view_banks.dataSource = self
    }
    
    private func initNibs () {
        let nibPerson = UINib(nibName: nibPersonName, bundle: nil)
        table_view_banks.register(nibPerson, forCellReuseIdentifier: nibPersonName)
    }
    
    private func fetchBanksFromJson () {
        let banksJsonArray = Utils.readJson(resourceName: "banks")
        
        for bankObjJson in banksJsonArray {
            let bankObj = JSON(bankObjJson).dictionaryValue
            var bank = Bank()
            bank.bank_title = bankObj["title"]?.stringValue
            bank.bank_icon = bankObj["box_icon"]?.stringValue
            arrayOfBanks.append(bank)
        }
    }
    
}

extension ChooseBankViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfBanks.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibPersonName, for: indexPath) as! PersonAccountViewCell
        
        if indexPath.row == arrayOfBanks.count {
            cell.label_person_contact.isHidden = true
            cell.label_person_name.text = "Other"
            cell.iv_person.image = UIImage(named: "ic_other")
        } else {
            cell.label_person_contact.isHidden = true
            cell.configureBankWithItem(bank: arrayOfBanks[indexPath.row])
        }
        
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accountBalanceVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACCOUNT_BALANCE) as! AccountBalanceViewController
        
        accountBalanceVC.accountType = "Bank"

        
        if indexPath.row == arrayOfBanks.count {
            accountBalanceVC.accountIcon = "ic_other"
            accountBalanceVC.bankName = "Other"
            accountBalanceVC.accountName = "Other Bank"
        } else {
            accountBalanceVC.accountIcon = arrayOfBanks[indexPath.row].bank_icon!
            accountBalanceVC.bankName = arrayOfBanks[indexPath.row].bank_title!
            accountBalanceVC.accountName = arrayOfBanks[indexPath.row].bank_title!
        }
        
        self.navigationController?.pushViewController(accountBalanceVC, animated: true)
    }
    
}
