

import Foundation
import CoreData

class NotificationDbUtils {
    
    public static func fetchNotification (categoryId : Int64 , message : String , month : String , year : String) -> Array<Hkb_notifications> {
        var arrayOfNotifications : Array<Hkb_notifications> = []
        let fetchRequest : NSFetchRequest<Hkb_notifications> = Hkb_notifications.fetchRequest()
        fetchRequest.fetchLimit = 1
        let categorIdPredicate = NSPredicate(format: "categoryId = %i", categoryId)
        let messagePredicate = NSPredicate(format: "flex1 = %@", message)
        let monthPredicate = NSPredicate(format: "month = %@", month)
        let yearPredicate = NSPredicate(format : "year = %@" , year)
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [categorIdPredicate , messagePredicate , monthPredicate , yearPredicate])
        
        do {
            let notifications = try DbController.getContext().fetch(fetchRequest)
            
            for notification in notifications as [Hkb_notifications] {
                arrayOfNotifications.append(notification)
            }
        } catch {
            print("Error : " , error)
        }
        
        return arrayOfNotifications
    }
}
