//
//  HomeTableViewController.swift
//  KRVoice
//
//  Created by Shebin Koshy on 13/04/22.
//

import UIKit
import NotificationBannerSwift

class HomeTableViewController: UITableViewController {
    
    var banner: GrowingNotificationBanner?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.black
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        if #available(iOS 15.0, *) {
           tableView.sectionHeaderTopPadding = .zero
        }
        self.tableView.allowsSelection = false
        navBar()
        self.navigationController?.navigationBar.isHidden = true
        
        banner = GrowingNotificationBanner(title: "", subtitle: "Hey, submit review of your recent purchase - belVita Breakfast Blueberry Biscuits", style: .success)
        banner?.show()
        banner?.onTap = {
            self.showCreateReview()
        }
        banner?.autoDismiss = false
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }
    
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: self.tableView)
        if location.y > (self.view.bounds.size.height/2) {
            //bottom
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PDPTableViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            //top
            banner?.show()
        }
        
    }
    
    @objc func showCreateReview() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReviewTableViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func exit() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        banner?.dismiss(forced: true)
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }


}

extension HomeTableViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
    }
}
