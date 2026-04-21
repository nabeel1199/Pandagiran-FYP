

import UIKit
import FirebaseAnalytics
import CoreData
import Alamofire
import SwiftyJSON

class AddCategoryViewController: BaseViewController {

    @IBOutlet weak var btn_create_category: GradientButton!
    @IBOutlet weak var collection_view_categories: UICollectionView!
    @IBOutlet weak var iv_category: UIImageView!
    @IBOutlet weak var text_field_title: UITextField!
    
    private let nibCategoryName = "CategoryCell"
    private var arrayOfCategories : Array<Category> = []
    private var categoryColor = ""
    private var categoryIcon = ""
    private var existingCategoryId = 0
    
    public var delegate : CategoryAddedListener?
    public var editCategory : Hkb_category?
    public var isExpense = 0
    public var categoryId : Int64 = 0 {
        didSet {
            btn_create_category.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        fetchCategories()
        setEditCategoryDetails()
    }
    
    private func initVariables () {
        collection_view_categories.delegate = self
        collection_view_categories.dataSource = self
        text_field_title.delegate = self
        
        initNibs()
    }
    
    private func initUI () {
        self.navigationItem.title = "Add Category"
        
        btn_create_category.backgroundColor = UIColor.lightGray
        
        text_field_title.attributedPlaceholder =
            NSAttributedString(string: "Category Name",
                               attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)])
    }
    
    private func fetchCategories () {
        let categoriesJsonArray = Utils.readJson(resourceName: "hkb_category")
        var category : Dictionary<String , Any>
        
        for record in categoriesJsonArray {
            category = record as! Dictionary<String, Any>
     
            
            let isExpense = category["is_expense"] as! Int16
            
            if self.isExpense == isExpense {
                var dbCategory = Category()
                dbCategory.title = category["title"] as? String
                dbCategory.box_color = category["box_color"] as? String
                dbCategory.box_icon = category["box_icon"] as? String
                dbCategory.is_expense = category["is_expense"] as? Int16
                dbCategory.categoryId = category["category_id"] as? Int64
                arrayOfCategories.append(dbCategory)
            }
        }
    }
    
    private func initNibs () {
        let nibCategory = UINib(nibName: nibCategoryName,
                                bundle: nil)
        collection_view_categories.register(nibCategory,
                                            forCellWithReuseIdentifier: nibCategoryName)
    }
    
    private func setEditCategoryDetails () {
        if let category = editCategory {
            btn_create_category.setTitle("Save Changes", for: .normal)
            self.navigationItem.title = "Update Category"
            existingCategoryId = Int(category.categoryId)
            categoryId = category.parent_category_id
            categoryColor = category.box_color!
            categoryIcon = category.box_icon!
            text_field_title.text = category.title!
            iv_category.image = UIImage(named: categoryIcon)
            
            if let index = arrayOfCategories.firstIndex(where: { $0.categoryId == Int64(category.parent_category_id) }) {
                DispatchQueue.main.async {
                    self.collection_view_categories.selectItem(at: IndexPath(item: index, section: 0),
                                                               animated: false,
                                                               scrollPosition: [.centeredVertically])
                }
            }
        }
    }
    
    
//    private func categoryDetails (category : Hkb_category) {
        private func categoryDetails (category : Hkb_category) -> Hkb_category {
//        let maxCategoryId = QueryUtils.getMaxCategoryId() + 1
        let maxCategoryId = Utils.getUniqueId()
        category.title = text_field_title.text!
        category.active = 1
        category.box_color = categoryColor
        category.box_icon = categoryIcon
        category.cattype = ""
        category.is_expense = Int16(isExpense)
        category.parent_category_id = Int64(self.categoryId)
        
        if let existingCategory = editCategory {
            category.categoryId = existingCategory.categoryId
            return existingCategory
        } else {
            category.categoryId = Int64(maxCategoryId)
            return category
        }
    }
    
    private func saveCategory () {

            let existingCategory = QueryUtils.fetchCategoryByName(nameString: text_field_title.text!,
                                                                  categoryId: Int64(existingCategoryId))
            if existingCategory == nil {
                
                var category : Hkb_category?
                var isUpdate : Bool
                
                if editCategory != nil {
                    category = editCategory
                    isUpdate = true
                    
                } else {
                    let newCategory : Hkb_category = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_CATEGORY, into: DbController.getContext()) as! Hkb_category
                    isUpdate = false
                    category = newCategory
                }
                
//                categoryDetails(category: category!)
                
                
                if QueryUtils.getCategorySync(categoryId: categoryDetails(category: category!).parent_category_id) == 1 {
                    postCategoryToServer(category: categoryDetails(category: category!), isUpdate: isUpdate)
                } else {
                    categoryDetails(category: category!).is_synced = 0
                    DbController.saveContext()
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                }
                
                
            } else if existingCategory?.active == 0 {
                existingCategory?.active = 1
                if QueryUtils.getCategorySync(categoryId: existingCategory!.parent_category_id) == 1 {
                    postCategoryToServer(category: existingCategory!, isUpdate: true)
                } else {
                    existingCategory?.is_synced = 0
                    DbController.saveContext()
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                }
                
            } else {
                UIUtils.showAlert(vc: self, message: "This category already exists")
                return
            }
            
            
            DbController.saveContext()
            Analytics.logEvent("category_created",
                               parameters: [:])
            delegate?.onCategoryAdded()
            navigationController?.popViewController(animated: true)
        
    }
    
    private func postCategoryToServer (category : Hkb_category, isUpdate : Bool) {
        let categoryDetails = Utils.convertVchIntoDict(object: category)
        let categoryJson = Utils.convertDictIntoJson(object: categoryDetails)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        var URL = "\(Constants.BASE_URL)/category/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        var httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["categories" : categoryJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
//        if isUpdate {
//            URL = "\(Constants.BASE_URL)/category/update"
//            httpMethod = Alamofire.HTTPMethod.post
//        }
        
        
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
                        
                            category.is_synced = 1
                    } else {
                        category.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                    
                    DbController.saveContext()
                    
                case .failure(let error):
                    category.is_synced = 0
                    DbController.saveContext()
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                }
        }
    }

    @IBAction func onCreateTapped(_ sender: Any) {
        if Utils.validateString(vc: self, string: text_field_title.text!, errorMsg: "Please enter category title") && Utils.validateInt(vc: self, intValue: categoryId, errorMsg: "Please select parent category") {
            
            saveCategory()
        }
    }
    

}

extension AddCategoryViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection_view_categories.dequeueReusableCell(withReuseIdentifier: nibCategoryName, for: indexPath) as! CategoryCell
        
        cell.categoryImage.tintColor = UIColor.lightGray
        cell.category_title.text = arrayOfCategories[indexPath.row].title
        let image = UIImage(named: arrayOfCategories[indexPath.row].box_icon!)?.withRenderingMode(.alwaysTemplate)
        print(arrayOfCategories[indexPath.row].box_icon!)
        cell.categoryImage.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = arrayOfCategories[indexPath.row]
        categoryId = category.categoryId ?? 0
        categoryIcon = category.box_icon!
        categoryColor = category.box_color!
        iv_category.image = UIImage(named: categoryIcon)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 3.5
        let height: CGFloat = 85
        return CGSize(width: width, height: height)
    }
}

extension AddCategoryViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        text_field_title.resignFirstResponder()
        return true
    }
}
