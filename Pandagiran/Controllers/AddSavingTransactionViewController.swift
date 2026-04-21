//
//  AddSavingTransactionViewController.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 3/25/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddSavingTransactionViewController: BaseViewController {

    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var text_field_amount: UITextField!
    @IBOutlet weak var collection_view_accounts: UICollectionView!
    
    private let nibAccountName = "CategoryCell"
    private var arrayOfAccounts : Array<Account> = []
    
    public var accountId: Int64 = 0
    public var goalId: Int64 = 0
    
    
    override func viewDidLoad() {
        
        initVariables()
        initUI()
        fetchAccounts(accountType: "ALL")
    }
    
    private func initVariables () {
        
        initNibs()
        
        collection_view_accounts.delegate = self
        collection_view_accounts.dataSource = self
    }
    
    private func initUI () {
        label_currency.text = LocalPrefs.getUserCurrency()
        self.navigationItemColor = .light
    }
    
    private func initNibs () {
        let nibAccount = UINib(nibName: nibAccountName, bundle: nil)
        collection_view_accounts.register(nibAccount, forCellWithReuseIdentifier: nibAccountName)
    }
    
    private func fetchAccounts (accountType: String) {
        UIUtils.showLoader(view: self.view)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/pfm/dashboard/accounts?consumer_id=\(consumerId)&device_type=Ios&use_case=&account_type=\(accountType)"
        
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        Alamofire.request(URL, method: .get, parameters: nil, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    UIUtils.dismissLoader(uiView: self.view)
                    let responseObj = JSON(response.result.value!)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    if status == 1 {
                        let data = responseObj["data"].dictionaryValue
                        let accountsJsonArray = data["accounts"]?.arrayValue
                        
                        for accountJson in accountsJsonArray! {
                            var account = Account()
                            account.title = accountJson["account_name"].stringValue
                            account.account_id = accountJson["account_id"].int64Value
                            account.openingbalance = accountJson["closing_balance"].doubleValue
                            account.boxicon = accountJson["account_icon"].stringValue
                            self.arrayOfAccounts.append(account)
                        }
                    } else {
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    DispatchQueue.main.async {
                        self.collection_view_accounts.reloadData()
                    }
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    private func fetchSavingTrxDetails () -> String {
        let jsonEncoder = JSONEncoder()
        let currentDate = Date()
        let dateString = Utils.currentDateDbFormat(date: currentDate)
        var savingTrxJson = ""
        
        var savingTrx = SavingTrx()
        savingTrx.active = 1
        savingTrx.accountid = self.accountId
        savingTrx.goalid = self.goalId
        savingTrx.amount = Utils.removeComma(numberString: text_field_amount.text!)
        savingTrx.trxdate = dateString
        savingTrx.trxday = String(Utils.getDayMonthAndYear(givenDate: dateString, dayMonthOrYear: "day"))
        savingTrx.trxmonth = String(Utils.getDayMonthAndYear(givenDate: dateString, dayMonthOrYear: "month"))
        savingTrx.trxyear = String(Utils.getDayMonthAndYear(givenDate: dateString, dayMonthOrYear: "year"))
        
        
        do {
            let jsonData = try jsonEncoder.encode(savingTrx)
            savingTrxJson = String(data: jsonData, encoding: .utf8)!
            
        } catch {
            print("ERROR : " , error)
        }
        
        return savingTrxJson
    }
    
    private func postSavingTrxToServer () {
        UIUtils.showLoader(view: self.view)
        let savingTrx = fetchSavingTrxDetails()
        
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/goal/trx/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        let httpMethod = Alamofire.HTTPMethod.post
        let params = ["saving_trxs" : savingTrx,
                      "device_type" : "Ios",
                      "consumer_id" : consumerId]
        
        print("VCH JSON ", savingTrx)
        
        
        Alamofire.request(URL, method: httpMethod, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    UIUtils.dismissLoader(uiView: self.view)
                    let responseObj = JSON(response.result.value!)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    if status == 1 {
                        UIUtils.showSnackbar(message: "Saving Transaction added successfully")
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
    
    @IBAction func onAddSavingTransactionTapped(_ sender: Any) {
        if Utils.validateString(vc: self, string: text_field_amount.text!, errorMsg: "Please enter the amount") && self.accountId != 0  {
            
            postSavingTrxToServer()
            
        } else {
            UIUtils.showAlert(vc: self, message: "Please select the account")
        }
    }
    

}

extension AddSavingTransactionViewController: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfAccounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibAccountName, for: indexPath) as! CategoryCell
        
        cell.configureAccountsWithItemCells(account: arrayOfAccounts[indexPath.row])
        cell.categoryImage.tintColor = UIColor.lightGray
        cell.bg_view.backgroundColor = UIColor.clear
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.cornerRadius = 5.0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        self.accountId = arrayOfAccounts[indexPath.row].account_id!
        let cell = collection_view_accounts.cellForItem(at: indexPath) as! CategoryCell
        cell.contentView.layer.borderColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR).cgColor
        cell.contentView.layer.borderWidth = 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = collection_view_accounts.cellForItem(at: indexPath) as! CategoryCell
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.borderWidth = 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collection_view_accounts.frame.size.width / 3.5
        let height: CGFloat = 85
        return CGSize(width: width, height: height)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationItemColor = .dark
    }
}
