//
//  LogDiaryTableViewCell.swift
//  NMapDiary
//
//  Created by cscoi008 on 2019. 8. 23..
//  Copyright © 2019년 sy. All rights reserved.
//

import UIKit

class LogDiaryTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet var placeTableCellLabel: UILabel!
    @IBOutlet var dateTableCellLabel: UILabel!
    @IBOutlet var contentsTableCellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
