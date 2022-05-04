//
//  KRListReviewTableViewCell.swift
//  KRVoice
//
//  Created by Shebin Koshy on 18/04/22.
//

import UIKit
import Cosmos

class KRListReviewTableViewCell: UITableViewCell {
    
    class func nib() -> UINib {
        return UINib(nibName: "KRListReviewTableViewCell", bundle: nil)
    }
    
    class func cellIdentifier() -> String {
        return "KRListReviewTableViewCell"
    }
    
    @IBOutlet weak var reviewOwnerLabel: UILabel!
    
    @IBOutlet weak var reviewDescriptionLabel: UILabel!
    
    @IBOutlet weak var starRating: CosmosView!

    override func awakeFromNib() {
        super.awakeFromNib()
        starRating.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
