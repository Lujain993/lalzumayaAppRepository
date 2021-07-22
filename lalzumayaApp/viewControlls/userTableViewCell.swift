//
//  userTableViewCell.swift
//  lalzumayaApp
//
//  Created by Lujain Z on 20/07/2021.
//

import UIKit

class userTableViewCell: UITableViewCell {
 
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userStatus: UILabel!
    @IBOutlet weak var userGender: UILabel!
    @IBOutlet weak var userView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
