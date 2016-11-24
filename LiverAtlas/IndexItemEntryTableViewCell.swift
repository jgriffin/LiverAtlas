//
//  IndexItemEntryTableViewCell.swift
//  LiverAtlas
//
//  Created by John on 11/3/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class IndexItemEntryTableViewCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var hrefLabel: UILabel!

    func configure(description: String, href: String) {
        descriptionLabel.text = description
        hrefLabel.text = href
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForInterfaceBuilder() {
        //
        print("prepareForInterface builder called")
        self.backgroundColor = UIColor.green
    }
    
    override func updateConstraints() {
        print("ran updateConstraints")
        super.updateConstraints()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
