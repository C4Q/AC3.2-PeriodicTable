//
//  ElementCollectionViewCell.swift
//  PeriodicTableOfTheElements
//
//  Created by Jason Gresh on 12/21/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

class ElementCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var elementView: ElementView!
    override func awakeFromNib() {
        super.awakeFromNib()
        elementView.symbolLabel.adjustsFontSizeToFitWidth = false
        elementView.numberLabel.adjustsFontSizeToFitWidth = false
        elementView.symbolLabel.font = UIFont.systemFont(ofSize: 20)
        elementView.numberLabel.font = UIFont.systemFont(ofSize: 10)
    }
}
