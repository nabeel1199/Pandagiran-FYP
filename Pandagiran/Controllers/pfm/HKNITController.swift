

import UIKit
import StoreKit
import Kingfisher

class HKNITController: BaseViewController{
    
    @IBOutlet weak var tableViewNIT: UITableView!
    
    var nitDataContent: Investment_plan?
    var id: Int?
    var investmentPlanId : Int?

    var inventmentTitle: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.inventmentTitle ?? ""
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.inventmentTitle ?? ""
        getInvestmentPlans()
        initVariable()
        initUI()
    }
    
    
    private func initNib(){
        let nib = UINib(nibName: "NITTableViewCell", bundle: nil)
        tableViewNIT.register(nib, forCellReuseIdentifier: "NITTableViewCell")
    }
    
    private func initVariable(){
        tableViewNIT.delegate = self
        tableViewNIT.dataSource = self
        initNib()

    }
    
    private func initUI(){
        let button = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(onCloseTapped))
        navigationItem.leftBarButtonItem = button
        self.view.backgroundColor = UIColor().hexCode(hex: "#F5F7FC")

    }
    @objc private func onCloseTapped () {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func getInvestmentPlans(){
        UIUtils.showLoader(view: self.view)
        NITNetworkCalls.sharedInstance.getInformationPlan(investmentId: id ?? 0 , successHandler: {
            response in self.nitDataContent = response
            self.tableViewNIT.reloadData()
            UIUtils.dismissLoader(uiView: self.view)

            print("Types of investments: \(self.id)")

     
            }) { error in
            UIUtils.showSnackbarNegative(message: "\(error.localizedDescription)")
        }
                                                          
        }
                                                          }
                                                          
                                                          
    
    


extension HKNITController: UITableViewDelegate, UITableViewDataSource{
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("NIT Data Count :\(String(describing: self.nitDataContent?.data?.count))")
        return self.nitDataContent?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NITTableViewCell", for: indexPath) as? NITTableViewCell else {
            return UITableViewCell() }
        
        cell.viewMore.tag = indexPath.row
        cell.viewMore.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        cell.infoLbl.text = self.nitDataContent?.data?[indexPath.row].attributes?.content?.html2String ?? ""
        let baseURL = Constants.HK_NIT_BASE_URL
        let imgURL = self.nitDataContent?.data?[indexPath.row].attributes?.logo?.data?.attributes?.url ?? ""
        let url = URL(string: baseURL + imgURL)
        cell.imgView.kf.setImage(with: url )
        investmentPlanId = self.nitDataContent?.data?[indexPath.row].id ?? 0
        cell.selectionStyle = .none
        
        return cell
    }
    
    @objc func btnTapped(sender: UIButton){
        let dest = getStoryboard(name: ViewIdentifiers.SB_HKNIT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_HK_NITINTRODUCTION) as! NITIntroductionController
        dest.id = self.id
        dest.investmentPlanId = self.investmentPlanId
        navigationItem.title = ""
        dest.ivestmentTitle = self.nitDataContent?.data?[sender.tag].attributes?.title ?? ""
        dest.introductionText = self.nitDataContent?.data?[sender.tag].attributes?.content ?? ""
        navigationController?.pushViewController(dest, animated: true)
    }
    
    
}
