

import Foundation

class HalfYearlyInterval {
    var monthRange : String?
    var months : String?
    var year : Int?
    
    
    init() {
        
    }
    
    init(monthRange : String , months : String , year : Int) {
        self.monthRange = monthRange
        self.months = months
        self.year = year
    }
}
