

import UIKit
import XLPagerTabStrip
import SideMenu

class PfmLandingPageViewController: ButtonBarPagerTabStripViewController {

    private var currentInterval : String = Constants.MONTHLY
    private var quarterlyArray : Array<QuarterlyInterval> = []
    private var halfYearlyArray : Array<HalfYearlyInterval> = []
    private var monthlyArray : Array<MonthlyInterval> = []
    private var yearlyArray : Array<Int> = []
    private var pfmViewControllers : Array<UIViewController> = []
    private var menu_button = UIBarButtonItem()
    

    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = UIColor.clear
        settings.style.buttonBarItemBackgroundColor = UIColor.clear
        settings.style.selectedBarHeight = 0
        settings.style.buttonBarItemFont = UIFont(name: "Montserrat", size: 14.0)!
        
        super.viewDidLoad()
        
    
        initUI()
//        self.configureSelectedTabView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.pfmViewControllers.removeAll()
        self.buttonBarView.layoutIfNeeded()
        self.reloadPagerTabStripView()
        print("Current interval on money screen is: \(LocalPrefs.getCurrentInterval())")
        (self.tabBarController as? TabBarViewController)?.popupAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        (self.tabBarController as? TabBarViewController)?.popupDisappear()
    }
    
    
    
    private func initUI () {
        self.addSideMenu()
        view.backgroundColor = Utils.hexStringToUIColor(hex: "#f9f9f9")
        self.navigationItem.title = "Money"
        //
        buttonBarView.frame.size = CGSize(width: self.view.frame.width - 50, height: 50.0)
        buttonBarView.selectedBar.backgroundColor = UIColor.white
        
        buttonBarView.backgroundColor = UIColor.clear

    }
    
    private func selectInitialIndex () {
        DispatchQueue.main.async {
            self.moveToViewController(at: Utils.getInitialIntervalIndex(currentInterval: LocalPrefs.getCurrentInterval()), animated: false)
        }
        
    }
    
    private func fetchIntervals () {
        monthlyArray = TimeIntervalUtils.getMonthlyInterval()
        quarterlyArray = TimeIntervalUtils.getQuarterlyInterval()
        halfYearlyArray = TimeIntervalUtils.getHalfYearlyInterval()
        yearlyArray = TimeIntervalUtils.getYearlyInterval()
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
    
    @IBAction func onBtnIntervalTapped(_ sender: Any) {
        let intervalPopup = IntervalSelectionPopup()
        intervalPopup.delegate = self
        intervalPopup.providesPresentationContextTransitionStyle = true
        intervalPopup.definesPresentationContext = true
        intervalPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        intervalPopup.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(intervalPopup, animated: true, completion: nil)
    }
    
    private func getPfmController () -> PfmLandingViewController {
        let pfmVC = UIUtils.getStoryboard(name: ViewIdentifiers.SB_PFM).instantiateViewController(withIdentifier: ViewIdentifiers.VC_PFM_LANDING) as! PfmLandingViewController
        return pfmVC
    }
    
    private func getControllers () -> Array<UIViewController> {
        let interval = LocalPrefs.getCurrentInterval()
        if interval == Constants.MONTHLY {
            for i in 0 ..< monthlyArray.count {
                let pfmVC = getPfmController()
                pfmVC.month = String(monthlyArray[i].monthNumeric!)
                pfmVC.intervalIndex = i
                pfmVC.year = monthlyArray[i].year!
                pfmVC.tabTitle = monthlyArray[i].month!
                pfmViewControllers.append(pfmVC)
            }
        } else if interval == Constants.HALF_YEARLY {
            for i in 0 ..< halfYearlyArray.count {
                let pfmVC = getPfmController()
                pfmVC.month = halfYearlyArray[i].months!
                pfmVC.intervalIndex = i
                pfmVC.year = halfYearlyArray[i].year!
                pfmVC.tabTitle = halfYearlyArray[i].monthRange!
                pfmViewControllers.append(pfmVC)
            }
        } else if interval == Constants.QUARTERLY {
            
            for i in 0 ..< quarterlyArray.count {
                let pfmVC = getPfmController()
                pfmVC.month = quarterlyArray[i].monthRange!
                pfmVC.intervalIndex = i
                pfmVC.year = quarterlyArray[i].year!
                pfmVC.tabTitle = quarterlyArray[i].months!
                pfmViewControllers.append(pfmVC)
            }
        } else if interval == Constants.YEARLY {
            for i in 0 ..< yearlyArray.count {
                let pfmVC = getPfmController()
                pfmVC.year = yearlyArray[i]
                pfmVC.intervalIndex = i
                pfmVC.tabTitle = String(yearlyArray[i])
                pfmViewControllers.append(pfmVC)
            }
        } else {
            let pfmVC = getPfmController()
            pfmVC.tabTitle = Constants.ALL_TIME
            pfmVC.intervalIndex = 0
            pfmViewControllers.append(pfmVC)
        }
        
        return pfmViewControllers
    }
    
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        fetchIntervals()
        let pfmControllers = getControllers()
        selectInitialIndex()
        configureSelectedTabView()
        return pfmControllers
    }
    
    public func addSideMenu () {
        let menuButton = UIBarButtonItem(image: UIImage(named: "drawer_icon"), style: .plain, target: self, action: #selector(onSideMenuTapped))
        self.navigationItem.leftBarButtonItem = menuButton
        
        let sideMenu = UIUtils.getStoryboard(name: ViewIdentifiers.SB_MAIN).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SIDE_MENU)
        let menu = UISideMenuNavigationController(rootViewController: sideMenu)
        
        
        
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuLeftNavigationController = menu
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    
    @objc private func onSideMenuTapped () {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
}

extension PfmLandingPageViewController: IntervalListener {
    func onIntervalChanged(selectedInterval: String) {
        DispatchQueue.main.async {
        LocalPrefs.setCurrentInterval(currentInterval: selectedInterval)
        
            self.pfmViewControllers.removeAll()
        

            self.reloadPagerTabStripView()
        }
    }
    
    
}
