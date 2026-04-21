

import UIKit
import Charts

class DashboardIncomeViewController: BaseViewController {

    @IBOutlet weak var view_add_income: UILabel!
    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var bar_chart: BarChartView!
    @IBOutlet weak var table_view_legends: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    private let nibChartLegends = "ChartLegendsViewCell"
    private var incomeAmount : Double = 0
    private var expenseAmount : Double = 0
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        populateChart()
        setDataCount()
        showPlaceholder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()


    }
    
    private func initVariables () {
        initNibs()
    }
    
    private func initNibs () {
        let nib = UINib(nibName: nibChartLegends, bundle: nil)
        table_view_legends.register(nib, forCellReuseIdentifier: nibChartLegends)
        
        table_view_legends.delegate = self
        table_view_legends.dataSource = self
    }
    
    private func initUI () {
        self.viewBackgroundColor = .white
        
        let addIncomeGest = UITapGestureRecognizer(target: self, action: #selector(onAddIncomeTapped))
        view_add_income.addGestureRecognizer(addIncomeGest)
    }
    
    private func fetchIncomeAndExpenseAmount () -> (Double, Double) {
        let month = Utils.getCurrentMonth()
        let year = Utils.getCurrentYear()
        let income = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.INCOME, currentInterval: Constants.MONTHLY, month: String(month) , year: year)
        let expense = ActivitiesDbUtils.getTotalIncomeAndExpense(vchType: Constants.EXPENSE, currentInterval: Constants.MONTHLY, month: String(month), year: year)
        
        return (income , expense)
    }
    
    private func populateChart () {
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
        
        table_view_legends.reloadData()
        
    }
    
    private func showPlaceholder () {
        if incomeAmount == 0 {
            view_placeholder.isHidden = false
            table_view_legends.isHidden = true
            bar_chart.isHidden = true
        } else {
            view_placeholder.isHidden = true
            table_view_legends.isHidden = false
            bar_chart.isHidden = false
        }
    }
    
    @objc private func onAddIncomeTapped () {
        let transactionVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: "TransactionLoggingVC") as! TransactionLoggingViewController
        transactionVC.isExpense = 0
        transactionVC.vchType = Constants.INCOME
        let navController = UINavigationController()
        navController.viewControllers = [transactionVC]
        self.present(navController, animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        self.updateViewConstraints()
//        self.tableHeight.constant = table_view_legends.contentSize.height
    }
}

extension DashboardIncomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibChartLegends, for: indexPath) as! ChartLegendsViewCell
        
        if indexPath.row == 0 {
            cell.legend_title.text = "Expense: \(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(expenseAmount), decimal: 0))"
            cell.iv_legend.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        } else {
            cell.legend_title.text = "Income: \(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(incomeAmount), decimal: 0))"
            cell.iv_legend.tintColor = UIColor().hexCode(hex: Style.color.PRIMARY_COLOR)
        }
        
        self.viewWillLayoutSubviews()
        cell.selectionStyle = .none
        
        return cell
    }
}

extension DashboardIncomeViewController {
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
