//
//  MemoTableViewCell.swift
//  MyMemoList
//
//  Created by 박성원 on 2023/08/10.
//

import UIKit

class MemoTableViewCell: UITableViewCell {

    
    @IBOutlet weak var memoTitleLabel: UILabel!
    
    @IBOutlet weak var memoDateLabel: UILabel!
    
    @IBOutlet weak var memoContentLabel: UILabel!
    
    @IBOutlet weak var memoView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
