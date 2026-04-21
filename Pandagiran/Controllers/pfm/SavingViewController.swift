

import UIKit
import Alamofire
import SwiftyJSON

class SavingViewController: BaseViewController, SegmentButtonTappedListener {
    
    @IBOutlet weak var scrollingView: UIView!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    @IBOutlet weak var view_extended: GradientView!
    @IBOutlet weak var extendedViewHeight: NSLayoutConstraint!
    @IBOutlet weak var totalSavingHeight: NSLayoutConstraint!
    @IBOutlet weak var view_total_savings: CardView!
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
    @IBOutlet weak var table_view_savings: UITableView!
    @IBOutlet weak var collection_view_saving_deals: UICollectionView!
    @IBOutlet weak var savingDealsCollectionHeight: NSLayoutConstraint!
    
    private let nibSavingName = "SavingViewCell"
    private let nibSavingDealName = "SavingDealViewCell"
    private var savingsArray : Array<Hkb_goal> = []
    
    public var shouldPush = false
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if view_segments.selectedSegmentIndex == 0 {
            fetchSavingGoals(type: "Running")
        } else {
            fetchSavingGoals(type: "Acheived")
        }
        
        populateTotalSavingsCard()
        (self.tabBarController as? TabBarViewController)?.popupAppear()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        (self.tabBarController as? TabBarViewController)?.popupDisappear()
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
        
        
        if !shouldPush {
            self.addSideMenu()
        }
        
        self.navigationItem.title = "Savings"
        
        let searchIcon = UIBarButtonItem(image: UIImage(named: "ic_search"), style: .plain, target: self, action: #selector(onSearchTapped))
//        self.navigationItem.rightBarButtonItem = searchIcon
        
        progress_view.layer.cornerRadius = 3
        progress_view.layer.masksToBounds = true
        
        table_view_savings.rowHeight = UITableView.automaticDimension
        table_view_savings.estimatedRowHeight = 130
        
        label_total_savings.regularFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_total_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_saved_amount.regularFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_left_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
    }
    
    private func initNibs () {
        let nibSaving = UINib(nibName: nibSavingName, bundle: nil)
        let nibSavingDeal = UINib(nibName: nibSavingDealName, bundle: nil)
        table_view_savings.register(nibSaving, forCellReuseIdentifier: nibSavingName)
        collection_view_saving_deals.register(nibSavingDeal, forCellWithReuseIdentifier: nibSavingDealName)
    }
    
    private func populateTotalSavingsCard () {
        var progressValue: Double = 0
        let currency = LocalPrefs.getUserCurrency()
        let totalSavingAmount = SavingDbUtils.fetchTotalSavingsAmount()
        let totalSavedAmount = SavingDbUtils.fetchSavedAmount(goalId: 0)
        let totalLeftAmount = totalSavingAmount - totalSavedAmount
        
        if totalSavingAmount != 0 {
            progressValue = totalSavedAmount / totalSavingAmount
        }
        
        label_saved_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: totalSavedAmount, decimal: LocalPrefs.getDecimalFormat()))"
        label_total_amount.text = "/\(Utils.formatDecimalNumber(number: totalSavingAmount, decimal: LocalPrefs.getDecimalFormat()))"
        label_left_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: totalLeftAmount, decimal: LocalPrefs.getDecimalFormat()))"
        DispatchQueue.main.async {
            self.progress_view.setProgress(Float(progressValue), animated: true)
        }
        
    
    }
    
    private func showPlaceholder () {
        if savingsArray.count == 0 {
            totalSavingHeight.constant = 0
            extendedViewHeight.constant = 0
            view_extended.isHidden = true
            view_total_savings.isHidden = true
            savingsTableHeight.constant = 200
            viewRunningHeight.constant = 80
            view_placeholder.isHidden = false
        } else {
            view_extended.isHidden = false
            view_total_savings.isHidden = false
            totalSavingHeight.constant = 128
            extendedViewHeight.constant = 60
            viewRunningHeight.constant = 200
            view_placeholder.isHidden = true
        }
    }
    
    private func fetchSavingGoals (type: String) {
        savingsArray.removeAll()
        savingsArray = SavingDbUtils.fetchRunningSavings(type: type)
        self.table_view_savings.reloadData()
        showPlaceholder()
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
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    
    func onSegmentTapped(btnTitle: String) {
        self.savingsArray.removeAll()
        self.table_view_savings.reloadData()
        if btnTitle == "Acheived" {
            view_running.isHidden = true
            viewRunningHeight.constant = 0
            fetchSavingGoals(type: "Acheived")
//            table_view_savings.translatesAutoresizingMaskIntoConstraints = false
//            self.table_view_savings.topAnchor.constraint(equalTo: self.scrollingView.topAnchor, constant: 0).isActive = true

        } else {
            view_running.isHidden = false
            viewRunningHeight.constant = 200
            fetchSavingGoals(type: "Running")
//            table_view_savings.translatesAutoresizingMaskIntoConstraints = false
//            self.table_view_savings.topAnchor.constraint(equalTo: self.view_running.bottomAnchor, constant: 16).isActive = true
//            viewWillLayoutSubviews()
        }
    }

}

extension SavingViewController: UITableViewDelegate, UITableViewDataSource, GenericPopupSelection {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view_savings.dequeueReusableCell(withIdentifier: nibSavingName, for: indexPath) as! SavingViewCell
        
        cell.configureSavingWithItem(saving: savingsArray[indexPath.row])
        cell.btn_menu.tag = indexPath.row
        cell.btn_menu.addTarget(self, action: #selector(onSavingMenuTapped), for: .touchUpInside)

        savingsTableHeight.constant = tableView.contentSize.height
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let savingTransactions = getStoryboard(name: ViewIdentifiers.SB_SAVING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SAVING_TRANSACTIONS) as! SavingTransactionsViewController
        savingTransactions.savingGoal = savingsArray[indexPath.row]
        self.navigationController?.pushViewController(savingTransactions, animated: true)
    }
    
    @objc private func onSavingMenuTapped (sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: {action in
            let goal = self.savingsArray[sender.tag]
            let addSavingVC = self.getStoryboard(name: ViewIdentifiers.SB_SAVING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_SAVING) as! AddSavingViewController
            addSavingVC.editGoal = goal
            let navController = UINavigationController()
            navController.viewControllers = [addSavingVC]
            navController.modalPresentationStyle = .currentContext
            self.present(navController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: {action in
            let genericPopup = GenericPopup()
            genericPopup.delegate = self
            genericPopup.popupTitle = "Delete Goal"
            genericPopup.message = "Are you sure you want to delete this goal?"
            genericPopup.btnText = "DELETE GOAL"
            genericPopup.objectIndex = sender.tag
            self.presentPopupView(popupView: genericPopup)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onButtonTapped(index: Int, objectIndex: Int) {
        let goalToDelete = savingsArray[objectIndex]
        let goalTrxArray = SavingDbUtils.fetchSavingTransactions(goalId: Int64(goalToDelete.goalId))
        goalToDelete.active = 0
        DbController.saveContext()
        if QueryUtils.getGoalSync(goalId: goalToDelete.goalId) == 1{
            self.postGoalToServer(goal: goalToDelete, isUpdate: true)
        } else {
            goalToDelete.is_synced = 0
            DbController.saveContext()
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
        }
        
        
        // Delete goal transactions and vouchers associated with it
//        for goalTrx in goalTrxArray {
////            let goalVoucher = QueryUtils.fetchSingleVoucher(voucherId: Int(goalTrx.hkbvchid))!
//            guard let goalVoucher = QueryUtils.fetchSingleVoucher(voucherId: Int(goalTrx.voucherId)) else {
//                return
//            }
//            
//            if goalVoucher.ref_no != nil && goalVoucher.ref_no != "" {
//                if let goalVoucher2 = QueryUtils.fetchSingleVoucher(voucherId: Int(goalVoucher.ref_no!)!) {
//                    goalVoucher2.active = 0
//                }
//            }
//            
//            goalVoucher.active = 0
//            goalTrx.active = 0
//            
//        }
        
        
        savingsArray.remove(at: objectIndex)
        table_view_savings.reloadData()
        showPlaceholder()
        UIUtils.showSnackbar(message: "Goal deleted successfully")
    }
    
    private func postGoalToServer (goal : Hkb_goal, isUpdate : Bool) {
        let goalDetails = Utils.convertVchIntoDict(object: goal)
        let goalsJson = Utils.convertDictIntoJson(object: goalDetails)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        var URL = "\(Constants.BASE_URL)/saving/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        var httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["savings" : goalsJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        if isUpdate {
            URL = "\(Constants.BASE_URL)/saving/update"
            httpMethod = Alamofire.HTTPMethod.post
        }
        
        Alamofire.request(URL, method: httpMethod, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue

                    if status == 1 {
                        
                            goal.is_synced = 1
                        
                    } else {
                        goal.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                    
                    DbController.saveContext()
                    
                case .failure(let error):
                    goal.is_synced = 0
                    DbController.saveContext()
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
//                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
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

