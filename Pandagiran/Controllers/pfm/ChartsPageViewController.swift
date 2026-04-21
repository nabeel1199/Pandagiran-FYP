

import UIKit
import XLPagerTabStrip
import SideMenu

class ChartsPageViewController: ButtonBarPagerTabStripViewController {
    
    var budgetInterval : String = LocalPrefs.getCurrentInterval()
    var noOfItem : Int = 4
    var monthlyArray : Array<MonthlyInterval> = []
    var currentInterval : String = LocalPrefs.getCurrentInterval()
    var quarterlyArray : Array<QuarterlyInterval> = []
    var halfYearlyArray : Array<HalfYearlyInterval> = []
    var yearlyArray : Array<Int> = []
    var categoryId : Int = 0
    var accountId : Int = 0
    var pagerIndex : Int = 0
    
    private var chartViewControllers : Array<UIViewController> = []
    
    
    
    override func viewDidLoad() {
        
        settings.style.buttonBarBackgroundColor = UIColor.clear
        settings.style.buttonBarItemBackgroundColor = UIColor.clear
        settings.style.selectedBarHeight = 0
        settings.style.buttonBarItemFont = UIFont(name: "Montserrat", size: 14.0)!
        
        super.viewDidLoad()

        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        chartViewControllers.removeAll()
        self.buttonBarView.layoutIfNeeded()
        self.reloadPagerTabStripView()

        (self.tabBarController as? TabBarViewController)?.popupAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        (self.tabBarController as? TabBarViewController)?.popupDisappear()
    }
    
    private func initUI () {
        self.addSideMenu()
        view.backgroundColor = Utils.hexStringToUIColor(hex: "#f9f9f9")
        self.navigationItem.title = "Insights"
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
    
    private func getChartsViewController () -> ChartDetailsViewController {
        let chartDetailsVC = UIUtils.getStoryboard(name: ViewIdentifiers.SB_CHARTS).instantiateViewController(withIdentifier: "ChartDetailsVC") as! ChartDetailsViewController
        return chartDetailsVC
    }
    
    private func getControllers () -> Array<UIViewController> {
        let interval = LocalPrefs.getCurrentInterval()
        if interval == Constants.MONTHLY {
            for i in 0 ..< monthlyArray.count {
                let chartsVC = getChartsViewController()
                chartsVC.month = String(monthlyArray[i].monthNumeric!)
                chartsVC.year = monthlyArray[i].year!
                chartsVC.tabTitle = monthlyArray[i].month!
                chartsVC.intervalIndex = i
                chartViewControllers.append(chartsVC)
            }
        } else if interval == Constants.HALF_YEARLY {
            for i in 0 ..< halfYearlyArray.count {
                let chartsVC = getChartsViewController()
                chartsVC.month = halfYearlyArray[i].months!
                chartsVC.year = halfYearlyArray[i].year!
                chartsVC.tabTitle = halfYearlyArray[i].monthRange!
                chartsVC.intervalIndex = i
                chartViewControllers.append(chartsVC)
            }
        } else if interval == Constants.QUARTERLY {
            
            for i in 0 ..< quarterlyArray.count {
                let chartsVC = getChartsViewController()
                chartsVC.month = quarterlyArray[i].monthRange!
                chartsVC.year = quarterlyArray[i].year!
                chartsVC.tabTitle = quarterlyArray[i].months!
                chartsVC.intervalIndex = i
                chartViewControllers.append(chartsVC)
            }
        } else if interval == Constants.YEARLY {
            for i in 0 ..< yearlyArray.count {
                let chartsVC = getChartsViewController()
                chartsVC.year = yearlyArray[i]
                chartsVC.tabTitle = String(yearlyArray[i])
                chartsVC.intervalIndex = i
                chartViewControllers.append(chartsVC)
            }
        } else {
            let chartsVC = getChartsViewController()
            chartsVC.tabTitle = Constants.ALL_TIME
            chartsVC.intervalIndex = 0
            chartViewControllers.append(chartsVC)
        }
        
        return chartViewControllers
    }
    
    @objc private func onBackTapped () {
        self.dismiss(animated: false, completion: nil)
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
        
        
        SideMenuManager.default.menuLeftNavigationController = menu
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    
    @objc private func onSideMenuTapped () {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
}

extension ChartsPageViewController: IntervalListener {

    func onIntervalChanged(selectedInterval: String) {
        LocalPrefs.setCurrentInterval(currentInterval: selectedInterval)
        chartViewControllers.removeAll()

        DispatchQueue.main.async {
            self.buttonBarView.layoutIfNeeded()
            self.reloadPagerTabStripView()
        }

    }


}

