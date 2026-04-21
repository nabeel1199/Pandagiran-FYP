

import UIKit
import CoreData
import SocketIO
import CommonCrypto
import Alamofire
import SwiftyJSON
import Firebase

enum AESError: Error {
    case KeyError((String, Int))
    case IVError((String, Int))
    case CryptorError((String, Int))
}


class LandingViewController: BaseViewController {

     private var sessionManager: SessionManager?
    var verify_device = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewBackgroundColor = .dark
        
        self.showScreen()
    }
    
    private func recordSyncSocket () {
        let manager = SocketManager(socketURL: URL(string: "http://35.237.181.250:1337")!, config: [.log(true), .compress])
        let socket = manager.defaultSocket
    
        socket.connect()
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            
            let items : [String:Any] = [:]
            socket.emit("interchange", items) {
                print("ERROR SOCKET : " , SocketClientEvent.error)
            }
        }
        
        
        socket.on(clientEvent: .error, callback: {
            
            data,ack in
            
            print("Error socket : " , data,ack)
            
        })
     
        
        socket.on("interchange_records") { (data, ack) in
            print("Data : " , data)
        }
        
        print("SOCKET CLIENT : " , socket.status.active)
        
    
    }

    private func initialNavigation () {
        
        let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
        let sbTabbar = UIUtils.getStoryboard(name: Constants.SB_TAB_BAR)
        
      
       
        if LocalPrefs.getIsDataWiped() {
            LocalPrefs.setIsDataWiped(isDataWiped: false)
            if Constants.IS_RESTORE {
                if Constants.IS_LOCAL_RESTORE {
                    restoreFromStore()
                    Constants.IS_RESTORE = false
                } else {
                    restoreFromICloud()
                    Constants.IS_RESTORE = false
                }
            } else {
                QueryUtils.saveAccounts()
                QueryUtils.saveCategories()
            }


            let dest = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
            self.present(dest, animated: true, completion: nil)
        }  else if LocalPrefs.getIsVerified() && LocalPrefs.getIsRegistered() && !LocalPrefs.checkForNil(key: LocalPrefs.USER_CURRENCY) {
            let dest = storyboard.instantiateViewController(withIdentifier: "SelectCurrencyVC")
            self.present(dest, animated: true, completion: nil)
        } else if LocalPrefs.getIsVerified() && LocalPrefs.getIsRegistered() {
            let dest = storyboard.instantiateViewController(withIdentifier: "MainVC")
            self.present(dest, animated: true, completion: nil)
        } else if (LocalPrefs.getIsVerified() && !LocalPrefs.getIsRegistered()) {
            let dest = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
            self.present(dest, animated: true, completion: nil)
        } else {
            let dest = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
            self.present(dest, animated: true, completion: nil)
//            let dest = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//            self.present(dest, animated: true, completion: nil)
        }
    }
    
    private func checkTravelModeActive () -> Bool {
        if LocalPrefs.getIsTravelMode() {
            let date1 : Date = Utils.convertStringToDate(dateString: LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_START_DATE]!)
            let date2 : Date = Utils.convertStringToDate(dateString: LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_END_DATE]!)
            return Utils.isDateBetween(date1, and: date2 , middleDate: Date())
        }
        
        return true
    }
    
    private func restoreFromStore(){
        let storeFolderUrl = FileManager.default.urls(for: .applicationSupportDirectory, in:.userDomainMask).first!
        let storeUrl = storeFolderUrl.appendingPathComponent("Hysab Kytab.sqlite")
        let backUpFolderUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        let backupUrl = backUpFolderUrl.appendingPathComponent("backup")

        let container = NSPersistentContainer(name: "Hysab Kytab")
        
        print("URL OF DIRECTORY : " , FileManager.default.urls(for: .applicationSupportDirectory, in:.userDomainMask).first!)
        print("URL OF DIRECTORY2 : " , FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        })
        
        
        let stores = container.persistentStoreCoordinator.persistentStores
        
//        for store in stores {
//            do {
//                try container.deall
//            } catch {
//                print("Couldnt clear store")
//            }
//        }
        do {
            try
                container.persistentStoreCoordinator.replacePersistentStore(at: storeUrl,
                                                                            destinationOptions: nil,
                                                                            withPersistentStoreFrom: backupUrl,
                                                                            sourceOptions: nil,
                                                                            ofType: NSSQLiteStoreType)
            QueryUtils.batchUpdates(entityName: Constants.HKB_ACCOUNT)
            QueryUtils.batchUpdates(entityName: Constants.HKB_CATEGORY)
            QueryUtils.batchUpdates(entityName: Constants.HKB_EVENT)
            QueryUtils.batchUpdates(entityName: Constants.HKB_BUDGET)
            QueryUtils.batchUpdates(entityName: Constants.HKB_SAVING)
            QueryUtils.batchUpdates(entityName: Constants.HKB_SAVING_TRX)
            QueryUtils.batchUpdates(entityName: Constants.HKB_VOUCHER)
            
        } catch {
            print("Failed to restore")
        }
    }
    
    // Completion Handler execute after the file is downloaded
    private func downloadBackupFile (backupUrl : URL , didDownload : () -> Void) {
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: backupUrl)
        } catch {
            print("Could not download")
        }
        
        didDownload()
    }
    
    private func restoreFromICloud () {
        let storeFolderUrl = FileManager.default.urls(for: .applicationSupportDirectory, in:.userDomainMask).first!
        let storeUrl = storeFolderUrl.appendingPathComponent("Hysab Kytab.sqlite")
        let backUpFolderUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        let backupUrl = backUpFolderUrl?.appendingPathComponent("backup")
  
        downloadBackupFile(backupUrl: backupUrl!) {
            
            
            let container = NSPersistentContainer(name: "Hysab Kytab")
            
            print("URL OF DIRECTORY : " , FileManager.default.urls(for: .applicationSupportDirectory, in:.userDomainMask).first!)
            print("URL OF DIRECTORY2 : " , FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!)
            
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            })
            
            
            let stores = container.persistentStoreCoordinator.persistentStores
            
            do {
                try
                    container.persistentStoreCoordinator.replacePersistentStore(at: storeUrl,
                                                                                destinationOptions: nil,
                                                                                withPersistentStoreFrom: backupUrl!,
                                                                                sourceOptions: nil,
                                                                                ofType: NSSQLiteStoreType)
                print("Backup Restored")
                QueryUtils.batchUpdates(entityName: Constants.HKB_ACCOUNT)
                QueryUtils.batchUpdates(entityName: Constants.HKB_CATEGORY)
                QueryUtils.batchUpdates(entityName: Constants.HKB_EVENT)
                QueryUtils.batchUpdates(entityName: Constants.HKB_BUDGET)
                QueryUtils.batchUpdates(entityName: Constants.HKB_SAVING)
                QueryUtils.batchUpdates(entityName: Constants.HKB_SAVING_TRX)
                QueryUtils.batchUpdates(entityName: Constants.HKB_VOUCHER)
            } catch {
                print("Failed to restore" , error)
                restoreFromICloud()
            }
        }
    }
    
    func testCrypt(data:Data, keyData:Data, ivData:Data, operation:Int) -> Data {
        let cryptLength  = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count:cryptLength)
        
        let keyLength             = size_t(kCCKeySizeAES256)
        let options   = CCOptions(kCCOptionPKCS7Padding)
        
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                ivData.withUnsafeBytes {ivBytes in
                    keyData.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(operation),
                                CCAlgorithm(kCCAlgorithmAES),
                                options,
                                keyBytes, keyLength,
                                ivBytes,
                                dataBytes, data.count,
                                cryptBytes, cryptLength,
                                &numBytesEncrypted)
                        
                        
                    }
                }
            }
        }
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
            
        } else {
            print("Error: \(cryptStatus)")
        }
        
        return cryptData;
    }
    
    private func enableCertificatePinning() {
        let certificates = getCertificates()
  
        
        let trustPolicy: [String: ServerTrustPolicy] = [
            "https://services.hysabkytab.app": .pinCertificates(
                certificates: certificates,
                validateCertificateChain: true,
                validateHost: true
            ),
            "insecure.expired-apis.com": .disableEvaluation
        ]
//        let trustPolicies = [ "https://services.hysabkytab.app" : trustPolicy ]
        let policyManager = ServerTrustPolicyManager(policies: trustPolicy)
        sessionManager = SessionManager(
            configuration: .default,
            serverTrustPolicyManager: policyManager
        )
    }
    
    private func getCertificates() -> [SecCertificate] {
        let pathToCert = Bundle.main.path(forResource: "PublicCert", ofType: "der")!
        let localCertificate: NSData = NSData(contentsOfFile: pathToCert)!
        guard let certificate = SecCertificateCreateWithData(nil, localCertificate)
            else { return [] }
        
        return [certificate]
    }
    
    
    public func fetchPopularOffers (interests: String,
                                    offset: Int,
                                    successHandler : @escaping (Array<Deal>, Int , String) -> Void,
                                    failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "https://services.hysabkytab.app/test/deals/popular/?consumer_id=\(consumerId)&device_type=Ios&interests=\(interests)&offset=\(offset)"
        let decodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        
        
        self.sessionManager?.request(decodedUrl!, method: .get , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = try! responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    var arrayOfDeals : Array<Deal> = []
                    
                    if status == 1 {
                        let dataArray = responseObj["data"].arrayValue
                        
                        for dataObj in dataArray {
                            let dealJsonObj = dataObj.dictionaryObject
                            
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: dealJsonObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(Deal.self, from: data)
                                arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        successHandler(arrayOfDeals, status, message)
                        
                    } else {
                        successHandler([], status, message)
                    }
                    
                    
                case .failure(let error):
                    print("CODE : " , response.response?.statusCode)
                    print("Error : " , error.localizedDescription)
                    failureHandler(error)
                }
        }
    }
    
    func logoutUser(){
        Analytics.logEvent("App_Logout", parameters: nil)
        LocalPrefs.setIsDataWiped(isDataWiped: false)
        LocalPrefs.setIsRegistered(isRegistered: false)
        LocalPrefs.setIsVerified(isVerified: false)
        
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)

        QueryUtils.deleteAllSavings()
        QueryUtils.deleteAllAccounts()
        QueryUtils.deleteAllCategories()
        QueryUtils.deleteSavingTransactions()
        QueryUtils.deleteAllTransaction()
        QueryUtils.deleteAllBudgets()
        QueryUtils.deleteAllEvents()
//        DbController.shared.clearDatabase {
            let navController = UINavigationController()
            let storyboard = UIUtils.getStoryboard(name: ViewIdentifiers.SB_ONBOARDING)
            if let dest = storyboard.instantiateViewController(withIdentifier: "GetStartedVC") as? GetStartedViewController{
                navController.viewControllers = [dest]
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
    }

    
    func verifySessionFromServer(){
        APIManager.sharedInstance.verifySession { status, message, error in
            if status == 0{
//                self.logoutUser()
                self.showScreen()
            } else if status == 1 {
                self.showScreen()
            } else {
                print("Login to Other Device")
                UIUtils.showSnackbarNegative(message: error?.localizedDescription ?? "Something went wrong")
            }
        }
    }
    
    private func showScreen(){
        DbController.shared.loadPersistentStore {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let window = UIApplication.shared.windows.first!
                let navController = UINavigationController()

                if LocalPrefs.getIsDataWiped() {
                    LocalPrefs.setIsDataWiped(isDataWiped: false)
                    QueryUtils.saveAccounts()
                    QueryUtils.saveCategories()
                    if Constants.IS_RESTORE {
                        if Constants.IS_LOCAL_RESTORE {
                            self.restoreFromStore()
                            Constants.IS_RESTORE = false
                        } else {
                            self.restoreFromICloud()
                            Constants.IS_RESTORE = false
                        }
                    } else {
                        print("Nothing")
                    }

                    let dest = self.getStoryboard(name: ViewIdentifiers.SB_MAIN).instantiateViewController(withIdentifier: "MainVC")
                    self.present(dest, animated: true, completion: nil)
                } else if LocalPrefs.checkForNil(key: LocalPrefs.PASSCODE) {
                    let dest = UIUtils.getStoryboard(name: ViewIdentifiers.SB_SETTINGS).instantiateViewController(withIdentifier: "PasscodeVC") as! PasscodeViewController
                    dest.isUpdate = false
                    self.present(dest, animated: true, completion: nil)
                }  else if LocalPrefs.getIsRegistered() && LocalPrefs.getIsVerified() && LocalPrefs.getBackupTotalCount() != (LocalPrefs.getSyncedBackupTotalCount()) {

                    let dest = self.getStoryboard(name: ViewIdentifiers.SB_BACKUP).instantiateViewController(withIdentifier: ViewIdentifiers.VC_RESTOREVC) as! RestoreVC
                    navController.viewControllers = [dest]

                } else if LocalPrefs.getIsRegistered() && LocalPrefs.getIsVerified() {
                    let dest = self.getStoryboard(name: ViewIdentifiers.SB_MAIN).instantiateViewController(withIdentifier: "MainVC")
                    self.present(dest, animated: true, completion: nil)
                } else if LocalPrefs.getIsVerified() {
                    let dest = self.getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SIGNUP_DETAILS) as! SignupDetailsViewController
                    navController.viewControllers = [dest]
                } else {
                    
                    let dest = self.getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_GET_STARTED)
                    navController.viewControllers = [dest]
                }
                
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
//    private func showVerifyUser(verify_device: Bool) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            let dest = UIUtils.getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: "VerifyVC") as! VerifyVC
//            dest.verify_Device = verify_device
//            dest.modalPresentationStyle = .overCurrentContext
//            self.present(dest, animated: true, completion: nil)
//        }
//    }
}


