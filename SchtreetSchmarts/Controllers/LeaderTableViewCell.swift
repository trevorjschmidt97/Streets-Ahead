//
//  LeaderTableViewCell.swift
//  SchtreetSchmarts
//
//  Created by Trevor Schmidt on 5/9/21.
//

import UIKit

class LeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var knocks: UILabel!
    @IBOutlet weak var people: UILabel!
    @IBOutlet weak var sales: UILabel!
    @IBOutlet weak var revenue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
