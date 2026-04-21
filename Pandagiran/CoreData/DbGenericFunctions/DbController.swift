
import Foundation
import CoreData

class DbController {
    
    
    static let shared = DbController()
    //    private init(){}
    //
    //
//        class func getContext() -> NSManagedObjectContext {
//            return  persistentContainer.viewContext
//        }
    class func getContext() -> NSManagedObjectContext {
        return  DbController.shared.persistentContainer.viewContext
    }
//
    
    //
//
//        static var persistentContainer: NSPersistentContainer = {
//            /*
//             The persistent container for the application. This implementation
//             creates and returns a container, having loaded the store for the
//             application to it. This property is optional since there are legitimate
//             error conditions that could cause the creation of the store to fail.
//             */
//            let container = NSPersistentContainer(name: "Hysab Kytab")
//    //
//    //        let description = NSPersistentStoreDescription()
//    //        description.shouldInferMappingModelAutomatically = true
//    //        description.shouldMigrateStoreAutomatically = true
//    //        container.viewContext.automaticallyMergesChangesFromParent = true
//    //        container.persistentStoreDescriptions = [description]
//            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//                if let error = error as NSError? {
//                    // Replace this implementation with code to handle the error appropriately.
//                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//
//                    /*
//                     Typical reasons for an error here include:
//                     * The parent directory does not exist, cannot be created, or disallows writing.
//                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                     * The device is out of space.
//                     * The store could not be migrated to the current model version.
//                     Check the error message to determine what the actual problem was.
//                     */
//                    fatalError("Unresolved error \(error), \(error.userInfo)")
//                }
//            })
//            return container
//        }()
//    //
//    //    let migrator: CoreDataMigrator
//    //
    lazy var persistentContainer: NSPersistentContainer! = {
        let persistentContainer = NSPersistentContainer(name: "Pandagiran")
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = false
        description.shouldInferMappingModelAutomatically = true
        persistentContainer.persistentStoreDescriptions.append(description)


        //        description?.shouldInferMappingModelAutomatically = true
        //        description.shouldMigrateStoreAutomatically = true
        //        persistentContainer.persistentStoreDescriptions = [description!]
        return persistentContainer
    }()
    //
    //    lazy var backgroundContext: NSManagedObjectContext = {
    //        let context = self.persistentContainer.newBackgroundContext()
    //        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    //
    //        return context
    //    }()
    //
    //    lazy var mainContext: NSManagedObjectContext = {
    //        let context = self.persistentContainer.viewContext
    //        context.automaticallyMergesChangesFromParent = true
    //
    //        return context
    //    }()
    //
    //    // MARK: - Singleton
    //
    //    static let shared = DbController()
    //
    //    // MARK: - Init
    //
    //    init(migrator: CoreDataMigrator = CoreDataMigrator()) {
    //        self.migrator = migrator
    //    }
    //
    //    // MARK: - SetUp
    //
    //    func setup(completion: @escaping () -> Void) {
    //        loadPersistentStore {
    //            completion()
    //        }
    //    }
    //
    //    // MARK: - Loading
    //
    //    func loadPersistentStore(completion: @escaping () -> Void) {
    //        migrateStoreIfNeeded {
    //        self.persistentContainer.loadPersistentStores { description, error in
    //                guard error == nil else {
    //                    fatalError("was unable to load store \(error!)")
    //                }
    //
    //                completion()
    //            }
    //        }
    //    }
    ////
    //    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
    //        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
    //            fatalError("persistentContainer was not set up properly")
    //        }
    //
    //        if migrator.requiresMigration(at: storeURL) {
    //            DispatchQueue.global(qos: .userInitiated).async {
    //                self.migrator.migrateStore(at: storeURL)
    //
    //                DispatchQueue.main.async {
    //                    completion()
    //                }
    //            }
    //        } else {
    //            completion()
    //        }
    //    }


    func loadPersistentStore(completion: @escaping () -> Void) {
        //        migrateStoreIfNeeded {

        if LocalPrefs.getIsDataWiped(){
            completion()
        } else {
            self.persistentContainer.loadPersistentStores { description, error in
                guard error == nil else {
                    fatalError("was unable to load store \(error!)")
                }

                completion()
            }
        }
        
        //        }
    }
    ////
    //    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
    //        guard let storeURL = DbController.persistentContainer.persistentStoreDescriptions.first?.url else {
    //            fatalError("persistentContainer was not set up properly")
    //        }
    //
    //        if migrator.requiresMigration(at: storeURL) {
    //            DispatchQueue.global(qos: .userInitiated).async {
    //                self.migrator.migrateStore(at: storeURL)
    //
    //                DispatchQueue.main.async {
    //                    completion()
    //                }
    //            }
    //        } else {
    //            completion()
    //        }
    //    }

    public func clearDatabase(completion: @escaping () -> Void){
        guard let url = persistentContainer.persistentStoreDescriptions.first?.url else { return }
        
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator

         do {
             try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
             try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            completion()
         } catch {
             print("Attempted to clear persistent store: " + error.localizedDescription)
            completion()
         }
    }
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        let context = DbController.shared.persistentContainer.viewContext
//                let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } 
        
        
    }
}
