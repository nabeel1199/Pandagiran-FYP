

import UIKit
import Charts

class BudgetAnalysisViewController: UIViewController {

    @IBOutlet weak var iv_category: UIImageView!
    @IBOutlet weak var label_category_title: UILabel!
    @IBOutlet weak var label_expense_amount: UILabel!
    @IBOutlet weak var bar_chart: BarChartView!
    @IBOutlet weak var view_category_bg: CircularView!
    
    public var category_id: Int64 = 0
    public var categoryTitle = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        populateChart(months: populateMonths())
        setDataCount()
    }
    
    private func initUI () {
        self.navigationItem.title = "Budget Analysis"
        let category = QueryUtils.fetchSingleCategory(categoryId: Int64(category_id))
        categoryTitle = category?.title ?? Constants.NULL_TEXT
        label_category_title.text = categoryTitle
        iv_category.image = UIImage(named: category?.box_icon ?? "ic_clear")
        view_category_bg.backgroundColor = Utils.hexStringToUIColor(hex: category?.box_color! ?? Constants.DEFAULT_COLOR)
        label_expense_amount.isHidden = true
    }
    
    private func populateMonths () -> Array<String> {
        var previousValue = -5
        var monthsArray = Array<String>()
        
        for i in 0 ... 5 {
            var date = Date()
            date = Calendar.current.date(byAdding: .month, value: previousValue, to: date)!
            let month = Utils.getDayMonthAndYear(givenDate: Utils.currentDateDbFormat(date: date), dayMonthOrYear: "month")
            let year = Utils.getDayMonthAndYear(givenDate: Utils.currentDateDbFormat(date: date), dayMonthOrYear: "year")
            monthsArray.append("\(Utils.getMonthFromInt(num: Int(month - 1))) \(year)")
            
            previousValue += 1
        }
        
        return monthsArray
    }
    
    private func populateChart (months : Array<String>) {
        let xAxis = bar_chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.valueFormatter = BarChartFormatter(labels: months)
        xAxis.drawGridLinesEnabled = false
        xAxis.avoidFirstLastClippingEnabled = false
//        xAxis.axisMaximum = 6.5
        xAxis.setLabelCount(7, force: true)
        
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        //        leftAxisFormatter.negativeSuffix = " $"
        //        leftAxisFormatter.positiveSuffix = " $"dw
        let leftAxis = bar_chart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        
        let l = bar_chart.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4
    }
    
    private func setDataCount() {
        let count = 6
        var previousValue = -5
        var budgetValue: Double = 0
        var xVals = Array<BarChartDataEntry>()
        var yVals = Array<BarChartDataEntry>()
      
        for i in 1 ... count {
            var date = Date()
            date = Calendar.current.date(byAdding: .month, value: previousValue, to: date)!
            let month = Utils.getDayMonthAndYear(givenDate: Utils.currentDateDbFormat(date: date), dayMonthOrYear: "month")
            let year = Utils.getDayMonthAndYear(givenDate: Utils.currentDateDbFormat(date: date), dayMonthOrYear: "year")
            
            let hkb_budget = BudgetDbUtils.fetchSingleBudget(categoryId: category_id, month: Int(month), year: Int(year))
            let spentAmount = BudgetDbUtils.fetchAmountSpent(categoryId: category_id, currentInterval: Constants.MONTHLY, month: String(month), year: Int(year))
            
            if hkb_budget?.budgetvalue != nil {
                budgetValue = (hkb_budget?.budgetvalue)!
            }
            xVals.append(BarChartDataEntry(x: Double(i), y: abs(spentAmount)))
            yVals.append(BarChartDataEntry(x: Double(i), y: budgetValue))
//            bar_chart.barData?.addEntry(BarChartDataEntry(x: budgetValue, y: spentAmount), dataSetIndex: i)
            previousValue += 1
            print("AMOUNT :  " , date)
        }
        
        var set1: BarChartDataSet! = nil
        var set2: BarChartDataSet! = nil

        set1 = BarChartDataSet(values: xVals, label: "Amount spent on \(categoryTitle)")
        set1.setColor(UIColor.red)
        set1.values = xVals
        set1.drawValuesEnabled = true
        set2 = BarChartDataSet(values: yVals, label: "Budgets allocated")
        set2.setColor(UIColor.green)
        set2.values = yVals
        set2.drawValuesEnabled = true
        
        let data = BarChartData()
        data.addDataSet(set1)
        data.addDataSet(set2)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.barWidth = 0.3
        bar_chart.data = data
        bar_chart.chartDescription?.text = ""
        bar_chart.rightAxis.enabled = false
        bar_chart.animate(yAxisDuration: 0.8)
        bar_chart.animate(xAxisDuration: 0.8)
        bar_chart.drawBarShadowEnabled = false
        bar_chart.xAxis.axisMinimum = 0.5
        bar_chart.drawValueAboveBarEnabled = true
        bar_chart.fitScreen()
        
        bar_chart.groupBars(fromX: 0.3, groupSpace: 0.5, barSpace: 0.0)
    }
}

extension BudgetAnalysisViewController {
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

