
import UIKit
import XLPagerTabStrip

class ActivityPageViewController: ButtonBarPagerTabStripViewController {
    
    private var currentInterval : String = Constants.MONTHLY
    private var quarterlyArray : Array<QuarterlyInterval> = []
    private var halfYearlyArray : Array<HalfYearlyInterval> = []
    private var monthlyArray : Array<MonthlyInterval> = []
    private var yearlyArray : Array<Int> = []
    
    public var passedInterval = LocalPrefs.getCurrentInterval()
    public var intervalIndex = 0
    public var categoryId: Int64 = 0
    public var accountId: Int64 = 0
    public var vchType: String = ""
    public var accountType: String = ""
    private var activityViewControllers : Array<UIViewController> = []
    private var arrayOfVouchers : Array<Hkb_voucher> = []
    let activityDetailVC = ActivityDetailsViewController()
    
    
    override func viewDidLoad() {
        configureTabViews()
        super.viewDidLoad()
        
        initUI()
        selectInitialIndex()
        
        let searchIcon = UIBarButtonItem(image: UIImage(named: "ic_search"), style: .plain, target: self, action: #selector(onSearchTapped))
        let shareIcon = UIBarButtonItem(image: UIImage(named: "ic_share_activity"), style: .plain, target: self, action: #selector(onShareTapped))
        self.navigationItem.rightBarButtonItems = [shareIcon, searchIcon]
        
    }
    
    @objc private func onShareTapped () {
        arrayOfVouchers.removeAll()

        let vc = viewControllers[self.currentIndex] as! ActivityDetailsViewController
        let month = vc.month
        let year = vc.year
        let interval = vc.passedInterval
        let eventId = vc.eventId
        let categoryId = vc.categoryId
        let accountId = vc.accountId
        let vchType = vc.vchType
        let amountRange = vc.amountRange
        let sortBy = vc.sortBy
        let isAscending = vc.isAscending
        
        arrayOfVouchers = ActivitiesDbUtils.fetchFilteredVouchers(accountId: accountId,
                                                                  categoryId: categoryId,
                                                                  eventId: eventId,
                                                                  type: vchType,
                                                                  amountRange: amountRange,
                                                                  currentInterval: interval,
                                                                  month: month,
                                                                  year: year,
                                                                  sortBy: sortBy,
                                                                  isAscending: isAscending,
                                                                  offset: 0,
                                                                  limit: 0)
        
        if arrayOfVouchers.count > 0 {
            self.exportDB()
        } else {
            UIUtils.showAlert(vc: self, message: "No data to export")
        }
        
    }
    
    @objc private func onSearchTapped () {
        let navController = UINavigationController()
        let searchVC = UIUtils.getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SEARCH_ACTIVITY) as! SearchActivityViewController
        searchVC.currentInterval = currentInterval
        searchVC.intervalIndex = self.intervalIndex
        navController.viewControllers = [searchVC]
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    private func selectInitialIndex () {
        DispatchQueue.main.async {
            self.moveToViewController(at: self.intervalIndex, animated: false)
            
        }
    }
    
    private func fetchIntervals () {
        monthlyArray.removeAll()
        quarterlyArray.removeAll()
        halfYearlyArray.removeAll()
        yearlyArray.removeAll()
        monthlyArray = TimeIntervalUtils.getMonthlyInterval()
        quarterlyArray = TimeIntervalUtils.getQuarterlyInterval()
        halfYearlyArray = TimeIntervalUtils.getHalfYearlyInterval()
        yearlyArray = TimeIntervalUtils.getYearlyInterval()
    }
    
    private func initUI () {
        view.backgroundColor = Utils.hexStringToUIColor(hex: "#f9f9f9")
        self.navigationItem.title = "Transaction History"
        
        buttonBarView.frame.size = CGSize(width: self.view.frame.width, height: 50)
        buttonBarView.selectedBar.backgroundColor = UIColor.white
        buttonBarView.backgroundColor = UIColor.clear
        
    }
    
    private func configureTabViews () {
        settings.style.buttonBarBackgroundColor = UIColor.clear
        settings.style.buttonBarItemBackgroundColor = UIColor.clear
        settings.style.selectedBarHeight = 0
        settings.style.buttonBarItemFont = UIFont(name: "Montserrat", size: 14.0)!
    }
    
    private func configureSelectedTabView () {
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor(white: 1, alpha: 0.6)
            newCell?.label.textColor = UIColor.white
            
            
            if animated {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
            }
            else {
                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
    }
    
    private func getActivityController () -> ActivityDetailsViewController {
        let activitiesVC = UIUtils.getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACTIVITY) as! ActivityDetailsViewController
        return activitiesVC
    }
    
    private func getControllers () -> Array<UIViewController> {
        let interval = self.passedInterval
        
        if interval == Constants.MONTHLY {
            for i in 0 ..< monthlyArray.count {
                let activityVC = getActivityController()
                activityViewControllers.append(activityVC)
                activityVC.categoryId = self.categoryId
                activityVC.accountId = self.accountId
                activityVC.vchType = self.vchType
                activityVC.accountType = self.accountType
                activityVC.tabTitle = monthlyArray[i].month!
                activityVC.month = String(monthlyArray[i].monthNumeric!)
                activityVC.year = monthlyArray[i].year!
                activityVC.passedInterval = self.passedInterval
            }
        } else if interval == Constants.HALF_YEARLY {
            for i in 0 ..< halfYearlyArray.count {
                let activityVC = getActivityController()
                activityViewControllers.append(activityVC)
                activityVC.month = halfYearlyArray[i].months!
                activityVC.year = halfYearlyArray[i].year!
                activityVC.categoryId = self.categoryId
                activityVC.accountType = self.accountType
                activityVC.accountId = self.accountId
                activityVC.vchType = self.vchType
                activityVC.tabTitle = halfYearlyArray[i].monthRange!
                activityVC.passedInterval = self.passedInterval
            }
        } else if interval == Constants.QUARTERLY {
            
            for i in 0 ..< quarterlyArray.count {
                let activityVC = getActivityController()
                activityViewControllers.append(activityVC)
                activityVC.month = quarterlyArray[i].monthRange!
                activityVC.year = quarterlyArray[i].year!
                activityVC.accountType = self.accountType
                activityVC.categoryId = self.categoryId
                activityVC.accountId = self.accountId
                activityVC.vchType = self.vchType
                activityVC.tabTitle = quarterlyArray[i].months!
                activityVC.passedInterval = self.passedInterval
            }
        } else if interval == Constants.YEARLY {
            for i in 0 ..< yearlyArray.count {
                let activityVC = getActivityController()
                activityViewControllers.append(activityVC)
                activityVC.year = yearlyArray[i]
                activityVC.categoryId = self.categoryId
                activityVC.accountType = self.accountType
                activityVC.accountId = self.accountId
                activityVC.vchType = self.vchType
                activityVC.tabTitle = String(yearlyArray[i])
                activityVC.passedInterval = self.passedInterval
            }
        } else {
            let activityVC = getActivityController()
            activityViewControllers.append(activityVC)
            activityVC.categoryId = self.categoryId
            activityVC.vchType = self.vchType
            activityVC.accountType = self.accountType
            activityVC.accountId = self.accountId
            activityVC.tabTitle = Constants.ALL_TIME
            activityVC.passedInterval = self.passedInterval
        }
        
        return activityViewControllers
    }
    
    func exportDB() {
        let exportedString = createExportString()
        saveAndExport(exportString: exportedString)
    }
    
    func saveAndExport (exportString : String) {
        let exportFilePath = NSTemporaryDirectory() + "HysabKytabData(\(Utils.currentDateReminderFormat(date: Date()))).csv"
        let exportFileURL = URL(string : exportFilePath)
        FileManager.default.createFile(atPath: exportFilePath, contents: NSData() as Data, attributes: nil)
        var fileHandle : FileHandle? = nil
        
        do {
            fileHandle = try FileHandle(forWritingTo: exportFileURL as! URL)
        } catch {
            print("Error with fileHandle")
        }
        
        if fileHandle != nil {
            fileHandle!.seekToEndOfFile()
            let csvData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            fileHandle!.write(csvData!)
            
            fileHandle!.closeFile()
            
            let firstActivityItem = NSURL(fileURLWithPath: exportFilePath)
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [firstActivityItem], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
            ]
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func createExportString () -> String {
        var vchAmount : Double?
        var description : String?
        var date : String?
        var categoryName : String?
        var useCase = ""
        var tags : String?
        var place : String = ""
        var fcrate = ""
        var eventId = ""
        var currency = ""
        var eventName = ""
        var hkb_category : Hkb_category?
        var export : String = NSLocalizedString("Voucher amount , Voucher desc , Voucher Date , Voucher type , Use Case , Category name , Account name , Place , Fc amount , Fc rate , Tags , Event Id , Base Currency , Event Name \n", comment: "")
        
        for (_ , items) in arrayOfVouchers.enumerated() {
            vchAmount = items.vch_amount
            description = items.vch_description?.replacingOccurrences(of: ",", with: " ")
            let vchType = items.vch_type
            let fcamount = items.fcamount
            
            if let fcRate = items.fcrate {
                fcrate = fcRate
            }
            
            if items.flex1 != nil && items.flex1 != "Select place" {
                place = items.flex1!.replacingOccurrences(of: ",", with: " ")
            }
            
            if items.vch_type != "Transfer" {
                hkb_category = QueryUtils.fetchSingleCategory(categoryId: Int64(items.category_id))
                categoryName = hkb_category!.title
            } else {
                categoryName = ""
            }
            
            if items.tag != nil {
                tags = items.tag!.replacingOccurrences(of: ",", with: " ")
            } else {
                tags = ""
            }
            
            if items.eventid != nil {
                eventId = String(items.eventid)
            }
            
            if items.vchcurrency != nil {
                currency = items.vchcurrency!
            }
            
            if items.eventname != nil {
                eventName = items.eventname!.replacingOccurrences(of: ",", with: " ")
            }
            
            if let vchUseCase = items.use_case {
                useCase = vchUseCase
            }
            
            guard let hkb_account = QueryUtils.fetchSingleAccount(accountId: Int64(items.account_id)) as Hkb_account? else {
                return ""
            }
            let accountName = hkb_account.title!.replacingOccurrences(of: ",", with: " ")
            date = items.created_on
            export += "\(vchAmount!) , \(description!) , \(date!) , \(vchType!) , \(useCase) , \(categoryName!) , \(accountName) , \(place) , \(fcamount) , \(String(describing: fcrate)) , \(String(describing: tags!)) , \(eventId) , \(currency) , \(eventName) \n"
            
        }
        
        return export
    }
    
    @IBAction func onIntervalTapped(_ sender: Any) {
        let intervalPopup = IntervalSelectionPopup()
        intervalPopup.delegate = self
        intervalPopup.providesPresentationContextTransitionStyle = true
        intervalPopup.definesPresentationContext = true
        intervalPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        intervalPopup.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(intervalPopup, animated: true, completion: nil)
    }
    
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        fetchIntervals()
        let controllers = getControllers()
        selectInitialIndex()
        configureSelectedTabView()
        return controllers
        
    }
    
}


extension ActivityPageViewController: IntervalListener {
    func onIntervalChanged(selectedInterval: String) {
        LocalPrefs.setCurrentInterval(currentInterval: selectedInterval)
        activityViewControllers.removeAll()
        self.reloadPagerTabStripView()
    }
}
