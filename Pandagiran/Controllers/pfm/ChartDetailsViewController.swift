

import UIKit
import Charts
import XLPagerTabStrip

class ChartDetailsViewController: BaseViewController {

    @IBOutlet weak var label_expense_amount: UILabel!
    @IBOutlet weak var label_income_amount: UILabel!
    @IBOutlet weak var table_view_income_expense: UITableView!
    @IBOutlet weak var bar_chart: BarChartView!
    @IBOutlet weak var label_no_income: UILabel!
    @IBOutlet weak var label_no_expense: UILabel!
    @IBOutlet var pie_chart: PieChartView!
    @IBOutlet var pie_chart_income: PieChartView!
    @IBOutlet weak var table_view_income: UITableView!
    @IBOutlet weak var table_view_expense: UITableView!
    @IBOutlet weak var iv_expense_placeholder: UIImageView!
    @IBOutlet weak var iv_income_placeholder: UIImageView!
    @IBOutlet weak var tableIncomeConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableExpenseConstraint: NSLayoutConstraint!
    
    var expenseLegendsArray = Array<Hkb_category>()
    var incomeLegendsArray = Array<Hkb_category>()
    var categoriesArray : Array<Hkb_category> = []
    var sum : Double = 0
    var percentage : Float = 0
    var totalAmount : Double = 0
    var lastContentOffset: CGFloat = 0
    private var incomeAmount : Double = 0
    private var expenseAmount : Double = 0
    
    // Class Variables
    var month : String = ""
    var currentInterval : String = Constants.MONTHLY
    var year : Int = Utils.getCurrentYear()
    var monthsRange : String = ""
    public var tabTitle = ""
    var pageIndex : Int = 0
    private let nibLegendName = "ChartLegendsViewCell"
    public var intervalIndex = 0

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        categoriesArray.removeAll()
        expenseLegendsArray.removeAll()
        incomeLegendsArray.removeAll()
        setupPieChart(pie_chart: pie_chart)
        populateChartData(type : Constants.EXPENSE, pie_chart: pie_chart)
        setupPieChart(pie_chart: pie_chart_income)
        populateChartData(type: Constants.INCOME, pie_chart: pie_chart_income)
        setPlaceHolders()
        populateBarChart()
        setDataCount()
        setIncomeAndExpenseAmount()
    }
    
    private func initVariables () {
        table_view_income.dataSource = self
        table_view_income.delegate = self
        
        table_view_expense.dataSource = self
        table_view_expense.delegate = self
        
        table_view_income_expense.dataSource = self
        table_view_income_expense.delegate = self
        
        registerNibs()
    }
    
    private func registerNibs () {
        let nibLegend = UINib(nibName: nibLegendName, bundle: nil)
        table_view_income.register(nibLegend, forCellReuseIdentifier: nibLegendName)
        table_view_expense.register(nibLegend, forCellReuseIdentifier: nibLegendName)
        table_view_income_expense.register(nibLegend, forCellReuseIdentifier: nibLegendName)
    }
    
    func setupPieChart (pie_chart : PieChartView) {
        pie_chart.chartDescription?.enabled = false
        pie_chart.legend.enabled = false
        pie_chart.entryLabelColor = .white
        pie_chart.drawEntryLabelsEnabled = false
        pie_chart.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        pie_chart.holeRadiusPercent = 0.7
        pie_chart.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    func populateChartData (type : String , pie_chart : PieChartView) {

        categoriesArray = QueryUtils.fetchCategories(type: type)
        
        var colorsArray : Array<UIColor> = []
        var pieChartData : [PieChartDataEntry] = []
        
        for i in 0 ..< categoriesArray.count {
            sum = ActivitiesDbUtils.getVoucherSumWithCategoryID(categoryId: categoriesArray[i].categoryId, type : type, currentInterval: LocalPrefs.getCurrentInterval(), month: month, year: year)
            
            if sum != 0 {
                if type == Constants.INCOME {
                    totalAmount = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.INCOME, currentInterval: LocalPrefs.getCurrentInterval(), month: month, year: year)
                    incomeLegendsArray.append(categoriesArray[i])
                } else {
                    totalAmount = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.EXPENSE, currentInterval: LocalPrefs.getCurrentInterval(), month: month, year: year)
                    expenseLegendsArray.append(categoriesArray[i])
                }
                
                if totalAmount != 0 {
                   percentage = Float(abs(sum) / totalAmount * 100)
                }
                
                colorsArray.append(Utils.hexStringToUIColor(hex: categoriesArray[i].box_color!))
                let chartData = PieChartDataEntry(value : Double(abs(percentage)))
                pieChartData.append(chartData)
                
            }
        }
        
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
        data.setValueTextColor(.white)
        
        pie_chart.data = data
        pie_chart.highlightValues(nil)
        self.table_view_income_expense.reloadData()
        self.table_view_expense.reloadData()
        self.table_view_income.reloadData()
    }
    
    private func fetchIncomeAndExpenseAmount () -> (Double, Double) {
        let income = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.INCOME, currentInterval: LocalPrefs.getCurrentInterval(), month: String(month) , year: year)
        let expense = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.EXPENSE, currentInterval: LocalPrefs.getCurrentInterval(), month: String(month), year: year)
        
        return (income , expense)
    }
    
    private func setIncomeAndExpenseAmount () {
        label_income_amount.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: incomeAmount, decimal: LocalPrefs.getDecimalFormat()))"
        label_expense_amount.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(expenseAmount), decimal: LocalPrefs.getDecimalFormat()))"
    }
    
    private func populateBarChart () {
        let xAxis = bar_chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 8)
        xAxis.valueFormatter = BarChartFormatter(labels: ["INCOME", "" , "", "EXPENSE"])
        xAxis.drawGridLinesEnabled = false
        xAxis.avoidFirstLastClippingEnabled = false
        xAxis.labelCount = 4
        
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        
        let leftAxis = bar_chart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 2
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        
    }
    
    private func setDataCount() {
        
        var xVals = Array<BarChartDataEntry>()
        
        (incomeAmount , expenseAmount) = fetchIncomeAndExpenseAmount()
        
        xVals.append(BarChartDataEntry(x: 0, y: incomeAmount))
        xVals.append(BarChartDataEntry(x: 1, y: 0))
        xVals.append(BarChartDataEntry(x: 2, y: 0))
        xVals.append(BarChartDataEntry(x: 3, y: abs(expenseAmount)))
        
        var set1: BarChartDataSet! = nil
        
        set1 = BarChartDataSet(values: xVals, label: "")
        set1.setColors(Utils.hexStringToUIColor(hex: AppColors.SECONDARY_COLOR),Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR))
        set1.values = xVals
        set1.drawValuesEnabled = true
        
        
        let data = BarChartData()
        data.addDataSet(set1)
        data.setDrawValues(false)
        data.barWidth = 0.3
        
        
        bar_chart.data = data
        bar_chart.chartDescription?.text = ""
        bar_chart.legend.enabled = false
        bar_chart.rightAxis.enabled = false
        bar_chart.animate(yAxisDuration: 0.8)
        bar_chart.animate(xAxisDuration: 0.8)
        bar_chart.drawBarShadowEnabled = false
        bar_chart.leftAxis.drawAxisLineEnabled = false
        
        table_view_income_expense.reloadData()
//        table_view_income.reloadData()
//        table_view_expense.reloadData()
        
    }
    
    func setPlaceHolders () {
        if expenseLegendsArray.count == 0 {
            iv_expense_placeholder.isHidden = false
            label_no_expense.isHidden = false
            pie_chart.isHidden = true
        } else {
            iv_expense_placeholder.isHidden = true
            label_no_expense.isHidden = true
            pie_chart.isHidden = false
        }
        
        if incomeLegendsArray.count == 0 {
            iv_income_placeholder.isHidden = false
            label_no_income.isHidden = false
            pie_chart_income.isHidden = true
        } else {
            iv_income_placeholder.isHidden = true
               label_no_income.isHidden = true
               pie_chart_income.isHidden = false
        }
    }
    
    private func navigateToActivitiesVC (vchType: String) {
        let acitivityPageVC = getStoryboard(name: ViewIdentifiers.SB_ACTIVITY).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ACTIVITY_PAGE) as! ActivityPageViewController
        acitivityPageVC.passedInterval = LocalPrefs.getCurrentInterval()
        acitivityPageVC.intervalIndex = self.intervalIndex
        acitivityPageVC.vchType = vchType
        self.navigationController?.pushViewController(acitivityPageVC, animated: true)
    }

    @IBAction func onIncomeBreakdownTapped(_ sender: Any) {
        navigateToActivitiesVC(vchType: Constants.INCOME)
    }
    
    
    @IBAction func onExpenseBreakdownTapped(_ sender: Any) {
        navigateToActivitiesVC(vchType: Constants.EXPENSE)
    }

}

extension ChartDetailsViewController : UITableViewDelegate , UITableViewDataSource, IndicatorInfoProvider {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == table_view_income_expense {
            return 2
        } else if tableView == table_view_income {
            return incomeLegendsArray.count
        } else {
            return expenseLegendsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: nibLegendName, for: indexPath) as! ChartLegendsViewCell
        
        if tableView == table_view_income_expense {
            cell.label_spent.isHidden = true
            if indexPath.row == 0 {
                cell.legend_title.text = "Income: \(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(incomeAmount), decimal: LocalPrefs.getDecimalFormat()))"
                cell.iv_legend.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            } else {
                cell.legend_title.text = "Expense: \(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(expenseAmount), decimal: LocalPrefs.getDecimalFormat()))"
                cell.iv_legend.tintColor = UIColor().hexCode(hex: Style.color.PRIMARY_COLOR)
            }
        }
            
        else if tableView == table_view_expense
            
        {
            //            DispatchQueue.main.async {
            //                self.tableExpenseConstraint.constant = self.table_view_expense.contentSize.height
            //            }
            
            let legend = expenseLegendsArray[indexPath.row]
            
            sum = ActivitiesDbUtils.getVoucherSumWithCategoryID(categoryId: legend.categoryId, type : Constants.EXPENSE, currentInterval: LocalPrefs.getCurrentInterval(), month: month, year: year)
            totalAmount = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.EXPENSE, currentInterval: LocalPrefs.getCurrentInterval(), month: month, year: year)
            
            if totalAmount != 0 {
                percentage = Float(abs(sum) / totalAmount * 100)
            }
            
            
            cell.legend_title.text = legend.title
            cell.label_spent.isHidden = false
            cell.iv_legend.tintColor = UIColor().hexCode(hex: legend.box_color!)
            cell.label_spent.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(sum), decimal: LocalPrefs.getDecimalFormat()))"
            //            cell.label_amount_spent.text = Utils.formatDecimalNumber(number: abs(sum), decimal: LocalPrefs.getDecimalFormat())
            //            cell.label_percentage_spent.text = "\(Utils.formatDecimalNumber(number: Double(abs(percentage)), decimal: 2)) %"
            
            
        }
            
        else
            
        {
            //            DispatchQueue.main.async {
            //                self.tableIncomeConstraint.constant = self.table_view_income.contentSize.height
            //            }
            
            
            let legend = incomeLegendsArray[indexPath.row]
            sum = ActivitiesDbUtils.getVoucherSumWithCategoryID(categoryId: legend.categoryId , type : Constants.INCOME, currentInterval: LocalPrefs.getCurrentInterval(), month: month, year: year)
            totalAmount = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.INCOME, currentInterval: LocalPrefs.getCurrentInterval(), month: month, year: year)
            
            if totalAmount != 0 {
                percentage = Float(abs(sum) / totalAmount * 100)
            }
            
            cell.legend_title.text = legend.title
            cell.label_spent.isHidden = false
            cell.iv_legend.tintColor = UIColor().hexCode(hex: legend.box_color!)
            cell.label_spent.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(sum), decimal: LocalPrefs.getDecimalFormat()))"
            
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let dest = UIUtils.getStoryboard().instantiateViewController(withIdentifier: "CategoryDetailsVC") as! CategoryDetailsViewController
        //        dest.month = month
        //        dest.year = year
        //
        //        if tableView == table_view_expense {
        //           dest.categoryId = Int(expenseLegendsArray[indexPath.row].categoryId)
        //        } else {
        //            dest.categoryId = Int(incomeLegendsArray[indexPath.row].categoryId)
        //        }
        //
        //        self.navigationController?.pushViewController(dest, animated: true)
        
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabTitle)
    }
}

extension ChartDetailsViewController {
    private class BarChartFormatter: NSObject, IAxisValueFormatter {
        
        var labels: [String] = []
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let index = Int(value)
            if index < labels.count && index >= 0 {
                return labels[index]
            } else {
                return ""
            }
        }
        
        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }
}
