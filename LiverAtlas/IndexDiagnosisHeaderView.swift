//
//  IndexDiagnosisHeaderView.swift
//  LiverAtlas
//
//  Created by John on 12/17/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class IndexDiagnosisHeaderView: UITableViewHeaderFooterView {
    @IBOutlet var titleLabel: UILabel!
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        createConstraints()
    }
    
    func createConstraints() {
        let views: [String: UIView] = ["titleLabel": titleLabel]

        let constraints = ["H:|-8-[titleLabel]-8-|", "V:|-[titleLabel]-|"].flatMap { (visualFormat) -> [NSLayoutConstraint] in
            NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                           options: [], metrics: nil, views: views)
        }
        NSLayoutConstraint.activate(constraints)
    }
    

}
