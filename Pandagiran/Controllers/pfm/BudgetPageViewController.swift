

import UIKit
import XLPagerTabStrip

class BudgetPageViewController: ButtonBarPagerTabStripViewController {

    private var currentInterval : String = Constants.MONTHLY
    private var quarterlyArray : Array<QuarterlyInterval> = []
    private var halfYearlyArray : Array<HalfYearlyInterval> = []
    private var monthlyArray : Array<MonthlyInterval> = []
    private var yearlyArray : Array<Int> = []
    private var budgetViewControllers : Array<UIViewController> = []
    
     public var intervalIndex = 0
    
    
    override func viewDidAppear(_ animated: Bool) {
      
    }
    
    override func viewDidLoad() {
        configureTabViews()
        super.viewDidLoad()

        
        initUI()
        selectInitialIndex()
    }
    
    private func initUI () {
        view.backgroundColor = Utils.hexStringToUIColor(hex: "#f9f9f9")
        self.navigationItem.title = "Budgets"
//
        buttonBarView.frame.size = CGSize(width: self.view.frame.width, height: 50)
        buttonBarView.selectedBar.backgroundColor = UIColor.white
        buttonBarView.backgroundColor = UIColor.clear
    }
    
    private func selectInitialIndex () {
        DispatchQueue.main.async {
            self.moveToViewController(at: Utils.getInitialIntervalIndex(currentInterval: Constants.MONTHLY), animated: false)
            self.reloadPagerTabStripView()
            self.changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
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
    }
    
    private func fetchIntervals () {
        monthlyArray = TimeIntervalUtils.getMonthlyInterval()
        quarterlyArray = TimeIntervalUtils.getQuarterlyInterval()
        halfYearlyArray = TimeIntervalUtils.getHalfYearlyInterval()
        yearlyArray = TimeIntervalUtils.getYearlyInterval()
    }
    
    private func configureTabViews () {
        settings.style.buttonBarBackgroundColor = UIColor.clear
        settings.style.buttonBarItemBackgroundColor = UIColor.clear
        settings.style.selectedBarHeight = 0
        settings.style.buttonBarItemFont = UIFont(name: "Montserrat", size: 14.0)!
    }
    
    private func getBudgetViewController () -> BudgetViewController {
        let budgetVC = UIUtils.getStoryboard(name: ViewIdentifiers.SB_BUDGET).instantiateViewController(withIdentifier: ViewIdentifiers.VC_BUDGET) as! BudgetViewController
        return budgetVC
    }
    
    private func getControllers () -> Array<UIViewController> {
        let interval = Constants.MONTHLY
        if interval == Constants.MONTHLY {
            for i in 0 ..< monthlyArray.count {
                let budgetVC = getBudgetViewController()
                budgetViewControllers.append(budgetVC)
                budgetVC.month = String(describing: monthlyArray[i].monthNumeric!)
                budgetVC.intervalIndex = i
                budgetVC.year = monthlyArray[i].year!
                budgetVC.tabTitle = monthlyArray[i].month!
            }
        } else if interval == Constants.HALF_YEARLY {
            for i in 0 ..< halfYearlyArray.count {
                let budgetVC = getBudgetViewController()
                budgetViewControllers.append(budgetVC)
                budgetVC.month = halfYearlyArray[i].months!
                budgetVC.intervalIndex = i
                budgetVC.year = halfYearlyArray[i].year!
                budgetVC.tabTitle = halfYearlyArray[i].monthRange!
            }
        } else if interval == Constants.QUARTERLY {
            
            for i in 0 ..< quarterlyArray.count {
                let budgetVC = getBudgetViewController()
                budgetViewControllers.append(budgetVC)
                budgetVC.month = quarterlyArray[i].monthRange!
                budgetVC.intervalIndex = i
                budgetVC.year = quarterlyArray[i].year!
                budgetVC.tabTitle = quarterlyArray[i].months!
            }
        } else if interval == Constants.YEARLY {
            for i in 0 ..< yearlyArray.count {
                let budgetVC = getBudgetViewController()
                budgetViewControllers.append(budgetVC)
                budgetVC.intervalIndex = i
                budgetVC.year = yearlyArray[i]
                budgetVC.tabTitle = String(yearlyArray[i])
            }
        } else {
            let budgetVC = getBudgetViewController()
            budgetViewControllers.append(budgetVC)
            budgetVC.intervalIndex = 0
            budgetVC.tabTitle = Constants.ALL_TIME
        }
        
        return budgetViewControllers
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
    
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        self.budgetViewControllers.removeAll()
        fetchIntervals()
        let budgetViewControllers = getControllers()
        return budgetViewControllers
    }

}

extension BudgetPageViewController : IntervalListener {
    
    func onIntervalChanged(selectedInterval: String) {
        LocalPrefs.setCurrentInterval(currentInterval: selectedInterval)
        budgetViewControllers.removeAll()
        reloadPagerTabStripView()
        
        selectInitialIndex()
    }
    
    
}
