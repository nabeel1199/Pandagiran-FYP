

import UIKit
import Alamofire
import SwiftyJSON


protocol EventSelectionListener {
    func onEventSelected (eventId: Int64, eventName: String)
}

class EventSelectionPopup: BasePopup {

    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var table_view_events: UITableView!
    
    @IBOutlet weak var tableEventsHeight: NSLayoutConstraint!
    @IBOutlet weak var popup_view: CardView!
    
    private let nibEventName = "CategorySelectionViewCell"
    private var eventArray : Array<Hkb_event> = []
    
    public var delegate: EventSelectionListener?
    public var showActive = true
    public var isFilter = false
    
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var titleLabel: CustomFontLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        initVariables()
        initUI()
        fetchEvents()
        
        if isFilter{
            createEventButton.isHidden = true
            titleLabel.text = "Select an Event"
        }
    }
    
    
    private func initVariables () {
        initNibs()
        
        table_view_events.delegate = self
        table_view_events.dataSource = self
    }
    
    private func initNibs () {
        let nibEvent = UINib(nibName: nibEventName, bundle: nil)
        table_view_events.register(nibEvent, forCellReuseIdentifier: nibEventName)
    }
    
    private func initUI () {
        self.animateView(popup_view: popup_view)
    }
    
    private func fetchEvents () {
        let allEvents = QueryUtils.fetchAllEvents()
        let currentDate = Date()
        for i in 0 ..< allEvents.count {
            let startDate = Utils.convertStringToDate(dateString: allEvents[i].startdate!)
            let endDate = Utils.convertStringToDate(dateString: allEvents[i].enddate!)
            
            if showActive {
                if Utils.isDateBetween(startDate, and: endDate, middleDate: currentDate) {
                    eventArray.append(allEvents[i])
                }
            } else {
                eventArray.append(allEvents[i])
            }
        }
            
        showPlaceholder()
    }

    private func showPlaceholder () {
        if eventArray.count == 0 {
            view_placeholder.isHidden = false
        }
    }
    
    @IBAction func onCloseButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onCreateNewTapped(_ sender: Any) {
        delegate?.onEventSelected (eventId: 0, eventName: "Wedding")
        self.dismiss(animated: true, completion: nil)
    }
}

extension EventSelectionPopup : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibEventName, for: indexPath) as! CategorySelectionViewCell
        
        cell.label_category.text = eventArray[indexPath.row].name
        cell.iv_selection.image = UIImage(named: "ic_radio_unchecked")?.withRenderingMode(.alwaysTemplate)
        cell.iv_selection.tintColor = UIColor.gray
        
        self.tableEventsHeight.constant = table_view_events.contentSize.height
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! CategorySelectionViewCell
        
        delegate?.onEventSelected (eventId: Int64(eventArray[indexPath.row].eventid), eventName: eventArray[indexPath.row].name!)
        cell.iv_selection.image = UIImage(named: "ic_radio_checked")
        cell.iv_selection.tintColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! CategorySelectionViewCell
        
        cell.iv_selection.image = UIImage(named: "ic_radio_checked")
        cell.iv_selection.tintColor = UIColor.lightGray
    }
    
    
}
