//
//  RecorderView.swift
//  SSAlexaVoiceService
//
//  Created by Shebin Koshy on 06/04/22.
//  Copyright © 2022 Shebin Koshy. All rights reserved.
//

import UIKit

protocol RecorderViewDelegate {
    func recorderView(recorderView: RecorderView, buttonAction: UIButton)
}

class RecorderView: UIView {
    let kCONTENT_XIB_NAME = "Recorder"
    @IBOutlet var contentView: UIView!
    var delegate: RecorderViewDelegate?
    @IBOutlet var rec: RecordingButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
//        rec.animate(true)
        rec.setTitle(" ", for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    @IBAction func keyboardAction( sender: UIButton) {
        delegate?.recorderView(recorderView: self, buttonAction: sender)
    }
}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
