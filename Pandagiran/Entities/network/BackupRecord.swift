

import Foundation

struct BackupRecord {
    public var title : String?
    public var entries_count : Int?
    public var synced : Bool?
    
    internal init(title: String? = nil, entries_count: Int? = nil, isSynced: Bool? = false) {
        self.title = title
        self.entries_count = entries_count
        self.synced = isSynced
    }
}
