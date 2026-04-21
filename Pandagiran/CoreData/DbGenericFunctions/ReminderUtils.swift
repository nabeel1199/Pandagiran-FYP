
import Foundation
import CoreData

class ReminderUtils {
    
    static func fetchAllReminders () -> Array<Hkb_reminder> {
            var arrayOfReminders : Array <Hkb_reminder> = []
            let fetchRequest : NSFetchRequest<Hkb_reminder> = Hkb_reminder.fetchRequest()
            let sort = NSSortDescriptor(key: #keyPath(Hkb_reminder.reminderId), ascending: false)
            fetchRequest.sortDescriptors = [sort]
            let activePredicate = Predicates.activePredicate()
            fetchRequest.predicate = activePredicate
            
            do {
                let reminders = try DbController.getContext().fetch(fetchRequest)
                
                for reminder in reminders as [Hkb_reminder]{
                    arrayOfReminders.append(reminder)
                }
            } catch {
                print("Error : " , error)
            }
            
            return arrayOfReminders
        }
    
    static func fetchReminderCountByDate (date : String) -> Int {
        var a : Int = 0
        let fetchRequest : NSFetchRequest<Hkb_reminder> = Hkb_reminder.fetchRequest()
        let activePredicate = Predicates.activePredicate()
        let datePredicate = NSPredicate(format: "rmdate contains[c] %@", date)
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [activePredicate , datePredicate])
        
        do {
            a = try DbController.getContext().count(for: fetchRequest)
            print(" Here is the count : " , a)
        } catch {
            print("error is" , error)
        }
        
        return a
    }
}
