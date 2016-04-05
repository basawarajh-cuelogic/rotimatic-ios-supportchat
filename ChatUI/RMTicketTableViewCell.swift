//
//  RMTicketTableViewCell.swift
//  ChatUI
//
//  Created by Basawaraj on 05/04/16.
//  Copyright © 2016 Basawaraj. All rights reserved.
//

import UIKit

class RMTicketTableViewCell: UITableViewCell {

    @IBOutlet var lblTicketTitle: UILabel!
    @IBOutlet var lblTicketDescription: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var statusView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        statusView.layer.cornerRadius = statusView.frame.size.height/2
        statusView.layer.masksToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
