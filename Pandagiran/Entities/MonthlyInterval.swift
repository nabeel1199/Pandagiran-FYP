

import Foundation

class MonthlyInterval {
    
    var month : String?
    var year : Int?
    var monthNumeric : Int?
    var yearNumeric : String?
    
    
    init() {
        
    }
    
    init(month : String , year : Int , monthNumeric : Int , yearNumeric : String) {
        self.month = month
        self.year = year
        self.monthNumeric = monthNumeric
        self.yearNumeric = yearNumeric
    }
}
