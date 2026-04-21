

import UIKit
import CoreData
import Firebase

class BackupRestoreViewController: BaseViewController {
    
    @IBOutlet weak var label_last_backup: UILabel!
    @IBOutlet weak var label_icloud_backup: UILabel!
    @IBOutlet weak var cloudRestoreButton: GradientButton!
    @IBOutlet weak var localRestoreButton: GradientButton!
    
    private var localBackup = ""
    private var iCloudBackup = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
    }
    
    private func initUI () {
        setLocalBackupTime()
        setIcloudBackupTime()
    }
    
    private func setLocalBackupTime () {        
        let backUpFolderUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        let backupUrl = backUpFolderUrl.appendingPathComponent("backup")
        
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: backupUrl.path)
            let creationDate = attrs[FileAttributeKey.creationDate] as! Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let time = dateFormatter.string(from: creationDate)
            localBackup = "\(Utils.currentDateUserFormat(date: creationDate)) at \(time)"
            label_last_backup.text = "Last synced on : \(localBackup)"
            
        } catch {
            
            label_last_backup.text = "Last synced on : No backup"
        }
        
    }
    
    private func setIcloudBackupTime () {
        let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        let backupUrl = iCloudDocumentsURL?.appendingPathComponent("backup")
        
        downloadBackupFile(backupUrl: backupUrl) {
            do {
                let attrs = try FileManager.default.attributesOfItem(atPath: (backupUrl?.path)!)
                let creationDate = attrs[FileAttributeKey.creationDate] as! Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let time = dateFormatter.string(from: creationDate)
                iCloudBackup = "\(Utils.currentDateUserFormat(date: creationDate)) at \(time)"
                label_icloud_backup.text = "Last synced on : \(iCloudBackup)"
//                cloudRestoreButton.isEnabled = true
            } catch {
//                cloudRestoreButton.isEnabled = false
                label_icloud_backup.text = "Last synced on : No backup"
                print("EROOR : ", error)
            }
        }
    }
    
    
    private func downloadBackupFile (backupUrl: URL? , didDownload: () -> Void) {
        if backupUrl != nil {
            if FileManager.default.fileExists(atPath: (backupUrl?.path)!) {
                do {
                    try FileManager.default.startDownloadingUbiquitousItem(at: backupUrl!)
                    cloudRestoreButton.isEnabled = true
                } catch {
                    print("Could not download" , error)
                }
                
                didDownload()
            } 
        } else {
            cloudRestoreButton.isEnabled = false
        }
    }
    
    private func copyDatabase() {
        let backUpFolderUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        let backupUrl = backUpFolderUrl.appendingPathComponent("backup")
        let backupUrl2 = backUpFolderUrl.appendingPathComponent("backup-shm")
        let backupUrl3 = backUpFolderUrl.appendingPathComponent("backup-wal")
        
        if FileManager.default.fileExists(atPath: backupUrl.path) {
            do {
                try FileManager.default.removeItem(at: backupUrl)
                try FileManager.default.removeItem(at: backupUrl2)
                try FileManager.default.removeItem(at: backupUrl3)
            } catch {
                print("Could not delete the existing backup")
                return
            }
        }
        
        let container = NSPersistentContainer(name: "Hysab Kytab")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in })
        
        let store:NSPersistentStore
        store = container.persistentStoreCoordinator.persistentStores.last!
        do {
            try container.persistentStoreCoordinator.migratePersistentStore(store,
                                                                            to: backupUrl,
                                                                            options: nil,
                                                                            withType: NSSQLiteStoreType)
            
            setLocalBackupTime()
            UIUtils.showSnackbar(message: "Backup created successfully")
        } catch {
            print("Failed to migrate" , error)
            UIUtils.showSnackbarNegative(message: "Could not create the backup")
        }
    }
    
    private func backupOniCloud () {
        var error:NSError?
        
        
        var iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        
        // check for container existence
        if let url = iCloudDocumentsURL, !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        let backupUrl = iCloudDocumentsURL?.appendingPathComponent("backup")
        let backupUrl2 = iCloudDocumentsURL?.appendingPathComponent("backup-shm")
        let backupUrl3 = iCloudDocumentsURL?.appendingPathComponent("backup-wal")
        
        //        do {
        //            try FileManager.default.startDownloadingUbiquitousItem(at: backupUrl!)
        //            try FileManager.default.startDownloadingUbiquitousItem(at: backupUrl2!)
        //            try FileManager.default.startDownloadingUbiquitousItem(at: backupUrl3!)
        //        } catch {
        //            print("WHATTTT" , error)
        //        }
        
        print("BACKUP URL :  " , backupUrl?.path)
        
        if backupUrl != nil {
            if FileManager.default.fileExists(atPath: (backupUrl!.path)) {
                do {
                    try FileManager.default.removeItem(at: backupUrl!)
                    try FileManager.default.removeItem(at: backupUrl2!)
                    try FileManager.default.removeItem(at: backupUrl3!)
                } catch {
                    print("Could not delete the existing backup" , error)
                    return
                }
            }
            
            
            
            //        //is iCloud working?
            //        if  iCloudDocumentsURL != nil {
            //
            //            //Create the Directory if it doesn't exist
            //            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL!.path, isDirectory: nil)) {
            //                //This gets skipped after initial run saying directory exists, but still don't see it on iCloud
            //                do {
            //                    try FileManager.default.createDirectory(at: iCloudDocumentsURL!, withIntermediateDirectories: true, attributes: nil)
            //                } catch {
            //                    print("ERROR OCCURED : " , error)
            //                }
            //            }
            //        } else {
            //            print("iCloud is NOT working!")
            //        }
            
            let container = NSPersistentContainer(name: "Hysab Kytab")
            
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in })
            
            let store:NSPersistentStore
            store = container.persistentStoreCoordinator.persistentStores.last!
            
            print("STORE : " , store)
            do {
                try container.persistentStoreCoordinator.migratePersistentStore(store,
                                                                                to: backupUrl!,
                                                                                options: nil,
                                                                                withType: NSSQLiteStoreType)
                
                UIUtils.showSnackbar(message: "Backup created successfully")
                setIcloudBackupTime()
            } catch {
                print("Failed to migrate" , error)
                UIUtils.showAlert(vc: self, message: "Could not backup, please try again")
            }
        }
    }
    
    private func showAlertOnRestore (isLocalBackup: Bool, backupTime: String) {
        let alert = UIAlertController(title: "Restore", message: "It will wipe all your current data from HK-Server, all your current data will be replaced with the backup file that you are restoring. Are you sure you want to continue?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
            if isLocalBackup {
                Constants.IS_RESTORE = true
                Constants.IS_LOCAL_RESTORE = true
                LocalPrefs.setIsDataWiped(isDataWiped: true)
                QueryUtils.deleteAllSavings()
                QueryUtils.deleteAllAccounts()
                QueryUtils.deleteAllCategories()
                QueryUtils.deleteSavingTransactions()
                QueryUtils.deleteAllTransaction()
                self.clearDataFromServer()
                let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
                let dest = storyboard.instantiateViewController(withIdentifier: "LandingViewController")
                self.present(dest, animated: true, completion: nil)
                
            }
            else
            {
                Constants.IS_RESTORE = true
                Constants.IS_LOCAL_RESTORE = false
                LocalPrefs.setIsDataWiped(isDataWiped: true)
                QueryUtils.deleteAllSavings()
                QueryUtils.deleteAllAccounts()
                QueryUtils.deleteAllCategories()
                QueryUtils.deleteSavingTransactions()
                QueryUtils.deleteAllTransaction()
                self.clearDataFromServer()
                let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
                let dest = storyboard.instantiateViewController(withIdentifier: "LandingViewController")
                self.present(dest, animated: true, completion: nil)
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func noBackupAlert (isLocalBackup: Bool) {
        let alert = UIAlertController(title: "", message: "Could not find any previous backup to restore from. Would you like to create a backup now?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {action in
            if isLocalBackup {
                self.copyDatabase()
            } else {
                self.backupOniCloud()
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension BackupRestoreViewController {
    // Tap Listeners here
    @IBAction func onRestoreTapped(_ sender: Any) {
        if localBackup != "" {
            showAlertOnRestore(isLocalBackup: true, backupTime: localBackup)
        } else {
            noBackupAlert(isLocalBackup: true)
        }
        
    }
    
    @IBAction func onBackupTapped(_ sender: Any) {
        copyDatabase()
    }
    
    @IBAction func onIcloudRestoreTapped(_ sender: Any) {
        if iCloudBackup != "" {
            showAlertOnRestore(isLocalBackup: false, backupTime: iCloudBackup)
        } else {
            noBackupAlert(isLocalBackup: false)
        }
    }
    
    @IBAction func onIcloudBackupTapped(_ sender: Any) {
        backupOniCloud()
    }
    
    
    func clearDataFromServer(){
        Analytics.logEvent("Wipe_Server", parameters: nil)
        RestoreNetworkCalls.sharedInstance.getWipAllData(isRestore: true) { status, message, response in
            if status == 1{
                print(response)
                print(message)
                UIUtils.showSnackbar(message: message)
            } else{
                print(response)
                print(message)
                UIUtils.showSnackbarNegative(message: "Failed to clear Data")
            }
        }
    }
}
