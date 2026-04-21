

import UIKit
import SwiftyJSON

class AddAccountViewController: BaseViewController {

    @IBOutlet weak var label_other: UILabel!
    @IBOutlet weak var view_bank_width: NSLayoutConstraint!
    @IBOutlet weak var view_bank: CardView!
    @IBOutlet weak var view_banks: UIView!
    @IBOutlet weak var collection_view_banks: UICollectionView!
    @IBOutlet weak var view_person: CardView!
    @IBOutlet weak var view_cash: CardView!
    @IBOutlet weak var collectionBanksHeight: NSLayoutConstraint!
    
    private let nibBankName = "AddBankViewCell"
    private let nibViewMoreName = "CategoryCell"
    private var arrayOfBanks : Array<Bank> = []
 
    
    override func viewDidLoad() {


        initVariables()
        initUI()
        fetchBanksFromJson()
    }
    
    private func initVariables () {
        self.navigationItemColor = .light
        initNibs()
        
        collection_view_banks.delegate = self
        collection_view_banks.dataSource = self
        
        let personTapGest = UITapGestureRecognizer(target: self, action: #selector(onPersonTapped))
        view_person.addGestureRecognizer(personTapGest)
        
        let cashTapGest = UITapGestureRecognizer(target: self, action: #selector(onCashTapped))
        view_cash.addGestureRecognizer(cashTapGest)
        
        let bankTapGest = UITapGestureRecognizer(target: self, action: #selector(onBankTapped))
        view_bank.addGestureRecognizer(bankTapGest)
    }
    
    private func initUI () {
        self.navigationItemColor = .light
        self.navigationItem.title = "Add Account"
        
        let navRightIcon = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onNavRightIconTapped))
        self.navigationItem.rightBarButtonItem = navRightIcon
        
        if LocalPrefs.getCountryName() == "MY" || LocalPrefs.getCountryName() == "MAY" || LocalPrefs.getCountryName() == "MYR" {
            view_banks.isHidden = false
            view_bank.isHidden = true
            view_bank_width.constant = 0
            label_other.isHidden = false
        } else {
            view_banks.isHidden = true
            label_other.isHidden = true
            view_bank.isHidden = false
            view_bank_width.constant = 90
        }
    }
    
    private func initNibs () {
        let nibBank = UINib(nibName: nibBankName, bundle: nil)
        let nibViewMore = UINib(nibName: nibViewMoreName, bundle: nil)
        collection_view_banks.register(nibBank, forCellWithReuseIdentifier: nibBankName)
        collection_view_banks.register(nibViewMore, forCellWithReuseIdentifier: nibViewMoreName)
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

    
    @objc private func onPersonTapped () {
//        let selectPersonVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SELECT_PERSON) as! SelectPersonViewController
//        self.navigationController?.pushViewController(selectPersonVC, animated: true)
        
        let accountBalanceVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACCOUNT_BALANCE) as! AccountBalanceViewController
        
        accountBalanceVC.accountType = "Person"
        self.navigationController?.pushViewController(accountBalanceVC, animated: true)
    }
    
    @objc private func onCashTapped () {
        let accountBalanceVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACCOUNT_BALANCE) as! AccountBalanceViewController
        
        accountBalanceVC.accountType = "Cash"
        self.navigationController?.pushViewController(accountBalanceVC, animated: true)
    }
    
    @objc private func onBankTapped () {
        let accountBalanceVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACCOUNT_BALANCE) as! AccountBalanceViewController
        
        accountBalanceVC.bankName = "Global"
        accountBalanceVC.accountIcon = "ic_other"
        accountBalanceVC.accountType = "Bank"
        self.navigationController?.pushViewController(accountBalanceVC, animated: true)
    }
    
    @objc private func onNavRightIconTapped ()  {
        self.dismiss(animated: true, completion: nil)
    }

}


extension AddAccountViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    override func viewDidLayoutSubviews() {
        super.updateViewConstraints()
        
        self.collectionBanksHeight.constant = 200
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 7:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibViewMoreName, for: indexPath) as! CategoryCell
            
            
            cell.categoryImage.image = UIImage(named: "ic_forward_arrow")
            cell.categoryImage.tintColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR)
            cell.category_title.text = "View All"
            cell.category_title.textColor = UIColor.lightGray
            cell.bg_view.layer.borderColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR).cgColor
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibBankName, for: indexPath) as! AddBankViewCell
            
            cell.bg_view.layer.cornerRadius = 5.0
            cell.bg_view.backgroundColor = .clear
            cell.bg_view.layer.borderWidth = 1.0
            cell.bg_view.layer.borderColor = UIColor.lightGray.cgColor
            
            cell.configureBankWithItem(bank: arrayOfBanks[indexPath.row])
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 7 {
            let selectBankVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_CHOOSE_BANK) as! ChooseBankViewController
            self.navigationController?.pushViewController(selectBankVC, animated: true)
        } else {
            let accountBalanceVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACCOUNT_BALANCE) as! AccountBalanceViewController
            accountBalanceVC.accountName = arrayOfBanks[indexPath.row].bank_title!
            accountBalanceVC.accountType = "Bank"
            accountBalanceVC.accountIcon = arrayOfBanks[indexPath.row].bank_icon!
            accountBalanceVC.bankName = arrayOfBanks[indexPath.row].bank_title!
            self.navigationController?.pushViewController(accountBalanceVC, animated: true)
        }
    }
}
