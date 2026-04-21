

import Foundation
import CoreData

struct EventsResponseData : Codable {
    let active : Int?
    let enddate : String?
    let name : String?
    let desc : String?
    let startdate : String?
    let eventid : Int64?
    let flex1 : String?

    enum CodingKeys: String, CodingKey {

        case active = "active"
        case enddate = "enddate"
        case name = "name"
        case desc = "desc"
        case startdate = "startdate"
        case eventid = "eventid"
        case flex1 = "flex1"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        active = try values.decodeIfPresent(Int.self, forKey: .active)
        enddate = try values.decodeIfPresent(String.self, forKey: .enddate)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        desc = try values.decodeIfPresent(String.self, forKey: .desc)
        startdate = try values.decodeIfPresent(String.self, forKey: .startdate)
        eventid = try values.decodeIfPresent(Int64.self, forKey: .eventid)
        flex1 = try values.decodeIfPresent(String.self, forKey: .flex1)
        self.maptoDBModel()
    }

}
extension EventsResponseData{
    func maptoDBModel(){
        if QueryUtils.fetchExistingEvents(event_id: self.eventid ?? 0, event_name: self.name ?? "") {
            LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
            LocalPrefs.setEventsTotal(count: LocalPrefs.getEventsTotal() - 1)
            LocalPrefs.setSyncEventsTotalCount(count: LocalPrefs.getSyncEventsTotalCount() + 1)
        } else {
            var events : Hkb_event = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_EVENT, into: DbController.getContext()) as! Hkb_event
//            var events: Hkb_event?
            events.eventid = Int64(self.eventid ?? 0)
            events.active = Int16(self.active ?? 0)
            events.enddate = self.enddate ?? ""
            events.name = self.name ?? ""
            events.desc = self.desc ?? ""
            events.startdate = self.startdate ?? ""
            events.is_synced = 1
            DbController.saveContext()
            LocalPrefs.setSyncedBackupTotalCount(totalBackupCount: LocalPrefs.getSyncedBackupTotalCount() + 1)
            LocalPrefs.setEventsTotal(count: LocalPrefs.getEventsTotal() - 1)
            LocalPrefs.setSyncEventsTotalCount(count: LocalPrefs.getSyncEventsTotalCount() + 1)
        }
    }
}
