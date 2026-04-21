import CoreData

class MigrationPolicy: NSEntityMigrationPolicy {
    
//    override func createDestinationInstances(forSource sInstance: NSManagedObject,
//                                             in mapping: NSEntityMapping,
//                                             manager: NSMigrationManager) throws
//    {
//       if sInstance.entity.name == "Hkb_account"
//        {
//            let isSynced = sInstance.primitiveValue(forKey: "is_synced") as! Int32
////            let userAge = sInstance.primitiveValue(forKey: "userAge") as! Int
////            let userSex = sInstance.primitiveValue(forKey: "userSex") as! String
////            let userCity = sInstance.primitiveValue(forKey: "userCity") as! String
////            let userCountry = sInstance.primitiveValue(forKey: "userCountry") as! String
//
//            if isSynced == 1
//            {
////                let updateTable = NSEntityDescription.
////                let tableName = NSEntityDescription.insertNewObject(forEntityName: "Hkb_account",
////                                                                      into: manager.destinationContext)
////                tableName.setValue(0, forKey: "is_synced")
////                finelandUser.setValue(userAge, forKey: "userAge")
////                finelandUser.setValue(userSex, forKey: "userSex")
////                if userCity == "Vaasa"
////                {
////                    finelandUser.setValue("Pori", forKey: "userCity")
////                }
////                else
////                {
////                    finelandUser.setValue(userCity, forKey: "userCity")
////                }
//            }
//        }
//    }
    
//    override func performCustomValidation(forMapping mapping: NSEntityMapping, manager: NSMigrationManager) throws {
//        print(mapping.sourceEntityName)
////        let eName = mapping.destinationEntityName
//
//    }
    
    
    
//     override func validateValue(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>, forKey key: String) throws {
//        print("\(key)")
//        if key == "is_synced"{
//            value.pointee?.setValue(0, forKey: "is_synced")
//        }
//    }
    
    
    
//    @objc
//    public func setActive() -> Int32 {
//        return Int32(0)
//        
//    }
//    
//    @objc func syncronized() -> Int32 {
//        return 3
//    }
//    
//    @objc func setActive(is_synced: Int16) -> Int32 {
//        if is_synced == 0 {
//            return Int32(1)
//        } else {
//            return Int32(1)
//        }
//
//    }
    // FUNCTION($entityPolicy, “setActive”)

//    FUNCTION($entityPolicy, “syncronized”)
//    FUNCTION($entityPolicy, "convertWithIs_synced:" , $source.is_synced)
    //    @objc func changeData(forData: Int16) -> Int16 {
    //        return Int16(2)
    //    }
//        FUNCTION($entityPolicy, "setActiveWithIs_synced:" , $source.is_synced)
    //    FUNCTION($entityPolicy, "setActive:")
    //    FUNCTION($entityPolicy, "convertIs_synced:" , $source.is_synced)
    //    FUNCTION($entityPolicy, "changeDataForData:" , $source.is_synced)
    //    FUNCTION($entityPolicy, "convertIs_synced:", $source.is_synced)
    //    FUNCTION($manager, "destinationInstancesForEntityMappingNamed:sourceInstances:","NoteToNote", $source)

}
