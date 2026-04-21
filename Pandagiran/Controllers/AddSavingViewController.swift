//
//  AddSavingViewController.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 3/23/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddSavingViewController: BaseViewController {

    @IBOutlet weak var view_tags: CardView!
    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var text_field_saving_title: UITextField!
    @IBOutlet weak var text_field_amount: UITextField!
    @IBOutlet weak var collection_view_icons: UICollectionView!
    @IBOutlet weak var text_field_tags: UITextField!
    @IBOutlet weak var btn_target_date: UIButton!
    @IBOutlet weak var view_target_date: CardView!
    @IBOutlet weak var iconsCollectionHeight: NSLayoutConstraint!
    
    private let nibIconName = "CategoryCell"
    private var arrayOfCategories : Array<Category> = []
    private var iconsArray = ["bt_1" , "bt_2" , "bt_3" , "bt_4" , "bt_5" , "bt_6"]
    private var targetDate = ""
    public var boxIcon = ""
    public var savingTitle = ""
    private var tags = ""
    private var savingIcon = ""
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
        "  {\"category_id\": 711,\"title\": \"Gifts\",\"box_icon\": \"gfts_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 712,\"title\": \"Shopping\",\"box_icon\": \"shopping_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 713,\"title\": \"Picnic/Party\",\"box_icon\": \"party_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 714,\"title\": \"Home Appliances\",\"box_icon\": \"appliances_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"},\n" +
        "  {\"category_id\": 715,\"title\": \"Other\",\"box_icon\": \"other_inactive\",\"box_color\": \"#339b9c\",\"is_expense\": 0,\"balance_amount\": \"0.00\",\"user_id\": 0,\"budget_amount\": \"0.00\"}\n" +
    "] "
    
    
    
    override func viewDidLoad() {

        initVariables()
        initUI()
        fetchCategoriesFromJson()

    }
    
    private func initVariables () {
        label_currency.text = LocalPrefs.getUserCurrency()
        initNibs()
        
        collection_view_icons.delegate = self
        collection_view_icons.dataSource = self
                
        text_field_saving_title.delegate = self
        text_field_amount.delegate = self
        text_field_tags.delegate = self
    }
    
    private func initUI () {
        text_field_saving_title.text = savingTitle
        self.navigationItemColor = .light
        self.navigationItem.title = "Add Goal"
        
        let navRightIcon = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onNavRightIconTapped))
        self.navigationItem.rightBarButtonItem = navRightIcon
        
        
        let tagsTapGest = UITapGestureRecognizer(target: self, action: #selector(onTagsTapped))
        view_tags.addGestureRecognizer(tagsTapGest)
    }
    
    private func initNibs () {
        let nibIcon = UINib(nibName: nibIconName, bundle: nil)
        collection_view_icons.register(nibIcon, forCellWithReuseIdentifier: nibIconName)
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
    
    private func fetchGoalDetails () -> String {
        let jsonEncoder = JSONEncoder()
        var savingJson = ""
        
        let currentDate = Date()
        let saving = Saving()
        saving.title = text_field_saving_title.text!
        saving.active = 1
        saving.amount = Utils.removeComma(numberString: text_field_amount.text!)
        saving.createdon = Utils.currentDateDbFormat(date: currentDate)
        saving.targetenddate = targetDate
        saving.icon = savingIcon
        saving.currency = LocalPrefs.getUserCurrency()
        saving.tags = text_field_tags.text!
    
        do {
            let jsonData = try jsonEncoder.encode(saving)
            savingJson = String(data: jsonData, encoding: .utf8)!
        } catch {
            print("SAVING ERROR : " , error)
        }
        
        return savingJson
    }
    
    private func postGoalToServer (isUpdate : Bool) {
        UIUtils.showLoader(view: self.view)
        let goalsJson = fetchGoalDetails()
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        var URL = "\(Constants.BASE_URL_SYNC)/saving/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        var httpMethod = Alamofire.HTTPMethod.post
        let params = ["savings" : goalsJson,
                      "device_type" : "Ios",
                      "consumer_id" : consumerId]
        
        if isUpdate {
            URL = "\(Constants.BASE_URL_SYNC)/saving/update"
            httpMethod = Alamofire.HTTPMethod.patch
        }
        
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
                        UIUtils.showSnackbar(message: "Goal created successfully")
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

    @objc private func onNavRightIconTapped () {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onCreateSavingTapped(_ sender: Any) {
        postGoalToServer(isUpdate: false)
    }
    
    @IBAction func onTargetTapped(_ sender: Any) {
        let datePopup = DateSelectionPopup()
        datePopup.delegate = self
        self.presentPopupView(popupView: datePopup)
    }
    
    @objc private func onTagsTapped () {
        let addTagsPopup = AddTagsPopup()
        self.presentPopupView(popupView: addTagsPopup)
    }
    
}

extension AddSavingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibIconName, for: indexPath) as! CategoryCell
        
        cell.configureCategoryWithItemCells(category: arrayOfCategories[indexPath.row])
        cell.contentView.layer.borderWidth = 0
        cell.category_title.textColor = UIColor().hexCode(hex: Style.color.LIGHT_TEXT)
        cell.bg_view.layer.shadowOpacity = 0.0
        cell.bg_view.layer.borderWidth = 1
        cell.category_title.isHidden = true
        
        iconsCollectionHeight.constant = collectionView.contentSize.height
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        
        
        cell.bg_view.layer.borderColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR).cgColor
        cell.bg_view.layer.borderWidth = 2.0
        cell.bg_view.layer.shadowOpacity = 0.3
        cell.category_title.textColor = UIColor.black
        cell.categoryImage.tintColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR)
        self.savingTitle = arrayOfCategories[indexPath.row].title!
        self.savingIcon = arrayOfCategories[indexPath.row].title!
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        
        
        cell.bg_view.layer.borderColor = UIColor.lightGray.cgColor
        cell.bg_view.layer.borderWidth = 1.0
        cell.bg_view.layer.shadowOpacity = 0
        cell.category_title.textColor = UIColor().hexCode(hex: Style.color.LIGHT_TEXT)
        cell.categoryImage.tintColor = UIColor.lightGray
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collection_view_icons.frame.size.width / 4
        let height: CGFloat = 80
        return CGSize(width: width, height: height)
    }
}

extension AddSavingViewController: UITextFieldDelegate, DateSelectionListener {
    
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
