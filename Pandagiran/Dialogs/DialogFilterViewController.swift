

import UIKit

class DialogFilterViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource {
    var categoryPicker : UIPickerView?
    var accountPicker : UIPickerView?
    var typePicker : UIPickerView?
    var categoriesArray : Array<Hkb_category> = []
    var accountsArray : Array<Hkb_account> = []
    var pickerCategories : Array<String> = []
    var pickerAccounts : Array<String> = []
    var categoryId : Int = 0
    var categoryType: String = "ALL TYPE"
    var accountId : Int = 0
    var filterType : String = ""
    var typesArray : Array<String> = ["-All types-" , "Expense" , "Income" , "Transfer"]
    var myDelegate : OnFilterApplied?
    var alert = UIAlertController()

    @IBOutlet weak var btn_category: UIButton!
    @IBOutlet weak var btn_account: UIButton!
    @IBOutlet weak var btn_type: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        populateCategories(categoryType: categoryType)
        populateAccounts()
    }
    
    func initUI () {
        btn_type.semanticContentAttribute = .forceRightToLeft
        btn_account.semanticContentAttribute = .forceRightToLeft
        btn_category.semanticContentAttribute = .forceRightToLeft
        
        overlayBlurredBackgroundView()
    }
    
    func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = self.view.bounds
        blurredBackgroundView.effect = UIBlurEffect(style: .regular)
        blurredBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurredBackgroundView, at: 0)
    }

    func populateCategories (categoryType: String) {
        pickerCategories.removeAll()
        categoriesArray = QueryUtils.fetchCategories(type: categoryType)
        
        pickerCategories.append("-All categories-")
        for i in 0 ..< categoriesArray.count {
            pickerCategories.append(categoriesArray[i].title!)
        }
    }
    
    func populateAccounts () {
        accountsArray = QueryUtils.fetchAccounts(accountType: [])
        
        pickerAccounts.append("-All accounts-")
        for i in 0 ..< accountsArray.count {
            pickerAccounts.append(accountsArray[i].title!)
        }
    }
    
    func getAlertWidth (view : UIView) -> Int {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 300
        } else {
            return Int(view.frame.width - 20)
        }
    }
    
    func showPicker (sender : UIButton ,type : String) {
        guard let viewRect = sender as? UIView else {
            return
        }
        
        alert = UIAlertController(title: "", message: "\n\n\n\n\n\n\n", preferredStyle: UIAlertController.Style.actionSheet)
        alert.isModalInPopover = true
        
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = viewRect
            presenter.sourceRect = viewRect.bounds
        }
        
        print("ALERT FRAME : " , alert.view.frame)
        
        if type == "Category" {
            alert.title = "Please select category"
            populateCategories(categoryType: (btn_type.titleLabel?.text)!)
            categoryPicker = UIPickerView(frame: CGRect(x: 0, y: 50, width: getAlertWidth(view: alert.view) , height: 150))
            categoryPicker?.delegate = self
            alert.view.addSubview(categoryPicker!)
        } else if type == "Account" {
            alert.title = "Please select account"
            accountPicker = UIPickerView(frame: CGRect(x: 0, y: 50, width: getAlertWidth(view: alert.view), height: 150))
            accountPicker?.delegate = self
            alert.view.addSubview(accountPicker!)
        } else {
            alert.title = "Please select type"
            typePicker = UIPickerView(frame: CGRect(x: 0, y: 50, width: getAlertWidth(view: alert.view), height: 150))
            typePicker?.delegate = self
            alert.view.addSubview(typePicker!)
        }
        

        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if type == "Category" {
                let index = self.categoryPicker?.selectedRow(inComponent: 0)
                self.btn_category.setTitle(self.pickerCategories[index!], for: .normal)
                
                if index! == 0 {
                    self.categoryId = 0
                } else {
                    self.categoryId = Int(self.categoriesArray[index! - 1].categoryId)
                }
            } else if type == "Account" {
                let index = self.accountPicker?.selectedRow(inComponent: 0)
                self.btn_account.setTitle(self.pickerAccounts[index!], for: .normal)
                
                if index! == 0 {
                    self.accountId = 0
                } else {
                    self.accountId = Int(self.accountsArray[index! - 1].account_id)
                }
            } else {
                let index = self.typePicker?.selectedRow(inComponent: 0)
                self.btn_type.setTitle(self.typesArray[index!], for: .normal)
                
                if index! == 0 {
                    self.filterType = ""
                } else if index! == 1 {
                    self.filterType = Constants.EXPENSE
                } else if index! == 2 {
                    self.filterType = Constants.INCOME
                } else {
                    self.filterType = Constants.TRANSFER
                }
            }
        })
        alert.addAction(okAction)
//        alert.view.tintColor = Utils.hexStringToUIColor(hex: AppColors.hk_green)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func onFilterTypeTapped(_ sender: Any) {
        showPicker(sender: btn_type, type: "Type")
    }
    
    @IBAction func onAccountTapped(_ sender: Any) {
        showPicker(sender: btn_account, type: "Account")
    }
    
    @IBAction func omCategoryTapped(_ sender: Any) {
        showPicker(sender: btn_category, type : "Category")
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onFilterApplied(_ sender: Any) {
        let filterString = "\(btn_type.titleLabel!.text!) , \(btn_account.titleLabel!.text!) , \(btn_category.titleLabel!.text!)"
        myDelegate?.filterParams(categoryId: categoryId, accountId: accountId, type: filterType, filterString: filterString)
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPicker {
            return pickerCategories.count
        } else if pickerView == accountPicker {
            return pickerAccounts.count
        } else {
            return typesArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker {
            return pickerCategories[row]
        } else if pickerView == accountPicker {
            return pickerAccounts[row]
        } else {
            return typesArray[row]
        }
    }

}

