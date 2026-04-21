

import UIKit
import Kingfisher

protocol presentController{
    func labelTapped(id : Int, title: String)
}

class Investment: UITableViewCell {

    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var optionLbl: UILabel!
    @IBOutlet weak var optionImg: UIImageView!
    @IBOutlet weak var optionTable: UITableView!
    private var investmentTitle: String?
    var nitResponse: Nit?
    var delegate: presentController?
    var id: Int?
    
    @IBOutlet weak var tableHeighht: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: "InvestmentOptions", bundle: nil)
        optionTable.register(nib, forCellReuseIdentifier: "InvestmentOptions")
        optionTable.dataSource = self
        optionTable.delegate = self
//        self.tableHeighht.constant = optionTable.contentSize.height
        print("Nit Response in Options:\(self.nitResponse)")
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.tableHeighht.constant = self.optionTable.contentSize.height
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension Investment: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Data Count: \(self.nitResponse?.data?.count)")
        return self.nitResponse?.data?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InvestmentOptions", for: indexPath) as? InvestmentOptions else {return UITableViewCell()}
        cell.investmentLbl.text = self.nitResponse?.data?[indexPath.row].attributes?.name ?? ""
        investmentTitle = cell.investmentLbl.text
        let baseURL = Constants.HK_NIT_BASE_URL
        let imgURL = self.nitResponse?.data?[indexPath.row].attributes?.partnerImage?.data?.attributes?.url ?? ""
        let url = URL(string: baseURL + imgURL)
        cell.investmentImg.kf.indicatorType = .activity
        cell.investmentImg.kf.setImage(with: url )
        print(url)
        print("Name in Data:\(self.nitResponse?.data?[indexPath.row].attributes?.name ?? "None")")
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let id = self.nitResponse?.data?[indexPath.row].id ?? 0
        let title = self.nitResponse?.data?[indexPath.row].attributes?.name ?? ""
        seperatorView.backgroundColor = .white
        delegate?.labelTapped(id: id, title: title)

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
    }
    
  
    
    
}

