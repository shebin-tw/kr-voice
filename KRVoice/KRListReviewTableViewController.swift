//
//  KRListReviewTableViewController.swift
//  KRVoice
//
//  Created by Shebin Koshy on 13/04/22.
//

import UIKit

class KRListReviewTableViewController: UITableViewController {
    
    var reviews: [ReviewItem]?

    override func viewDidLoad() {
        super.viewDidLoad()
        reviews = ReviewItem.fetchReviews()
        tableView.register(KRListReviewTableViewCell.nib(), forCellReuseIdentifier: KRListReviewTableViewCell.cellIdentifier())
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: KRListReviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: KRListReviewTableViewCell.cellIdentifier(), for: indexPath) as? KRListReviewTableViewCell  else {
            return UITableViewCell()
        }
        let item = reviews![indexPath.row]
        cell.reviewOwnerLabel.text = item.ownerName
        cell.starRating.rating = Double(item.rating)
        cell.starRating.update()
        cell.reviewDescriptionLabel.text = item.revDescription
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
