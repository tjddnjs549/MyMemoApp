//
//  HeaderTableViewCell.swift
//  MyMemoList
//
//  Created by 박성원 on 2023/08/10.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    
    @IBOutlet weak var headerLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
