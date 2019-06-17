//
//  TableCell.swift
//  DiaryApplication
//
//  Created by Sano Gharzani on 2019-05-22.


import Foundation
import UIKit


class TableCell: UITableViewCell{
    
    
    @IBOutlet var cityLbl: UILabel!
    @IBOutlet var titleTxtV: UITextView!
    @IBOutlet weak var categoryLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
