//
//  ReviewTableViewController.swift
//  SSAlexaVoiceService
//
//  Created by Shebin Koshy on 06/04/22.
//  Copyright © 2022 Shebin Koshy. All rights reserved.
//

import UIKit
import Cosmos



class ReviewTableViewController: UITableViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var starRating: CosmosView!
    
    let audioInstances = AudioInstances()
    
    var isContainsBadWords: Bool = false
   
    
    private var krClient = KRVoiceServiceClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.textColor = UIColor.white
        textView.backgroundColor = UIColor.black
        textView.layer.cornerRadius = 12.5
        textView.clipsToBounds = true
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.white.cgColor
      
        placeholderLabel.text = "Add a detailed review. Tap here to start speaking..."
        audioInstances.delegate = self
        
        starRating.backgroundColor = UIColor.clear
        starRating.settings.filledColor = UIColor.init(red: 242/255, green: 217/255, blue: 0, alpha: 1)
        
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
        setupRecordView()
        
        textView.delegate = self
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0/255, green: 73/255, blue: 154/255, alpha: 1)
        self.tableView.backgroundColor = UIColor.black
        navBar()
    }
    
    
    
    func setupRecordView() {
        let recorderView = RecorderView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 300))
        recorderView.delegate = self
        textView.inputView = recorderView
        textView.inputAccessoryView = nil
    }

    
    @objc func tapGesture(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: self.tableView)
        if self.starRating.frame.contains(location) {
            return;
        }
        self.view.endEditing(true)
    }
    
    @IBAction func submitAction() {
        
        if textView.text == nil || (textView.text?.count ?? 0) == 0  {
            showAlert(message: "Your feedback is required to submit")
            return;
        }
        
        let ratingInt = Int(starRating.rating)
        print("-----ratingInt:\(ratingInt)")
        let review = ReviewItem(uniqueId: UUID().uuidString, revDescription: textView.text, rating: ratingInt, ownerName: "Carl Parson")
        
        var message:String = "Thanks for your product review, it will be published in couple of seconds"
        if isContainsBadWords == true && Settings().settingsReviewConfirmAlertSwitch {
            message = "Thanks for your product review, it will be published soon after review"
        } else {
            ReviewItem.saveReview(review: review)
        }
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "ok", style: .default) { [weak self] (action:UIAlertAction) in
            self?.textView.text = ""
            self?.starRating.rating = 5
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

extension ReviewTableViewController {
    
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



    extension ReviewTableViewController: RecorderViewDelegate {
        func recorderView(recorderView: RecorderView, buttonAction: UIButton) {
            self.textView.resignFirstResponder()
            textView.inputView = .none
            let toolBard = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
            let barButton = UIBarButtonItem(title: "Mic", style: .plain, target: self, action: #selector(showRecordView))
            toolBard.items = [barButton]
            textView.inputAccessoryView = toolBard
            self.textView.becomeFirstResponder()
        }
        
        @objc func showRecordView() {
            self.textView.resignFirstResponder()
            setupRecordView()
            self.textView.becomeFirstResponder()
        }
    }

extension ReviewTableViewController: AudioInstancesDelegate{
    func talking(isTalking: Bool) {
        if let recView = textView.inputView as? RecorderView {
            recView.rec.animate(isTalking)
        }
    }
    
    func audioRecordStarted() {
        
    }
    
    
    func audioRecordStoppedAndDataIsProcessing() {
        
    }
    
    func audioRecordStopped(audioData:Data) {
        try krClient.postRecording(audioData: audioData, completion: {responseData in
            guard let dict = responseData as? [String:Any], let text = dict["text"] as? String, text.count > 0 else {
                return;
            }
            let badwords =   dict["cussWords"] as? [String]
            if badwords != nil && badwords!.count > 0 {
                self.isContainsBadWords = true
            }
            DispatchQueue.main.async {
                self.textView.text = "\(self.textView.text ?? "") \(text)"
            }
        })
    }
    
   
  
}

extension ReviewTableViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        placeholderLabel.isHidden = true
        if textView.inputView is RecorderView {
            audioInstances.toggle()
        }
        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.count == 0 {
            placeholderLabel.isHidden = false
        }
        return true
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.inputView is RecorderView {
            audioInstances.toggle()
        }
    }
}

extension ReviewTableViewController: UIGestureRecognizerDelegate {
    
}


extension UIViewController {
    func navBar() {
        if #available(iOS 15.0, *) {
            let isTransparent = false
            if isTransparent {
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.configureWithTransparentBackground()

                navigationController?.navigationBar.tintColor = .white

                navigationItem.scrollEdgeAppearance = navigationBarAppearance
                navigationItem.standardAppearance = navigationBarAppearance
                navigationItem.compactAppearance = navigationBarAppearance

            } else {
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.configureWithDefaultBackground()

                navigationController?.navigationBar.tintColor = Theme().primaryColor

                navigationItem.scrollEdgeAppearance = navigationBarAppearance
                navigationItem.standardAppearance = navigationBarAppearance
                navigationItem.compactAppearance = navigationBarAppearance
            }

            navigationController?.setNeedsStatusBarAppearanceUpdate()
        }

    }
}


extension UIViewController {
    func showAlert(message:String) {
        let otherAlert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)

        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in
                print("We can run a block of code." )
            }

            otherAlert.addAction(okButton)

        present(otherAlert, animated: true, completion: nil)
    }
}
