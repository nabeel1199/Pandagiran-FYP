
import UIKit

class ActivityViewCell: UITableViewCell {
    
    @IBOutlet weak var btn_menu: TintedButton!
    @IBOutlet weak var label_time: UILabel!
    @IBOutlet weak var stack_view_category: UIStackView!
    @IBOutlet weak var date_bg: UIView!
    @IBOutlet weak var date_bg_view: CardView!
    @IBOutlet weak var tv_category: UILabel!
    @IBOutlet var tv_day: UILabel!
    @IBOutlet var tv_date: UILabel!
    @IBOutlet weak var tv_description: UILabel!
    @IBOutlet weak var tv_year: UILabel!
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
   
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDay(day : String) {
        tv_day.text = day
    }
}
