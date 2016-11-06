//
//  AutoLayoutTableViewCell.swift
//  LiverAtlas
//
//  Created by John on 11/3/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

@IBDesignable
class AutoLayoutTableViewCell: UITableViewCell {
    @IBOutlet public var theLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization 
        
        theLabel.text = "excite"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state    
    }
    
    
    func addAutolayoutConstraints() {
        self.theLabel!.superview!.translatesAutoresizingMaskIntoConstraints = false
        
        theLabel!.topAnchor.constraint(equalTo: superview!.topAnchor).isActive = true
        theLabel!.leadingAnchor.constraint(equalTo:superview!.leadingAnchor).isActive = true
        theLabel!.trailingAnchor.constraint(equalTo: superview!.trailingAnchor).isActive = true
        theLabel!.bottomAnchor.constraint(equalTo: superview!.bottomAnchor).isActive = true
        
//        backgroundColor = UIColor.red
    }
    
    lazy var addAutolayoutConstraintsOnce: () = { [unowned self] in self.addAutolayoutConstraints() }()
    override func updateConstraints() {
        if let _ = theLabel {
            let _ = addAutolayoutConstraintsOnce
        }

        super.updateConstraints()
    }
    
    override func prepareForInterfaceBuilder() {
        self.theLabel = self.contentView.subviews.first { ($0 as? UILabel) != nil } as? UILabel
        
        updateConstraints()
        super.prepareForInterfaceBuilder()
        self.layoutIfNeeded()
    }
    
}
