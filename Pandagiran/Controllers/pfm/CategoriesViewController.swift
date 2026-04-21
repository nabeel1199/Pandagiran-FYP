

import UIKit
import Alamofire
import SwiftyJSON

class CategoriesViewController: BaseViewController {

    
    @IBOutlet weak var view_segments: SignatureSegmentedControl!
    @IBOutlet weak var table_view_categories: UITableView!
    
    private let nibCategoryName = "UserSelectionViewCell"
    private var arrayOfCategories : Array<Hkb_category> = []
    private var isExpense = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()


        initVariables()
        initUI()
//        fetchCategories(type: Coandnstants.EXPENSE)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchCategories(type: Constants.EXPENSE)
    }
    
    private func initVariables () {
        view_segments.delegate = self
        table_view_categories.delegate = self
        table_view_categories.dataSource = self
        
        initNibs()
    }
    
    private func initUI () {
        self.navigationItem.title = "Manage Categories"

    }
    
    private func fetchCategories (type: String) {
        arrayOfCategories = QueryUtils.fetchCategories(type: type, showActive: false)
        
        DispatchQueue.main.async {
            self.table_view_categories.reloadData()
        }
        
    }
    
    private func initNibs () {
        let nibCategory = UINib(nibName: nibCategoryName, bundle: nil)
        table_view_categories.register(nibCategory, forCellReuseIdentifier: nibCategoryName)
    }

    @IBAction func onAddCategoryTapped(_ sender: Any) {
        let addCategoryVC = self.getStoryboard(name: ViewIdentifiers.SB_CATEGORY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_CATEGORY) as! AddCategoryViewController
        addCategoryVC.isExpense = self.isExpense
        addCategoryVC.delegate = self
        self.navigationController?.pushViewController(addCategoryVC, animated: true)
    }
    
    @objc private func onBackTapped () {
        self.dismiss(animated: false, completion: nil)
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

    
}

extension CategoriesViewController : SegmentButtonTappedListener, CategoryAddedListener {
    
    func onCategoryAdded() {
        arrayOfCategories.removeAll()
        
        if view_segments.selectedSegmentIndex == 0 {
            fetchCategories(type: Constants.EXPENSE)
        } else {
            fetchCategories(type: Constants.INCOME)
        }
        
    }
    
    
    func onSegmentTapped(btnTitle: String) {
        if btnTitle == "EXPENSE" {
            fetchCategories(type: Constants.EXPENSE)
            isExpense = 1
        } else {
            fetchCategories(type: Constants.INCOME)
            isExpense = 0
        }
    }
    
    
}

extension CategoriesViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibCategoryName, for: indexPath) as! UserSelectionViewCell
        
        let category = arrayOfCategories[indexPath.row]
        cell.configureCategoryWithItem(category: category)
        
        let editGest = UITapGestureRecognizer(target: self, action: #selector(onEditTapped(_:)))
        cell.iv_edit.tag = indexPath.row
        cell.iv_edit.isUserInteractionEnabled = true
        cell.iv_edit.addGestureRecognizer(editGest)
        
        let visibleGest = UITapGestureRecognizer(target: self, action: #selector(onVisibilityTapped(_:)))
        cell.iv_visibility.tag = indexPath.row
        cell.iv_visibility.isUserInteractionEnabled = true
        cell.iv_visibility.addGestureRecognizer(visibleGest)
        
        cell.cellType = "Category"
        cell.selectionStyle = .none
        return cell
    }
    
  

    
    @objc private func onEditTapped (_ tapGesture: UITapGestureRecognizer) {
        if let senderView = tapGesture.view {
            let category = arrayOfCategories[senderView.tag]
            
            if category.parent_category_id != 0 {
                let addCategoryVC = self.getStoryboard(name: ViewIdentifiers.SB_CATEGORY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_CATEGORY) as! AddCategoryViewController
                addCategoryVC.isExpense = self.isExpense
                addCategoryVC.editCategory = category
                self.navigationController?.pushViewController(addCategoryVC, animated: true)
            }
        }
        
    }
    
    @objc private func onVisibilityTapped (_ tapGesture: UITapGestureRecognizer) {
        if let senderView = tapGesture.view {
            let category = arrayOfCategories[senderView.tag]
            
            if category.active == 0 {
                category.active = 1
            } else {
                category.active = 0
            }

            DbController.saveContext()
            
            if QueryUtils.getCategorySync(categoryId: arrayOfCategories[senderView.tag].categoryId) == 1 {
                postCategoryToServer(category: category, isUpdate: true)
            } else{
                category.is_synced = 0
                DbController.saveContext()
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                
            }
            table_view_categories.reloadData()

            
        }
       
    }
    
    
    
}
