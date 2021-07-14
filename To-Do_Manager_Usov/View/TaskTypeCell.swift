//
//  TaskTypeCell.swift
//  To-Do_Manager_Usov
//
//  Created by Андрей Бородкин on 14.07.2021.
//

import UIKit

class TaskTypeCell: UITableViewCell {

    @IBOutlet var typeTitle: UILabel!
    @IBOutlet var typeDescription: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
