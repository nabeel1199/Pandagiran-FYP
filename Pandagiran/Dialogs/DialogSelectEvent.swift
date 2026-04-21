

import UIKit

class DialogSelectEvent: UIViewController {

    @IBOutlet weak var table_view: UITableView!
    
    private var eventsArray: Array<Hkb_event> = []
    public var voucherDate: String = ""
    public var myDelegate: EventSelectionListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        fetchExistingEvents()
    }
    
    private func initVariables () {
        table_view.dataSource = self
        table_view.delegate = self
        
        let nibEvents = UINib(nibName : "VoucherAccountViewCell" , bundle : nil)
        table_view.register(nibEvents, forCellReuseIdentifier: "VoucherAccountsViewCell")
    }

    private func initUI () {
        overlayBlurredBackgroundView()
    }
    
    private func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = self.view.bounds
        blurredBackgroundView.effect = UIBlurEffect(style: .regular)
        blurredBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurredBackgroundView, at: 0)
    }
    
    private func fetchExistingEvents() {
        var allEvents = QueryUtils.fetchAllEvents()
        let vchDate = Utils.convertStringToDate(dateString: voucherDate)
        
        for i in 0 ..< allEvents.count {
            let startDate = Utils.convertStringToDate(dateString: allEvents[i].startdate!)
            let endDate = Utils.convertStringToDate(dateString: allEvents[i].enddate!)
            
            if Utils.isDateBetween(startDate, and: endDate, middleDate: vchDate) {
                eventsArray.append(allEvents[i])
            }
        }
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension DialogSelectEvent : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        let cell = table_view.dequeueReusableCell(withIdentifier: "VoucherAccountsViewCell", for: indexPath) as! VoucherAccountViewCell
        
        if indexPath.row == eventsArray.count {
            cell.accountTitle.text = "Add Event"
            cell.label_balance.isHidden = true
            cell.accountImage.image = UIImage(named : "ic_add")?.withRenderingMode(.alwaysTemplate)
            cell.accountImage.tintColor = UIColor.black
            cell.bgView.layer.borderColor = UIColor.black.cgColor
        } else {
            let event = eventsArray[indexPath.row]
            let startDate = Utils.currentDateUserFormat(date: Utils.convertStringToDate(dateString: event.startdate!))
            let endDate = Utils.currentDateUserFormat(date: Utils.convertStringToDate(dateString: event.enddate!))
            cell.label_balance.isHidden = false
            cell.label_balance.text = "\(startDate) - \(endDate)"
            cell.label_balance.textColor = UIColor.gray
            cell.accountImage.image = UIImage(named: "ic_event")?.withRenderingMode(.alwaysTemplate)
            cell.accountImage.tintColor = UIColor.gray
            cell.bgView.layer.borderColor = UIColor.gray.cgColor
            cell.accountTitle.text = event.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == eventsArray.count {
            self.dismiss(animated: false, completion: nil)
            return
        } else {
            let event = eventsArray[indexPath.row]
            let cell : VoucherAccountViewCell = table_view.cellForRow(at: indexPath) as! VoucherAccountViewCell
            cell.accountImage.tintColor = UIColor.white
//            cell.bgView.backgroundColor = Utils.hexStringToUIColor(hex: AppColors.hk_green)
//            myDelegate?.onEventSelected(eventName: event.name!, eventId: Int(event.eventid))
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell : VoucherAccountViewCell = table_view.cellForRow(at: indexPath) as! VoucherAccountViewCell
        cell.accountImage.tintColor = UIColor.gray
        cell.bgView.backgroundColor = UIColor.white
        cell.bgView.layer.borderColor = UIColor.gray.cgColor
    }
}
