

import Foundation

class TimeIntervalUtils {
    
    static var currentMonth = Utils.getCurrentMonth()
    static var currentYear = Utils.getCurrentYear()
    
    static func getMonthlyInterval  () -> Array<MonthlyInterval> {
        var monthlyArray : Array<MonthlyInterval> = []
        
        
        for i in (-1 ... 11).reversed() {
            let date = Calendar.current.date(byAdding: .month, value: -i, to: Date()) ?? Date()
            
            let dateString = Utils.currentDateDbFormat(date: date)
            let month = Utils.getDayMonthAndYear(givenDate: dateString, dayMonthOrYear: "month")
            let year = Utils.getDayMonthAndYear(givenDate: dateString, dayMonthOrYear: "year")
            
            let monthlyInterval = MonthlyInterval()
            monthlyInterval.month = "\(Utils.getMonthFromInt(num: Int(month - 1))) \(year)"
            monthlyInterval.year = Int(year)
            monthlyInterval.monthNumeric = Int(month)
            monthlyArray.append(monthlyInterval)
        }
        
        return monthlyArray
    }
    
    static func getHalfYearlyInterval () -> Array<HalfYearlyInterval> {
        var halfYearlyArray: Array<HalfYearlyInterval> = []
        if currentMonth >= 0 && currentMonth < 7 {
            var halfYearlyInterval = HalfYearlyInterval()
            halfYearlyInterval.monthRange = "Jul-Dec \(currentYear - 1)"
            halfYearlyInterval.months = "6-12"
            halfYearlyInterval.year = currentYear - 1
            halfYearlyArray.append(halfYearlyInterval)
            
            halfYearlyInterval = HalfYearlyInterval()
            halfYearlyInterval.monthRange = "Jan-Jun \(currentYear)"
            halfYearlyInterval.months = "1-6"
            halfYearlyInterval.year = currentYear
            halfYearlyArray.append(halfYearlyInterval)
            
            halfYearlyInterval = HalfYearlyInterval()
            halfYearlyInterval.monthRange = "Jul-Dec \(currentYear)"
            halfYearlyInterval.months = "6-12"
            halfYearlyInterval.year = currentYear
            halfYearlyArray.append(halfYearlyInterval)
        } else if (currentMonth > 6 && currentMonth <= 12) {
            var halfYearlyInterval = HalfYearlyInterval()
            halfYearlyInterval.monthRange = "Jan-Jun \(currentYear)"
            halfYearlyInterval.months = "1-6"
            halfYearlyInterval.year = currentYear
            halfYearlyArray.append(halfYearlyInterval)
            
            halfYearlyInterval = HalfYearlyInterval()
            halfYearlyInterval.monthRange = "Jul-Dec \(currentYear)"
            halfYearlyInterval.months = "7-12"
            halfYearlyInterval.year = currentYear
            halfYearlyArray.append(halfYearlyInterval)
            
            halfYearlyInterval = HalfYearlyInterval()
            halfYearlyInterval.monthRange = "Jan-Jun '\(currentYear + 1)"
            halfYearlyInterval.months = "1-6"
            halfYearlyInterval.year = currentYear + 1
            halfYearlyArray.append(halfYearlyInterval)
        }
        
        return halfYearlyArray
    }
    
    static func getQuarterlyInterval() -> Array<QuarterlyInterval> {
        var quarterlyArray: Array<QuarterlyInterval> = []
        
        if currentMonth > 0 && currentMonth < 4 {
            var quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "7-9"
            quarterlyInterval.months = "Jul-Sep \(currentYear - 1)"
            quarterlyInterval.year = currentYear - 1
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "10-12"
            quarterlyInterval.months = "Oct-Dec \(currentYear - 1)"
            quarterlyInterval.year = currentYear - 1
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "1-3"
            quarterlyInterval.months = "Jan-Mar \(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "4-6"
            quarterlyInterval.months = "Apr-Jun \(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
        } else if currentMonth > 3 && currentMonth < 7 {
            var quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "10-12"
            quarterlyInterval.months = "Oct-Dec \(currentYear - 1)"
            quarterlyInterval.year = currentYear - 1
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "1-3"
            quarterlyInterval.months = "Jan-Mar \(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "4-6"
            quarterlyInterval.months = "Apr-Jun \(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "7-9"
            quarterlyInterval.months = "Jul-Sep \(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
        } else if currentMonth > 6 && currentMonth < 10 {
            var quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "1-3"
            quarterlyInterval.months = "Jan-Mar '\(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "4-6"
            quarterlyInterval.months = "Apr-Jun \(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "7-9"
            quarterlyInterval.months = "Jul-Sep \(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "10-12"
            quarterlyInterval.months = "Oct-Dec \(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
        } else if currentMonth > 9 && currentMonth <= 12 {
            var quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "4-6"
            quarterlyInterval.months = "Apr-Jun \(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "7-9"
            quarterlyInterval.months = "Jul-Sep \(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "10-12"
            quarterlyInterval.months = "Oct-Dec \(currentYear)"
            quarterlyInterval.year = currentYear
            quarterlyArray.append(quarterlyInterval)
            
            quarterlyInterval = QuarterlyInterval()
            quarterlyInterval.monthRange = "1-3"
            quarterlyInterval.months = "Jan-Mar \(currentYear + 1)"
            quarterlyInterval.year = currentYear + 1
            quarterlyArray.append(quarterlyInterval)
        }
        
        return quarterlyArray
    }
    
    static func getYearlyInterval() -> Array<Int> {
        var yearlyArray : Array<Int> = []
        yearlyArray.append(currentYear - 1)
        yearlyArray.append(currentYear)
        yearlyArray.append(currentYear + 1)
        return yearlyArray
    }
}
