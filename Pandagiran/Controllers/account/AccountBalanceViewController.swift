//
//  AccountBalanceViewController.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 3/21/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AccountBalanceViewController: BaseViewController {

    @IBOutlet weak var label_account_name: CustomFontLabel!
    @IBOutlet weak var label_set_balance: UILabel!
    @IBOutlet weak var view_receivable_payable: UIView!
    @IBOutlet weak var text_field_amount: AmountEnterTextField!
    @IBOutlet weak var text_field_account_name: AmountEnterTextField!
    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var btn_positive_balance: UIButton!
    @IBOutlet weak var btn_negative_balance: UIButton!
    @IBOutlet weak var btn_add_account: GradientButton!
  
    
    public var accountType: String = ""
    public var accountName: String = ""
    public var editAccount: Account?
    public var accountIcon: String = ""
    private var isPositiveBalance = true
    
    override func viewDidLoad() {

        initVariables()
        populateEditAccount()
        initUI()
    }
    
    private func initVariables () {
        text_field_amount.delegate = self
        text_field_account_name.delegate = self
    }
    
    private func initUI () {
        self.navigationItem.title = "Add \(accountType) Account"
        label_account_name.text = "Your Account Name"
        btn_positive_balance.tintColor = UIColor().hexCode(hex: Style.color.PRIMARY_COLOR)
        btn_negative_balance.tintColor = UIColor().hexCode(hex: Style.color.PRIMARY_COLOR)
        label_currency.text = LocalPrefs.getUserCurrency()
        
        if accountType == "Person" {
                label_account_name.text = "Person Name"
            btn_positive_balance.setTitle("Recievable", for: .normal)
            btn_negative_balance.setTitle("Payable", for: .normal)
        } else {
            btn_positive_balance.setTitle("Positive", for: .normal)
            btn_negative_balance.setTitle("Negative", for: .normal)
        }
        
        text_field_account_name.text = accountName
        
    }
    
    private func populateEditAccount () {
        if let account = editAccount {
            self.accountName = account.title!
            self.accountType = account.acctype!
            
            
            btn_add_account.setTitle("UPDATE", for: .normal)
            label_set_balance.text = Utils.formatDecimalNumber(number: account.openingbalance!, decimal: LocalPrefs.getDecimalFormat())
            
            if account.openingbalance! > 0 {
                label_currency.text = "Rs"
                isPositiveBalance = true
                btn_positive_balance.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
                btn_negative_balance.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
            } else {
                label_currency.text = "Rs -"
                isPositiveBalance = false
                btn_positive_balance.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
                btn_negative_balance.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
            }
        }
    }
    
    private func fetchAccountDetails () -> String {
        let jsonEncoder = JSONEncoder()
        var accountJson = ""
        var account = Account()
        account.title = text_field_account_name.text!
        account.acctype = accountType
        account.active = 1
        account.openingbalance = Utils.removeComma(numberString: text_field_amount.text!)
        
        if accountType == "Bank" {
            account.bank_name = text_field_account_name.text!
            account.boxicon = accountIcon
        } else if accountType == "Cash" {
            account.boxicon = "ic_cash_account"
        } else {
            account.boxicon = "personal_inactive"
        }
        
        if let pfmAccount = editAccount {
            account.account_id = pfmAccount.account_id!
        }
        
    
        do {
            let jsonData = try jsonEncoder.encode(account)
            accountJson = String(data: jsonData, encoding: .utf8)!
            
        } catch {
            print("ERROR : " , error)
        }
        
        return accountJson
    }
    
    private func postAccountToServer () {
        UIUtils.showLoader(view: self.view)
        let accountJson = fetchAccountDetails()
       
        print("Account Json : " , accountJson)
        
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/account/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        let httpMethod = Alamofire.HTTPMethod.post
        let params = ["accounts" : accountJson,
                      "device_type" : "Ios",
                      "consumer_id" : consumerId]
        
        Alamofire.request(URL, method: httpMethod, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    UIUtils.dismissLoader(uiView: self.view)
                    let responseObj = JSON(response.result.value!)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    if status == 1 {
                        UIUtils.showSnackbar(message: "Account added successfully")
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    @IBAction func onPositiveBalanceTapped(_ sender: Any) {
        label_currency.text = "Rs"
        isPositiveBalance = true
        btn_positive_balance.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
        btn_negative_balance.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
    }
    
    @IBAction func onNegativeBalanceTapped(_ sender: Any) {
        label_currency.text = "Rs -"
        isPositiveBalance = false
        btn_positive_balance.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
        btn_negative_balance.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
    }

    
    @IBAction func onChangeCurrencyTapped(_ sender: Any) {
        let changeCurrencyVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SELECT_CURRENCY) as! AccountCurrencyViewController
        self.navigationController?.pushViewController(changeCurrencyVC, animated: true)
    }
    
    @IBAction func onAddAccountTapped(_ sender: Any) {
        postAccountToServer()
    }
    
    
}

extension AccountBalanceViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case text_field_account_name:
            text_field_amount.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
}
