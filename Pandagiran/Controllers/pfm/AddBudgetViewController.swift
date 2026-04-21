

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class AddBudgetViewController: BaseViewController {

    @IBOutlet weak var label_set_budget: UILabel!
    @IBOutlet weak var btn_current_month_budget: UIButton!
    @IBOutlet weak var collection_view_categories: UICollectionView!
    @IBOutlet weak var btn_recurring: UIButton!
    @IBOutlet weak var text_field_amount: UITextField!
    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var label_choose_category: UILabel!
    @IBOutlet weak var categoriesCollectionHeight: NSLayoutConstraint!
    
    private let nibCategoryName = "CategoryCell"
    private var isSelected = false
    private var isRecurring = true
    private var arrayOfCategories: Array<Hkb_category> = []
    public var isUpdate = false
    public var categoryId: Int64 = 0
    public var editBudget : Hkb_budget?
    public var budgetMonth = Utils.getCurrentMonth()
    public var budgetYear = Utils.getCurrentYear()
    private var budgetArray : Array<Hkb_budget> = []
    private var endMonth = 12
   
    
    
    
    override func viewDidLoad() {

        initVariables()
        fetchCategories()
        initUI ()
        budgetEdit()
        
        
        
    }
    
    private func initVariables () {
        initNibs()
        
        collection_view_categories.delegate = self
        collection_view_categories.dataSource = self
    }
    
    private func initUI () {
        
        label_currency.text = LocalPrefs.getUserCurrency()
        self.navigationItemColor = .light
        self.navigationItem.title = "Add budget"
        categoriesCollectionHeight.constant = 170
        
        let navRightIcon = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onNavRightIconTapped))
        self.navigationItem.rightBarButtonItem = navRightIcon
        
        let btnRecurrigImage = UIImage(named: "ic_cb_unchecked")?.withRenderingMode(.alwaysTemplate)
        btn_current_month_budget.setImage(btnRecurrigImage, for: .normal)
        btn_current_month_budget.tintColor = UIColor.lightGray
        

        
        if categoryId != 0 {
            let category = QueryUtils.fetchSingleCategory(categoryId: Int64(categoryId))!
            if let index = arrayOfCategories.firstIndex(of: category) {
                DispatchQueue.main.async {
                    self.collection_view_categories.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [.centeredHorizontally])
                }
            }
        }
    }
    
    private func initNibs () {
        let nibCategory = UINib(nibName: nibCategoryName, bundle: nil)
        collection_view_categories.register(nibCategory, forCellWithReuseIdentifier: nibCategoryName)
    }
    
    private func budgetEdit () {
        if let budget = BudgetDbUtils.fetchSingleBudget(categoryId: categoryId, month: budgetMonth, year: budgetYear) {
            isRecurring = false
            budgetMonth = Int(budget.budgetmonth)
            endMonth = budgetMonth
            let btnRecurrigImage = UIImage(named: "ic_cb_checked")?.withRenderingMode(.alwaysTemplate)
            btn_current_month_budget.setImage(btnRecurrigImage, for: .normal)
            btn_current_month_budget.isUserInteractionEnabled = false
            isUpdate = true
            categoryId = budget.categoryid
//            budget.active = 1
            let category = QueryUtils.fetchSingleCategory(categoryId: Int64(budget.categoryid))!
            let index = arrayOfCategories.firstIndex(of: category)
            text_field_amount.text = Utils.formatDecimalNumber(number: budget.budgetvalue, decimal: LocalPrefs.getDecimalFormat())
            
            DispatchQueue.main.async {
                self.collection_view_categories.selectItem(at: IndexPath(item: index!, section: 0), animated: true, scrollPosition: [.centeredHorizontally])
            }
        }
    }
    
    private func fetchCategories () {
        arrayOfCategories = QueryUtils.fetchCategories(type: Constants.EXPENSE)
    }
    
    private func saveBudget () {
        var budgetDict : Array<[String:Any]> = []
        
        for i in budgetMonth ... endMonth {
            if let budget = BudgetDbUtils.fetchSingleBudget(categoryId: categoryId, month: i, year: budgetYear) {
                isUpdate = true
                budgetDetails(budget: budget, month: i, year: budgetYear)
                budgetArray.append(budget)
                let dictObj = Utils.convertVchIntoDict(object: budget)
                budgetDict.append(dictObj)
            }
            else
            {
                let budget : Hkb_budget = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_BUDGET, into: DbController.getContext()) as! Hkb_budget
                isUpdate = false
                budgetDetails(budget: budget, month: i, year: budgetYear)
                budgetArray.append(budget)
                let dictObj = Utils.convertVchIntoDict(object: budget)
                budgetDict.append(dictObj)
            }
        }
        
        if editBudget == nil {
            if QueryUtils.getCategorySync(categoryId: categoryId) == 1{
                DbController.saveContext()
                let budgetJson = Utils.convertDictIntoJson(object: budgetDict)
                postBudgetToServer(budgetJson: budgetJson, isUpdate: isUpdate)
            } else {

                for budget in budgetArray{
                    budget.is_synced = 0
                }
                DbController.saveContext()
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            }
        } else {
            
            if QueryUtils.getCategorySync(categoryId: categoryId) == 1{
                DbController.saveContext()
                let budgetJson = Utils.convertDictIntoJson(object: budgetDict)
                postBudgetToServer(budgetJson: budgetJson, isUpdate: isUpdate)
            } else {

                for budget in budgetArray{
                    budget.is_synced = 0
                }
                DbController.saveContext()
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            }
            
        }
//        if QueryUtils.getCategorySync(categoryId: categoryId) == 1{
//
//            let budgetJson = Utils.convertDictIntoJson(object: budgetDict)
//            postBudgetToServer(budgetJson: budgetJson, isUpdate: isUpdate)
//        } else {
//
//            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
//        }
        

        self.dismiss(animated: true, completion: nil)
    }
    
    private func budgetDetails (budget : Hkb_budget , month : Int , year : Int) {
        budget.budgetmonth = Int16(month)
        budget.budgetyear = Int16(year)
        budget.budgetvalue = Utils.removeComma(numberString: text_field_amount.text!)
        budget.is_synced = 0
        budget.categoryid = Int64(categoryId)
        
        if isUpdate == true{
            budget.active = 1
        }
        
        if editBudget == nil && isUpdate == false {
//            budget.budget_id = Int64(QueryUtils.getMaxBudgetId() + 1)
            budget.budget_id = Utils.getUniqueId()
            budget.active = 1
            
        }
    }
    
    private func postBudgetToServer (budgetJson: String, isUpdate : Bool) {
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        var URL = "\(Constants.BASE_URL)/budget/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        var httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt : [String:Any] =  ["budgets" : budgetJson,
                                             "device_type" : "Ios",
                                             "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        if isUpdate {
            URL = "\(Constants.BASE_URL)/budget/update"
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
                    let message = responseObj["message"].stringValue
                    print("ResponseStatus : " , status,  message)
                    if status == 1 {
                        for budget in self.budgetArray {
                           
                                budget.is_synced = 1

                        }
                        
                        DbController.saveContext()
                    } else {
                        for budget in self.budgetArray {
                            budget.is_synced = 0
                        }
                        DbController.saveContext()
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                    
                    
                case .failure(let error):
                    for budget in self.budgetArray {
                        budget.is_synced = 0
                    }
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    DbController.saveContext()
//                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    @objc private func onNavRightIconTapped () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCurrentMonthBudgetTapped(_ sender: Any) {
        if isRecurring {
            isRecurring = false
            endMonth = Utils.getCurrentMonth()
            let btnRecurrigImage = UIImage(named: "ic_cb_checked")?.withRenderingMode(.alwaysTemplate)
            btn_current_month_budget.setImage(btnRecurrigImage, for: .normal)
            btn_current_month_budget.tintColor = UIColor().hexCode(hex: Style.color.PRIMARY_COLOR)
        } else {
            isRecurring = true
            endMonth = 12
            let btnRecurrigImage = UIImage(named: "ic_cb_unchecked")?.withRenderingMode(.alwaysTemplate)
            btn_current_month_budget.setImage(btnRecurrigImage, for: .normal)
            btn_current_month_budget.tintColor = UIColor.lightGray
        }
    }
    
    @IBAction func onSaveTapped(_ sender: Any) {
        if Utils.validateInt(vc: self, intValue: categoryId, errorMsg: "Please select category") && Utils.validateAmount(vc: self, amount: Utils.removeComma(numberString: text_field_amount.text!), errorMsg: "Please enter the budget amount") {
            
            saveBudget()
        }
    }
}

extension AddBudgetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
//    override func viewWillLayoutSubviews() {
//        super.updateViewConstraints()
//        self.categoriesCollectionHeight.constant = self.collection_view_categories.contentSize.height
//    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibCategoryName, for: indexPath) as! CategoryCell
        
        
        cell.cellType = "Category"
        cell.configureCategoryWithItemCells(category: arrayOfCategories[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        
        cell.cellType = "Category"
        self.categoryId = arrayOfCategories[indexPath.row].categoryId ?? 0
        cell.isSelected = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        
       cell.isSelected = false
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collection_view_categories.frame.size.width / 4
        let height: CGFloat = 80
        return CGSize(width: width, height: height)
    }
    
}
