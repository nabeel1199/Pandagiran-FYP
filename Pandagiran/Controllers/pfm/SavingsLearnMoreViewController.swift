

import UIKit
import SwiftyJSON

class SavingsLearnMoreViewController: BaseViewController {

    @IBOutlet weak var btn_set_goal: UIButton!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collection_view_categories: UICollectionView!
    @IBOutlet weak var label_people_save_for: UILabel!
    @IBOutlet weak var label_placeholder_title: CustomFontLabel!
    
    private let nibCategoryName = "CategoryCell"
    private var arrayOfCategories : Array<Category> = []
    private var savingTitle = ""
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
        super.viewDidLoad()

        initVariables()
        initUI()
        fetchCategoriesFromJson()
    }
    
    private func initVariables () {
        initNibs()
        
        collection_view_categories.delegate = self
        collection_view_categories.dataSource = self
    }
    
    private func initUI () {
        self.navigationItemColor = .light
        self.viewBackgroundColor = .white
    }
    
    private func initNibs () {
        let nibCategory = UINib(nibName: nibCategoryName, bundle: nil)
        collection_view_categories.register(nibCategory, forCellWithReuseIdentifier: nibCategoryName)
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

    @IBAction func onSetGoalTapped(_ sender: Any) {
        let addSavingVC = getStoryboard(name: ViewIdentifiers.SB_SAVING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_SAVING) as! AddSavingViewController
        addSavingVC.savingTitle = self.savingTitle
        addSavingVC.savingIcon = self.savingIcon
        self.navigationController?.pushViewController(addSavingVC, animated: true)
    }
    
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationItemColor = .dark
    }

}

extension SavingsLearnMoreViewController: UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection_view_categories.dequeueReusableCell(withReuseIdentifier: nibCategoryName, for: indexPath) as! CategoryCell
        
        cell.cellType = "Category"
        cell.configureSavingCategoryWithItemCells(category: arrayOfCategories[indexPath.row])
    
        collectionViewHeight.constant = collectionView.contentSize.height
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        
        
        cell.isSelected = true
        self.savingTitle = arrayOfCategories[indexPath.row].title!
        self.savingIcon = arrayOfCategories[indexPath.row].title!
        
        
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
