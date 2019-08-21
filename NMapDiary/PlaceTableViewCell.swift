//
//  PlaceTableViewCell.swift
//
//  Created by JIN on 20/08/2019.
//  Copyright © 2019 sy. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    //response
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
