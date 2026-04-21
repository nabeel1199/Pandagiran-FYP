

import UIKit
import Alamofire
import SwiftyJSON

class EventTransactionsViewController: BaseViewController {

    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var view_event: CardView!
    @IBOutlet weak var view_create_new: CardView!
    @IBOutlet weak var table_view_transactions: UITableView!
    @IBOutlet weak var label_end_date: UILabel!
    @IBOutlet weak var label_start_date: UILabel!
    @IBOutlet weak var label_description: UILabel!
    @IBOutlet weak var label_title: UILabel!
    
    private let nibTransactionName = "TransactionViewCell"
    private var arrayOfVouchers : Array<Hkb_voucher> = []
    
    public var event : Hkb_event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setEventDetails()
        fetchEventTransactions()
        if self.event != nil {
            self.view_create_new.isHidden = true
        }
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_transactions.delegate = self
        table_view_transactions.dataSource = self
    }
    
    private func initUI () {
        self.navigationItem.title = event!.name!
        
        let createNewGest = UITapGestureRecognizer(target: self, action: #selector(onCreateNewTapped))
        view_create_new.addGestureRecognizer(createNewGest)
    }
    
    private func initNibs () {
        let nibTransaction = UINib(nibName: nibTransactionName, bundle: nil)
        table_view_transactions.register(nibTransaction, forCellReuseIdentifier: nibTransactionName)
    }
    
    private func setEventDetails () {
        if let event = self.event {
            let startDate = Utils.convertStringToDate(dateString: event.startdate!)
            let endDate = Utils.convertStringToDate(dateString: event.enddate!)
            label_title.text = event.name!
            label_description.text = event.desc!
            label_start_date.text = Utils.currentDateUserFormat(date: startDate)
            label_end_date.text = Utils.currentDateUserFormat(date: endDate)
        }
    
    }
    
    private func showPlaceholder () {
        if arrayOfVouchers.count == 0 {
            view_placeholder.isHidden = false
        } else {
            view_placeholder.isHidden = true
            self.table_view_transactions.reloadData()
        }
    }
    
    private func fetchEventTransactions () {
        arrayOfVouchers = ActivitiesDbUtils.fetchEventVouchers(eventId: event?.eventid ?? 0)
        showPlaceholder()
    }
    
    
    @IBAction func onMenuBtnTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: {action in
            let navController = UINavigationController()
            let editEventVC = self.getStoryboard(name: ViewIdentifiers.SB_EVENT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_EVENT) as! AddEventViewController
            editEventVC.editEvent = self.event
            navController.viewControllers = [editEventVC]
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: {action in
            let deletePopup = GenericPopup()
            deletePopup.delegate = self
            deletePopup.btnText = "DELETE EVENT"
            deletePopup.popupTitle = "DELETE EVENT"
            deletePopup.message = "Are you sure you want to delete this event?"
            self.presentPopupView(popupView: deletePopup)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc private func onCreateNewTapped () {
        let addEventVC = getStoryboard(name: ViewIdentifiers.SB_EVENT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_EVENT) as! AddEventViewController
        let navController = UINavigationController()
        navController.viewControllers = [addEventVC]
        self.present(navController, animated: true, completion: nil)
    }
    
    private func postEventToServer (event : Hkb_event, isUpdate : Bool) {
        let eventDetails = Utils.convertVchIntoDict(object: event)
        let eventsJson = Utils.convertDictIntoJson(object: eventDetails)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        var URL = "\(Constants.BASE_URL)/event/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        var httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["events" : eventsJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        if isUpdate {
            URL = "\(Constants.BASE_URL)/event/update"
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
                            event.is_synced = 1
                    } else {
                        event.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                    
                    DbController.saveContext()
                    
                case .failure(let error):
                    event.is_synced = 0
                    DbController.saveContext()
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
//                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
}

extension EventTransactionsViewController: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfVouchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibTransactionName, for: indexPath) as! TransactionViewCell
        
        cell.configureWithItem(accountId: 0, voucher: arrayOfVouchers[indexPath.row])
        
        cell.selectionStyle = .none
        return cell
    }
}

extension EventTransactionsViewController : GenericPopupSelection {
    
    func onButtonTapped(index: Int, objectIndex: Int) {
        if let event = self.event {
            event.active = 0
            DbController.saveContext()
            if QueryUtils.getEventSync(eventId: event.eventid) == 1{
                postEventToServer(event: event, isUpdate: true)
            } else {
                event.is_synced = 0
                DbController.saveContext()
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            }
            
            UIUtils.showSnackbar(message: "Event deleted successfully")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}
