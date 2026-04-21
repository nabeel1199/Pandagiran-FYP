

import UIKit
import SwiftyJSON
import Kingfisher
import Firebase

class DialogSelectCurrency: UIViewController , UITableViewDelegate , UITableViewDataSource , UITextFieldDelegate {

    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var et_search: UITextField!
    var myDelegate : CurrencySelectionListener?
    var currencyArray : Array<UserCurrency> = []
    var currencyData : Array<UserCurrency> = []
    public var isCountryOpted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        
        if isCountryOpted {
            fetchCountries()
        } else {
            fetchCurrencies()
        }
     
    }
    
    private func initVariables () {
        et_search.delegate = self
        
        let nibCurrency = UINib(nibName: "NavigationViewCell", bundle: nil)
        table_view.register(nibCurrency, forCellReuseIdentifier: "NavigationViewCell")
        
        table_view.delegate = self
        table_view.dataSource = self
    
    }
    

    func fetchCurrencies() {
        let jsonObj = Utils.readJson(resourceName: "core_country")
        
        for currency in jsonObj{
            let objc = JSON(currency)
            let urlCode = objc["country_iso_code_2dg"].stringValue
            let currencyObj = UserCurrency()
            currencyObj.currency3dg = objc["iso_code_3dg"].stringValue
            currencyObj.currencyFlag = "http://bo.hysabkytab.com/HK_data_pics/country_flags/\(urlCode.lowercased()).png"
            currencyObj.currencyName = objc["country_name"].stringValue
            currencyObj.currencyPrecision = objc["currency_precision"].intValue
            currencyObj.currency2dg = objc["country_iso_code_2dg"].stringValue
            currencyArray.append(currencyObj)
        }
        
            currencyData = currencyArray
    }
    
    private func fetchCountries () {
        let jsonObj = Utils.readJson(resourceName: "countries")
        
        for currency in jsonObj{
            let objc = JSON(currency)
            let urlCode = objc["country_iso_code_2dg"].stringValue
            let currencyObj = UserCurrency()
            currencyObj.currency3dg = objc["country_iso_code_3dg"].stringValue
            currencyObj.currencyFlag = "http://bo.hysabkytab.com/HK_data_pics/country_flags/\(urlCode.lowercased()).png"
            currencyObj.currencyName = objc["country_name"].stringValue
            currencyObj.currency2dg = objc["country_iso_code_2dg"].stringValue
            currencyObj.currencyPrecision = objc["currency_precision"].intValue
            currencyArray.append(currencyObj)
        }
        
        currencyData = currencyArray
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchTextEntered(_ sender: Any) {
        let searchText = et_search.text
        
        currencyArray = currencyData.filter {
            return $0.currency3dg?.range(of : searchText!, options: .caseInsensitive) != nil || $0.currencyName?.range(of : searchText!, options: .caseInsensitive) != nil
        }
        
        if et_search.text?.count == 0 {
            currencyArray = currencyData
        }
        
        table_view.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationViewCell") as! NavigationViewCell
        let flagUrl = URL(string: currencyArray[indexPath.row].currencyFlag!)
        
        cell.label_nav_text.text = "\(currencyArray[indexPath.row].currencyName!) (\(currencyArray[indexPath.row].currency3dg!))"
        cell.navImage.kf.setImage(with: flagUrl)
        cell.navImage.contentMode = .scaleToFill
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myDelegate?.onCurrencySelected(currency: currencyArray[indexPath.row].currency3dg!, country2dg: currencyArray[indexPath.row].currency2dg!, currencyFlag: currencyArray[indexPath.row].currencyFlag!, countryName: currencyArray[indexPath.row].currencyName!, decimal: currencyArray[indexPath.row].currencyPrecision!)
        Analytics.logEvent("currency", parameters: ["currency" : currencyArray[indexPath.row].currency3dg!])
        self.dismiss(animated: true, completion: nil)
    }
}
