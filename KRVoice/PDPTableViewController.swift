//
//  PDPTableViewController.swift
//  KRVoice
//
//  Created by Shebin Koshy on 13/04/22.
//

import UIKit

class PDPTableViewController: UITableViewController {
    
    var reviewsTableVC: KRListReviewTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "belVita Biscuits"
        tableView.backgroundColor = UIColor.black
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        if #available(iOS 15.0, *) {
           tableView.sectionHeaderTopPadding = .zero
        }
        navBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let after: DispatchTime = .now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: after) { [weak self] in
            self?.tableView.reloadData()
            self?.reviewsTableVC?.tableView.reloadData()
            self?.tableView.reloadData()
            self?.reviewsTableVC?.tableView.reloadData()
        }
        let after2: DispatchTime = .now() + 0.4
        DispatchQueue.main.asyncAfter(deadline: after2) { [weak self] in
          self?.tableView.reloadData()
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedKRListReviewTableViewController" {
            reviewsTableVC = segue.destination as?  KRListReviewTableViewController
        }
    }
    
}

extension PDPTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        reviewsTableVC?.tableView.layoutIfNeeded()
        if indexPath.row == 1 && reviewsTableVC?.tableView?.contentSize.height == 0 {
            return 0//if child tableView list is empty, the title can be removed.
        }
        if indexPath.row != 2 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        
        return reviewsTableVC?.tableView?.contentSize.height ?? 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
    }
    
}
