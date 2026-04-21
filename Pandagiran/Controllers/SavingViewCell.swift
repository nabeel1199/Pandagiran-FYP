//
//  SavingViewCell.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 3/22/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit

class SavingViewCell: UITableViewCell {

    
    @IBOutlet weak var progress_View: UIProgressView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        progress_View.layer.cornerRadius = 3
        progress_View.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func onMenuItemTapped(_ sender: Any) {
    }
}
