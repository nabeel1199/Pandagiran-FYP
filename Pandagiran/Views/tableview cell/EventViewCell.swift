

import UIKit

class EventViewCell: UITableViewCell {

    @IBOutlet weak var label_end_date: UILabel!
    @IBOutlet weak var label_end_date_heading: UILabel!
    @IBOutlet weak var label_start_date: UILabel!
    @IBOutlet weak var label_start_date_heading: UILabel!
    @IBOutlet weak var label_event_desc: UILabel!
    @IBOutlet weak var iv_event: CircularViewStroke!
    @IBOutlet weak var label_event_title: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        label_event_title.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_event_desc.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_start_date.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_start_date_heading.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_end_date_heading.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_end_date.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
    public func configureEventWithItem (event : Hkb_event) {
        let startDate = Utils.convertStringToDate(dateString: event.startdate!)
        let endDate = Utils.convertStringToDate(dateString: event.enddate!)
        
        label_event_title.text = event.name!
        label_event_desc.text = event.desc!
        label_start_date.text = Utils.currentDateUserFormat(date: startDate)
        label_end_date.text = Utils.currentDateUserFormat(date: endDate)
    }
    
}
