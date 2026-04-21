

import Foundation
import CryptoSwift
import CoreData

class Extension {
    
    
}

extension Date {
    var ticks: Int64 {
        return Int64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}

extension Date {
    
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        return calendar.isDate(self, equalTo: date, toGranularity: component)
    }
    
    func isInSameYear (date: Date) -> Bool {  return isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(date: Date) -> Bool {  return isEqual(to: date, toGranularity: .month) }
    func isInSameDay  (date: Date) -> Bool {  return isEqual(to: date, toGranularity: .day) }
    func isInSameWeek (date: Date) -> Bool {  return isEqual(to: date, toGranularity: .weekOfYear) }
    
    var isInThisYear:  Bool {  return isInSameYear(date: Date()) }
    var isInThisMonth: Bool {  return isInSameMonth(date: Date()) }
    var isInThisWeek:  Bool {  return isInSameWeek(date: Date()) }
    
    var isInYesterday: Bool {  return Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool {  return Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool {  return Calendar.current.isDateInTomorrow(self) }
    
    var isInTheFuture: Bool {  return self > Date() }
    var isInThePast:   Bool {  return self < Date() }
}
extension String {
    
    func aesEncrypt(key: String, iv: String) -> String {
        var encryptedString = ""
        
        do {
            let encryptedData = try AES(key: key, iv: iv, padding: .pkcs7).encrypt([UInt8](self.data(using: .utf8)!))
            encryptedString = Data(encryptedData).base64EncodedString()
            return encryptedString
        } catch {
            return ""
        }
    }
    
    func aesDecrypt(key: String, iv: String) -> String {
        guard let data = Data(base64Encoded: self) else { return "" }
        
        do {
            let decrypted = try AES(key: key, iv: iv, padding: .pkcs7).decrypt([UInt8](data))
            return String(bytes: decrypted, encoding: .utf8) ?? self
        } catch {
            return ""
        }
    }
}



extension NSPersistentStoreCoordinator {
    
    // MARK: - Destroy
    
    static func destroyStore(at storeURL: URL) {
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
        } catch let error {
            fatalError("failed to destroy persistent store at \(storeURL), error: \(error)")
        }
    }
    
    // MARK: - Replace
    
    static func replaceStore(at targetURL: URL, withStoreAt sourceURL: URL) {
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try persistentStoreCoordinator.replacePersistentStore(at: targetURL, destinationOptions: nil, withPersistentStoreFrom: sourceURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
        } catch let error {
            fatalError("failed to replace persistent store at \(targetURL) with \(sourceURL), error: \(error)")
        }
    }
    
    // MARK: - Meta
    
    static func metadata(at storeURL: URL) -> [String : Any]?  {
        return try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
    }
    
    // MARK: - Add
    
    func addPersistentStore(at storeURL: URL, options: [AnyHashable : Any]) -> NSPersistentStore {
        do {
            return try addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch let error {
            fatalError("failed to add persistent store to coordinator, error: \(error)")
        }
        
    }
}
extension Decodable {
    static func decode(data: Data) -> Self? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Self.self, from: data)
        } catch let error {
            print(error)
            return nil
        }
    }
    

}

extension Encodable {
    var convertToString: String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            return ""
        }
    }
    
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
