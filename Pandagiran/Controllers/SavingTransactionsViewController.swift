//
//  SavingTransactionsViewController.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 3/25/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SavingTransactionsViewController: BaseViewController {
    
    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var label_recent_transactions: CustomFontLabel!
    @IBOutlet weak var label_add: UILabel!
    @IBOutlet weak var label_percent_amount: UILabel!
    @IBOutlet weak var label_total_amount: UILabel!
    @IBOutlet weak var label_saved_amount: UILabel!
    @IBOutlet weak var label_saved: UILabel!
    @IBOutlet weak var label_goal_title: UILabel!
    @IBOutlet weak var label_target_date: UILabel!
    @IBOutlet weak var view_add_saving_transaction: CardView!
    @IBOutlet weak var savingTransactionsHeight: NSLayoutConstraint!
    @IBOutlet weak var table_view_saving_transactions: UITableView!
    
    
    private let nibSavingTransactionName = "TransactionViewCell"
    private var arrayOfVouchers : Array<SavingTrx> = []
    
    public var savingGoal : Saving?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        fetchGoalTransactions(goalId: (savingGoal?.goalId)!)
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_saving_transactions.delegate = self
        table_view_saving_transactions.dataSource = self
        
        let addSavingTapGest = UITapGestureRecognizer(target: self, action: #selector(onAddSavingTransactionTapped))
        view_add_saving_transaction.addGestureRecognizer(addSavingTapGest)
    }
    
    private func initUI () {
        if let goal = savingGoal {
            let goalDate = Utils.convertStringToDate(dateString: goal.targetenddate!)
            let decimal = LocalPrefs.getDecimalFormat()
            let currency = LocalPrefs.getUserCurrency()
            let totalAmount = goal.amount!
            let savedAmount = goal.savedAmount!
            var percentAmount: Double = 0
            
            if savedAmount != 0 {
                percentAmount = savedAmount / totalAmount
            }
            
            label_goal_title.text = goal.title!
            label_target_date.text = "Target Date: \(Utils.currentDateUserFormat(date: goalDate))"
            label_total_amount.text = "/ \(currency) \(Utils.formatDecimalNumber(number: totalAmount, decimal: decimal))"
            label_saved_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: savedAmount, decimal: decimal))"
            label_percent_amount.text = "\(round(percentAmount))%"
        }
    }
    
    private func initNibs () {
        let nibSavingTransaction = UINib(nibName: nibSavingTransactionName, bundle: nil)
        table_view_saving_transactions.register(nibSavingTransaction, forCellReuseIdentifier: nibSavingTransactionName)
    }
    
    private func showPlaceholder () {
        if arrayOfVouchers.count == 0 {
            view_placeholder.isHidden = false
        } else {
            view_placeholder.isHidden = true
        }
    }
    
    private func fetchGoalTransactions (goalId : Int64) {
        UIUtils.showLoader(view: self.view)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/pfm/saving/transactions?consumer_id=\(consumerId)&device_type=Ios&saving=\(goalId)"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        let httpMethod = Alamofire.HTTPMethod.get
        
        Alamofire.request(URL, method: httpMethod, parameters: nil, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    UIUtils.dismissLoader(uiView: self.view)
                    let responseObj = JSON(response.result.value!)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    let data = responseObj["data"].dictionaryValue
                    
                    if status == 1 {
                        let goalTrxArray = data["goal_transactions"]?.arrayValue
                        
                        for goalTrxObj in goalTrxArray! {
                            let goalTrx = goalTrxObj.dictionaryValue
                            var voucher = SavingTrx()
                            voucher.amount = goalTrx["amount"]?.doubleValue
                            voucher.accountid = goalTrx["account_id"]?.int64Value
                            voucher.trxdate = goalTrx["trx_date"]?.stringValue
                            voucher.accountTitle = goalTrx["account_title"]?.stringValue
                            self.arrayOfVouchers.append(voucher)
                        }
                    } else {
                        self.showPlaceholder()
                        UIUtils.showSnackbar(message: message)
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.table_view_saving_transactions.reloadData()
                    }
                    
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    @IBAction func onBtnMenuTapped(_ sender: Any) {
    }
    
    
    @objc private func onAddSavingTransactionTapped() {
        let addSavingTransaction = getStoryboard(name: ViewIdentifiers.SB_SAVING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_SAVING_TRANSACTION) as! AddSavingTransactionViewController
        addSavingTransaction.goalId = (savingGoal?.goalId)!
        self.navigationController?.pushViewController(addSavingTransaction, animated: true)
    }
    
    @IBAction func onGoalAcheiveTapped(_ sender: Any) {
        
    }
}

extension SavingTransactionsViewController: UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfVouchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibSavingTransactionName, for: indexPath) as! TransactionViewCell
        
        let goalTitle = savingGoal?.title!
        cell.configureSavingTransactionWithItem(savingTrx: arrayOfVouchers[indexPath.row], goalTitle: goalTitle!)

        savingTransactionsHeight.constant = tableView.contentSize.height
        cell.selectionStyle = .none
        return cell
    }
    
    
}
