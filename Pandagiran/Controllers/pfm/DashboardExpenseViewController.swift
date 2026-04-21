

import UIKit
import Charts

class DashboardExpenseViewController: BaseViewController {
    
    
    @IBOutlet weak var view_create_expense: UILabel!
    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var table_view_legends: UITableView!
    @IBOutlet weak var pie_chart: PieChartView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    private var arrayOfLegends = ["Grocery", "Eating out", "Medical"]
    private let nibChartLegends = "ChartLegendsViewCell"
    private var colorsArray : Array<UIColor> = []
    private var arrayOfCategories : Array<Hkb_category> = []
    private var sum : Double = 0
    private var totalAmount : Double = 0
    private var expenseLegendsArray = Array<Hkb_category>()
    private var percentage: Float?
    private let month = Utils.getCurrentMonth()
    private let year = Utils.getCurrentYear()

    
    
    override func viewWillAppear(_ animated: Bool) {
        
        populateChartData(type: Constants.EXPENSE, pie_chart: pie_chart)
        showPlaceholder()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        initNibs()
        initUI()
        
        
    }
    
    private func initNibs () {
        let nib = UINib(nibName: nibChartLegends, bundle: nil)
        table_view_legends.register(nib, forCellReuseIdentifier: nibChartLegends)
        
        table_view_legends.delegate = self
        table_view_legends.dataSource = self
    }
    
    private func initUI () {
        self.viewBackgroundColor = .white
        
        let addExpenseGest = UITapGestureRecognizer(target: self, action: #selector(onCreateTapped))
        view_create_expense.addGestureRecognizer(addExpenseGest)
    }
    
    private func populateChartData (type : String , pie_chart : PieChartView) {
        expenseLegendsArray.removeAll()
        colorsArray.removeAll()
        arrayOfCategories = QueryUtils.fetchCategories(type: type)
        
        var pieChartData : [PieChartDataEntry] = []
        
        for i in 0 ..< arrayOfCategories.count {
            sum = ActivitiesDbUtils.getVoucherSumWithCategoryID(categoryId: arrayOfCategories[i].categoryId, type : type, currentInterval: Constants.MONTHLY, month: String(month), year: year)
            
            if sum != 0 {
                totalAmount = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.EXPENSE, currentInterval: Constants.MONTHLY, month: String(month), year: year)
                
                colorsArray.append(Utils.hexStringToUIColor(hex: arrayOfCategories[i].box_color!))
                expenseLegendsArray.append(arrayOfCategories[i])
                
                percentage = Float(abs(sum) / totalAmount * 100)
            
                let chartData = PieChartDataEntry(value : Double(abs(percentage!)))
                pieChartData.append(chartData)
            }
        }
        
        self.table_view_legends.reloadData()
        
        let set = PieChartDataSet(values: pieChartData, label: "")
        set.drawIconsEnabled = false
        set.sliceSpace = 0
        set.drawValuesEnabled = false
        set.colors = colorsArray
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.black)
        
        pie_chart.data = data
        pie_chart.chartDescription?.enabled = false
        pie_chart.legend.enabled = false
        pie_chart.animate(xAxisDuration: 0.5)
        pie_chart.highlightValues(nil)
    }
    
    private func showPlaceholder () {
        if expenseLegendsArray.count == 0 {
            view_placeholder.isHidden = false
        } else {
            view_placeholder.isHidden = true
        }
    }
    
    @objc private func onCreateTapped () {
        let addExpenseVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: ViewIdentifiers.VC_TRANSACTION_LOGGING) as! TransactionLoggingViewController
        let navController = UINavigationController()
        navController.viewControllers = [addExpenseVC]
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func onViewAllTapped(_ sender: Any) {
        let activitiesVC = getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACTIVITY_PAGE) as! ActivityPageViewController
        let intervalIndex = Utils.getInitialIntervalIndex(currentInterval: Constants.MONTHLY)
        activitiesVC.intervalIndex = intervalIndex
        self.navigationController?.pushViewController(activitiesVC, animated: true)
    }
    
}

extension DashboardExpenseViewController : UITableViewDelegate, UITableViewDataSource {
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
//        if table_view_legends.contentSize.height < 130 {
//            self.tableHeight.constant = table_view_legends.contentSize.height
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseLegendsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibChartLegends, for: indexPath) as! ChartLegendsViewCell
        
        sum = ActivitiesDbUtils.getVoucherSumWithCategoryID(categoryId: expenseLegendsArray[indexPath.row].categoryId, type : Constants.EXPENSE, currentInterval: Constants.MONTHLY, month: String(month), year: year)
        totalAmount = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.EXPENSE, currentInterval: Constants.MONTHLY, month: String(month), year: year)
        percentage = Float(abs(sum) / totalAmount * 100)
        
        cell.legend_title.text = "\(expenseLegendsArray[indexPath.row].title!)"
        cell.iv_legend.tintColor = colorsArray[indexPath.row]
        cell.label_spent.isHidden = false
        cell.label_spent.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(sum), decimal: LocalPrefs.getDecimalFormat()))"
        
        cell.selectionStyle = .none
        return cell
    }
    
}
