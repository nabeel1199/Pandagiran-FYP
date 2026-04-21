//
//  SavingViewController.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 3/22/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SavingViewController: BaseViewController, SegmentButtonTappedListener {

    

    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var label_left_amount: UILabel!
    @IBOutlet weak var label_saved_amount: UILabel!
    @IBOutlet weak var label_total_amount: UILabel!
    @IBOutlet weak var label_total_savings: CustomFontLabel!
    @IBOutlet weak var view_running: UIView!
    @IBOutlet weak var viewRunningHeight: NSLayoutConstraint!
    @IBOutlet weak var view_segments: SignatureSegmentedControl!
    @IBOutlet weak var progress_view: UIProgressView!
    @IBOutlet weak var savingsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var view_create_saving: CardView!
    @IBOutlet weak var table_view_savings: SelfSizedTableView!
    @IBOutlet weak var collection_view_saving_deals: UICollectionView!
    @IBOutlet weak var savingDealsCollectionHeight: NSLayoutConstraint!
    
    private let nibSavingName = "SavingViewCell"
    private let nibSavingDealName = "SavingDealViewCell"
    private let placeholder = PlaceholderView()
    
    private var savingsArray : Array<Saving> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        fetchSavingGoals(active: "active")

        
    }
    
    private func initVariables () {
        view_segments.delegate = self
        initNibs()
        
        table_view_savings.delegate = self
        table_view_savings.dataSource = self
        
        collection_view_saving_deals.delegate = self
        collection_view_saving_deals.dataSource = self
        
        let createSavingGest = UITapGestureRecognizer(target: self, action: #selector(onCreateSavingTapped))
        view_create_saving.addGestureRecognizer(createSavingGest)
    }
    
    private func initUI () {
        self.navigationItem.title = "Saving Goals"
        
        let searchIcon = UIBarButtonItem(image: UIImage(named: "ic_search"), style: .plain, target: self, action: #selector(onSearchTapped))
        self.navigationItem.rightBarButtonItem = searchIcon
        
        progress_view.layer.cornerRadius = 3
        progress_view.layer.masksToBounds = true
        
        table_view_savings.rowHeight = UITableViewAutomaticDimension
        table_view_savings.estimatedRowHeight = 130
        
        label_total_savings.regularFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_total_amount.regularFont(fontStyle: .bold, size: Style.dimen.LARGE_TEXT)
        label_saved_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_left_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
    }
    
    private func initNibs () {
        let nibSaving = UINib(nibName: nibSavingName, bundle: nil)
        let nibSavingDeal = UINib(nibName: nibSavingDealName, bundle: nil)
        table_view_savings.register(nibSaving, forCellReuseIdentifier: nibSavingName)
        collection_view_saving_deals.register(nibSavingDeal, forCellWithReuseIdentifier: nibSavingDealName)
    }
    
    private func showPlaceholder () {
        if savingsArray.count == 0 {
            savingsTableHeight.constant = 200
            view_placeholder.isHidden = false
        } else {
            view_placeholder.isHidden = true
        }
    }
    
    private func fetchSavingGoals (active: String) {
        UIUtils.showLoader(view: self.view)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/pfm/savings/\(active)?consumer_id=\(consumerId)&device_type=Ios"
        
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
                    
                    if status == 1 {
                        let data = responseObj["data"].dictionaryValue
                        let totalDetails = data["total"]?.dictionaryValue
                        let savingJsonArray = data["savings"]?.arrayValue
                        
                        let decimal = LocalPrefs.getDecimalFormat()
                        let currency = LocalPrefs.getUserCurrency()
                        let totalAmount = totalDetails!["total_goal_amount"]?.doubleValue
                        let savedAmount = totalDetails!["total_saved_amount"]?.doubleValue
                        let leftAmount = totalAmount! - savedAmount!
                        
                        self.label_total_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: totalAmount!, decimal: decimal))"
                        self.label_saved_amount.text = "/\(currency) \(Utils.formatDecimalNumber(number: savedAmount!, decimal: decimal))"
                        self.label_left_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: leftAmount, decimal: decimal))"
                        
                        for savingObj in savingJsonArray! {
                            let saving = Saving ()
                            let goalObj = savingObj.dictionaryValue
                            let goalItem = goalObj["goal"]?.dictionaryValue
                            let goalTrackingItem = goalObj["goal_tracking_detail"]?.dictionaryValue
                            saving.title = goalItem!["title"]?.stringValue
                            saving.amount = goalItem!["amount"]?.doubleValue
                            saving.createdon = goalItem!["createdon"]?.stringValue
                            saving.currency = goalItem!["currency"]?.stringValue
                            saving.icon = goalItem!["icon"]?.stringValue
                            saving.tags = goalItem!["tags"]?.stringValue
                            saving.targetenddate = goalItem!["targetenddate"]?.stringValue
                            saving.goalId = goalItem!["goalId"]?.int64Value
                            saving.savedAmount = goalTrackingItem!["total_saved_amount"]?.doubleValue
                            self.savingsArray.append(saving)
                        }
                    } else {
                        UIUtils.showSnackbar(message: message)
                    }
                    
                    DispatchQueue.main.async {
                        self.table_view_savings.reloadData()
                        self.showPlaceholder()
                    }
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    self.showPlaceholder()
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    @IBAction func onLearnMoreTapped(_ sender: Any) {
        let learnMoreVC = getStoryboard(name: ViewIdentifiers.SB_SAVING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SAVINGS_LEARN_MORE) as! SavingsLearnMoreViewController
        self.navigationController?.pushViewController(learnMoreVC, animated: true)
    }
    
    
    @objc private func onSearchTapped () {
        
    }
    
    @objc private func onCreateSavingTapped () {
        let addSavingVC = getStoryboard(name: ViewIdentifiers.SB_SAVING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_SAVING) as! AddSavingViewController
        let navController = UINavigationController()
        navController.viewControllers = [addSavingVC]
        self.present(navController, animated: true, completion: nil)
    }
    
    
    func onSegmentTapped(btnTitle: String) {
        self.savingsArray.removeAll()
        self.table_view_savings.reloadData()
        if btnTitle == "Acheived" {
            view_running.isHidden = true
            viewRunningHeight.constant = 0
            fetchSavingGoals(active: "inactive")
        } else {
            view_running.isHidden = false
            viewRunningHeight.constant = 200
            fetchSavingGoals(active: "active")
        }
    }

}

extension SavingViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view_savings.dequeueReusableCell(withIdentifier: nibSavingName, for: indexPath) as! SavingViewCell
        
        cell.configureSavingWithItem(saving: savingsArray[indexPath.row])
        
        savingsTableHeight.constant = tableView.contentSize.height
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let savingTransactions = getStoryboard(name: ViewIdentifiers.SB_SAVING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SAVING_TRANSACTIONS) as! SavingTransactionsViewController
        savingTransactions.savingGoal = savingsArray[indexPath.row]
        self.navigationController?.pushViewController(savingTransactions, animated: true)
    }
    
}

extension SavingViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibSavingDealName, for: indexPath) as! SavingDealViewCell
        
        
        
        return cell
    }
    
    
}

