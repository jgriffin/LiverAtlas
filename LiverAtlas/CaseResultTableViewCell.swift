//
//  CaseResultTableViewCell.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseResultTableViewCell: UITableViewCell {
    static let identifier = "CaseResultTableViewCellIdentifier"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var specificDiagnosisLabel: UILabel!
    @IBOutlet weak var clinicalPresentationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(liverAtlasCase: LiverAtlasCase) {
        titleLabel?.text = liverAtlasCase.title
        specificDiagnosisLabel?.text = liverAtlasCase.specificDiagnosis
        clinicalPresentationLabel?.text = liverAtlasCase.clinicalPresentation
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
