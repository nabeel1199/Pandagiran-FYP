

import Foundation

class CellData {
    var cell : Int?
    var text : String?
    var icon : UIImage?
    var tag : String?
    
    init(cell : Int , text : String , icon : UIImage, tag: String) {
        self.cell = cell
        self.text = text
        self.icon = icon
        self.tag = tag
    }
}
