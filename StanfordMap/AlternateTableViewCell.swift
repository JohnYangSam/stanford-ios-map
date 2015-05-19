//
//  AlternateTableViewCell.swift
//  SearchController
//
//

import UIKit

class AlternateTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var hugeCountryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(#countryName:String)
    {
        self.hugeCountryLabel.text = countryName
    }
    
}
