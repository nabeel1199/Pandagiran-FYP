

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class AddSavingViewController: BaseViewController {
    
    @IBOutlet weak var btn_create_goal: UIButton!
    @IBOutlet weak var view_tags: CardView!
    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var text_field_saving_title: UITextField!
    @IBOutlet weak var text_field_amount: UITextField!
    @IBOutlet weak var collection_view_icons: UICollectionView!
    @IBOutlet weak var text_field_tags: UITextField!
    @IBOutlet weak var btn_target_date: UIButton!
    @IBOutlet weak var view_target_date: CardView!
    @IBOutlet weak var iconsCollectionHeight: NSLayoutConstraint!
    
    
    public var editGoal: Hkb_goal?
    public var savingTitle = ""
    public var savingIcon = ""
    public var savingAmount: Double = 0
    
    private let nibIconName = "CategoryCell"
    private var arrayOfCategories : Array<Category> = []
    private var iconsArray = ["bt_1" , "bt_2" , "bt_3" , "bt_4" , "bt_5" , "bt_6"]
    private var targetDate = ""
    private var tags = ""
    private let categoryJson = "[{\"category_id\": 700,\"title\": \"Personal\",\"box_icon\": \"personal_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 701,\"title\": \"House\",\"box_icon\": \"home_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 702,\"title\": \"Vehicle\",\"box_icon\": \"vehicle_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 703,\"title\": \"Education\",\"box_icon\": \"education_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 704,\"title\": \"Holiday Trip\",\"box_icon\": \"travel_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 705,\"title\": \"Wedding\",\"box_icon\": \"wedding_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 706,\"title\": \"Family\",\"box_icon\": \"family_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 707,\"title\": \"Electronics\",\"box_icon\": \"electronics_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 708,\"title\": \"Emergency\",\"box_icon\": \"emergency_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 709,\"title\": \"Hajj/Umrah\",\"box_icon\": \"hajj_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 710,\"title\": \"Business\",\"box_icon\": \"profit_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 711,\"title\": \"Gifts\",\"box_icon\": \"gifts_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 712,\"title\": \"Shopping\",\"box_icon\": \"shopping_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 713,\"title\": \"Picnic/Party\",\"box_icon\": \"party_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 714,\"title\": \"Home Appliances\",\"box_icon\": \"appliances_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 715,\"title\": \"Other\",\"box_icon\": \"other_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"}\n" +
        "] "
    
    
    
    override func viewDidLoad() {
        
        initVariables()
        fetchCategoriesFromJson()
        goalEdit()
        initUI()
        
        
    }
    
    private func initVariables () {
        initNibs()
        
        collection_view_icons.delegate = self
        collection_view_icons.dataSource = self
        
        text_field_saving_title.delegate = self
        text_field_amount.delegate = self
        text_field_tags.delegate = self
    }
    
    private func initUI () {
        self.navigationItemColor = .light
        
        let navRightIcon = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onNavRightIconTapped))
        self.navigationItem.rightBarButtonItem = navRightIcon
        
        label_currency.text = LocalPrefs.getUserCurrency()
        text_field_saving_title.text = savingTitle
        
        if savingAmount != 0 {
            text_field_amount.text =  Utils.formatDecimalNumber(number: savingAmount, decimal: LocalPrefs.getDecimalFormat())
        }
        
        let tagsTapGest = UITapGestureRecognizer(target: self, action: #selector(onTagsTapped))
        view_tags.addGestureRecognizer(tagsTapGest)
    }
    
    private func initNibs () {
        let nibIcon = UINib(nibName: nibIconName, bundle: nil)
        collection_view_icons.register(nibIcon, forCellWithReuseIdentifier: nibIconName)
    }
    
    private func goalEdit () {
        if let goal = editGoal {
            self.navigationItem.title = "Edit Goal"
            let goalEndDate = Utils.convertStringToDate(dateString: goal.targetenddate!)
            let goalAmount = goal.amount
            targetDate = goal.targetenddate!
            
            if let goalTags = goal.tags {
                tags = goalTags
            }
            
            savingIcon = goal.flex2!
            savingTitle = goal.title!
            
            
            if let index = arrayOfCategories.firstIndex(where: {$0.box_icon == savingIcon}) {
                collection_view_icons.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: [.centeredHorizontally, .centeredVertically])
            }
            
            
            text_field_amount.text = Utils.formatDecimalNumber(number: goalAmount, decimal: LocalPrefs.getDecimalFormat())
            text_field_saving_title.text = goal.title!
            text_field_tags.text = tags
            btn_target_date.setTitle(Utils.currentDateUserFormat(date: goalEndDate), for: .normal)
            btn_create_goal.setTitle("UPDATE SAVING GOAL", for: .normal)
        } else {
            self.navigationItem.title = "Add Goal"
        }
    }
    
    private func fetchCategoriesFromJson () {
        
        let data = categoryJson.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
            {
                for jsonObj in jsonArray {
                    let categoryJson = JSON(jsonObj).dictionaryValue
                    var category = Category()
                    category.title = categoryJson["title"]?.stringValue
                    category.box_icon = categoryJson["box_icon"]?.stringValue
                    arrayOfCategories.append(category)
                }
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    private func fetchGoalDetails (dbGoal : Hkb_goal, isUpdate: Bool) {
        dbGoal.amount = Utils.removeComma(numberString: text_field_amount.text!)
        dbGoal.currency = LocalPrefs.getUserCurrency()
        dbGoal.targetenddate = targetDate
        dbGoal.title = text_field_saving_title.text
        dbGoal.createdon = Utils.currentDateDbFormat(date: Date())
        dbGoal.active = 1
        dbGoal.tags = tags
        dbGoal.flex2 = savingIcon
        
        if editGoal == nil {
            //            dbGoal.goalId = Int64(QueryUtils.getMaxGoalId() + 1)
            dbGoal.goalId = Utils.getUniqueId()
        }
        
        if editGoal == nil {
            //            dbGoal.goalId = Int64(QueryUtils.getMaxGoalId() + 1)
            postGoalToServer(goal: dbGoal, isUpdate: isUpdate)
        } else {
            if QueryUtils.getGoalSync(goalId: dbGoal.goalId) == 1 {
                postGoalToServer(goal: dbGoal, isUpdate: isUpdate)
            } else {
                dbGoal.is_synced = 0
                DbController.saveContext()
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            }
        }
        
        
        
    }
    
    @objc private func saveGoal () {
        
        if btn_target_date.titleLabel?.text != "Target date" {
            if editGoal != nil {
                fetchGoalDetails(dbGoal: editGoal!, isUpdate: true)
                UIUtils.showSnackbar(message: "Goal updated successfully")
            } else {
                let newGoal : Hkb_goal = NSEntityDescription.insertNewObject(forEntityName: "Hkb_goal", into: DbController.getContext()) as! Hkb_goal
                fetchGoalDetails(dbGoal: newGoal, isUpdate: false)
                UIUtils.showSnackbar(message: "Goal created successfully")
            }
            self.dismiss(animated: true, completion: nil)
        } else {
            UIUtils.showAlert(vc: self, message: "Please select the target date")
        }
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
    
    @objc private func onNavRightIconTapped () {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onCreateSavingTapped(_ sender: Any) {
        
        
        if Utils.validateString(vc: self, string: text_field_saving_title.text!, errorMsg: "Please enter saving goal title") && Utils.validateString(vc: self, string: text_field_amount.text!, errorMsg: "Please enter saving amount") && Utils.validateString(vc: self, string: savingIcon, errorMsg: "Please select icon")  {
            self.saveGoal()
        }
        
    }
    
    @IBAction func onTargetTapped(_ sender: Any) {
        let datePopup = DialogSelectDate()
        datePopup.myDelegate = self
        datePopup.customDate = Utils.convertStringToDate(dateString: targetDate)
        datePopup.disableBackdate = true
        datePopup.dialogTitle = "Target Date"
        self.presentPopupView(popupView: datePopup)
    }
    
    @objc private func onTagsTapped () {
        let addTagsPopup = AddTagsPopup()
        addTagsPopup.delegate = self
        addTagsPopup.addedTags = tags
        self.presentPopupView(popupView: addTagsPopup)
    }
    
}

extension AddSavingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibIconName, for: indexPath) as! CategoryCell
        
        cell.cellType = "Category"
        cell.configureSavingCategoryWithItemCells(category: arrayOfCategories[indexPath.row])
        
        
        iconsCollectionHeight.constant = collectionView.contentSize.height
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        
        
        cell.isSelected = true
        savingIcon = arrayOfCategories[indexPath.row].box_icon!
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        
        cell.isSelected = false
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collection_view_icons.frame.size.width / 4
        let height: CGFloat = 80
        return CGSize(width: width, height: height)
    }
}

extension AddSavingViewController: UITextFieldDelegate, DateSelectionListener, TagsAddListener {
    
    func onTagsAdded(tags: String) {
        self.tags = tags
        text_field_tags.text = tags
    }
    
    
    func onDateSelected(date: Date) {
        btn_target_date.setTitle(Utils.currentDateUserFormat(date: date), for: .normal)
        targetDate = Utils.currentDateDbFormat(date: date)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        switch textField {
        case text_field_saving_title:
            text_field_amount.becomeFirstResponder()
            break
            
        default:
            print("Nothing")
        }
        
        return true
    }
}
