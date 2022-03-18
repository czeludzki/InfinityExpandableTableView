//
//  TableViewCell.swift
//  InfinityExpandableTableView
//
//  Created by siu on 2022/3/18.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var contentContainerLeftConstraint: NSLayoutConstraint!
    
    let chevronImage_right = UIImage.init(systemName: "chevron.right")
    let chevronImage_down = UIImage.init(systemName: "chevron.down")
    
    var node1d: JsonParserNode1D? {
        didSet {
            guard let node1d = node1d else { return }
            
            self.keyLabel.text = node1d.key
            self.valueLabel.text = node1d.stringValue
            
            if let fold = node1d.fold {
                self.chevronImageView.image = fold ? self.chevronImage_right : self.chevronImage_down
            }
            self.chevronImageView.isHidden = node1d.fold == nil
            
            let margin = Double(node1d.hierarchy) * 12.0
            self.contentContainerLeftConstraint.constant = margin
            self.updateConstraintsIfNeeded()
        }
    }

}
