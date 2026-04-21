

import UIKit
import Alamofire
import SwiftyJSON

class EventViewController: BaseViewController {

    @IBOutlet weak var label_create_new: UILabel!
    @IBOutlet weak var label_your_events: UILabel!
    @IBOutlet weak var view_create_new: CardView!
    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var table_view_events: UITableView!
    @IBOutlet weak var segment_view: SignatureSegmentedControl!
    @IBOutlet weak var customSegmentWidth: NSLayoutConstraint!
    
    private let nibSegmentName = "CustomSegmentViewCell"
    private let nibEventName = "EventViewCell"
    private var eventsArray : Array<Hkb_event> = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchEvents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        
        
    }
    
    private func initVariables () {
        initNibs()
        
        segment_view.delegate = self
        
        table_view_events.delegate = self
        table_view_events.dataSource = self
        
        view_placeholder.isHidden = true

        
        let createTapGest = UITapGestureRecognizer(target: self, action: #selector(onCreateEventTapped))
        view_create_new.addGestureRecognizer(createTapGest)
        
    }
    
    private func initUI () {
        self.navigationItem.title = "Events"
        
        label_your_events.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        
        label_create_new.regularFont(fontStyle: .bold, size: Style.dimen.SMALL_TEXT)
    }
    
    private func initNibs () {
        let nibSegments = UINib(nibName: nibSegmentName, bundle: nil)
        let nibEvent = UINib(nibName: nibEventName, bundle: nil)
        
        //        collection_view_segments.register(nibSegments, forCellWithReuseIdentifier: nibSegmentName)
        table_view_events.register(nibEvent, forCellReuseIdentifier: nibEventName)
    }
    
    private func showPlaceholder () {
        if eventsArray.count == 0 {
            view_placeholder.isHidden = false
        } else {
            view_placeholder.isHidden = true
        }
    }
    
    private func fetchEvents () {
        eventsArray.removeAll()
        let allEvents = QueryUtils.fetchAllEvents()
        let currentDate = Date()
        for i in 0 ..< allEvents.count {
            let startDate = Utils.convertStringToDate(dateString: allEvents[i].startdate!)
            let endDate = Utils.convertStringToOnlyDate(dateString: allEvents[i].enddate!)
            

            if segment_view.selectedSegmentIndex == 0 {
                if !endDate.isInThePast{
                    eventsArray.append(allEvents[i])
                }
//                if Utils.isDateBetween(startDate, and: endDate, middleDate: currentDate) {
//                    eventsArray.append(allEvents[i])
//                }
                self.view_create_new.isHidden = false
            } else {
                if endDate.isInThePast{
                    eventsArray.append(allEvents[i])
                }
//                if !Utils.isDateBetween(startDate, and: endDate, middleDate: currentDate) {
//                    eventsArray.append(allEvents[i])
//                }
                self.view_create_new.isHidden = true
            }
        }
        
        self.table_view_events.reloadData()
        
        if eventsArray.count == 0 {
            view_placeholder.isHidden = false
        } else {
            view_placeholder.isHidden = true
        }
    }
    
    @objc private func onCreateEventTapped() {
        let navigationVC = UINavigationController()
        let addEventVC = getStoryboard(name: ViewIdentifiers.SB_EVENT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_EVENT) as! AddEventViewController
        navigationVC.viewControllers = [addEventVC]
        navigationVC.modalPresentationStyle = .currentContext
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    @IBAction func onLearnMoreTapped(_ sender: Any) {
        let navigationVC = UINavigationController()
        let learnMoreVC = getStoryboard(name: ViewIdentifiers.SB_EVENT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_EVENT_LEARN_MORE) as! EventLearnMoreViewController
        navigationVC.viewControllers = [learnMoreVC]
        self.present(navigationVC, animated: true, completion: nil)
    }
    
}

// Table view delegates
extension EventViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibEventName, for: indexPath) as! EventViewCell
        
        cell.configureEventWithItem(event: eventsArray[indexPath.row])
        
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventTransactionsVC = getStoryboard(name: ViewIdentifiers.SB_EVENT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_EVENT_TRANSACTIONS) as! EventTransactionsViewController
        eventTransactionsVC.event = eventsArray[indexPath.row]
        self.navigationController?.pushViewController(eventTransactionsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}


extension EventViewController : SegmentButtonTappedListener{
    func onSegmentTapped(btnTitle: String) {
        fetchEvents()
    }
    
}
