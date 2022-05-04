//
//  SSSettingsViewController.swift
//  KRVoice
//
//  Created by Shebin Koshy on 12/04/22.
//

import UIKit

let settingsBaseUrlUserDefautlsKey = "settingsBaseUrlUserDefautlsKey"

let settingsFilterSwitchUserDefautlsKey = "settingsFilterSwitchUserDefautlsKey"

let settingsReviewConfirmAlertSwitchUserDefautlsKey = "settingsReviewConfirmAlertSwitchUserDefautlsKey"

let settingsSpeachToTextTypeUserDefautlsKey = "settingsSpeachToTextTypeUserDefautlsKey"

class SSSettingsViewController: UIViewController {
    
    @IBOutlet weak var baseURLTextField: UITextField!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var settingsTextField: UITextField!
    @IBOutlet weak var filterSwitch: UISwitch!
    @IBOutlet weak var badwordAdminApprovalSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = "Ver: \(Bundle.main.appVersionLong) (\(Bundle.main.appBuild)) "
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        settingsTextField.inputView = picker
        defaultValueSetup()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }
    
    @objc func tapAction() {
        self.view.endEditing(true)
    }
    
    func defaultValueSetup() {
        var defaultIP = UserDefaults.standard.object(forKey: settingsBaseUrlUserDefautlsKey) as? String
        if defaultIP == nil {
            defaultIP = "http://192.168.1.6:8080"
            UserDefaults.standard.set(defaultIP, forKey: settingsBaseUrlUserDefautlsKey)
        }
        
        baseURLTextField.text = defaultIP
        
        let settingType = "\(Settings.SpeechToText.allCases.first!)"
        settingsTextField.text = settingType
        
        let isFilterSwitchEnabled: Bool = (UserDefaults.standard.object(forKey: settingsFilterSwitchUserDefautlsKey) as? Bool) ?? true
        filterSwitch.isOn = isFilterSwitchEnabled
        
        let isBadwordAdminApprovalSwitchEnabled: Bool = (UserDefaults.standard.object(forKey: settingsReviewConfirmAlertSwitchUserDefautlsKey) as? Bool) ?? true
        badwordAdminApprovalSwitch.isOn = isBadwordAdminApprovalSwitchEnabled
        
        ifReviewsAreEmptyPrefillWithDefaultReviews()
        
    }
    
    func ifReviewsAreEmptyPrefillWithDefaultReviews() {
        if (ReviewItem.fetchReviews()?.count ?? 0) == 0 {
            let review = ReviewItem(uniqueId: UUID().uuidString, revDescription: "I love Belvita Breakfast Biscuits and always buy them at the grocery store. I decided to order these online and in bulk to save money. The first box I opened was delicious but every box after that was stale, even though the date says they're not expired. They tasted horrible, like they sat in the sun or something. There has to be something that happened to these boxes that made the food inside them change. I'm going to feed them to the ducks at the park. I will stick to the grocery store but I am glad I tried online food, I needed to know.", rating: 1, ownerName: "Lisa D")
            ReviewItem.saveReview(review: review)
//            let review2 = ReviewItem(uniqueId: UUID().uuidString, revDescription: "Let me start of by saying that I enjoyed the original golden oat and cinnamon brown sugar flavors quite a bit, but didn't like the fruity flavors at all. There are 2 golden oat and 2 blueberry boxes in this 6 box variety pack. While the golden oat is the original and having 2 of them makes sense, the blueberry ones were absolutely unneeded. Still, taste is a matter of personal preference. I just found out that there are more flavors that are not included in this set. I would prefer having 6 different boxes in the variety set, instead of 2 golden oat and 2 blueberry. So I can try all the flavors with one set and choose only the ones I like in the future.", rating: 3, ownerName: "David S.")
//            ReviewItem.saveReview(review: review2)
            
            let review3 = ReviewItem(uniqueId: UUID().uuidString, revDescription: "Thanks to my son I now have a major addiction to these. He buys them for his children (toddlers) so I decided to buy some to keep on hand. The buying part has gone better than the \"keeping on hand\" part - boy, these things just jump off the shelf and into my hand. They are delicious. The coconut flavor is just right - sort of coconut / nutty - light and crispy. (Also find I love the cranberry orange - wouldn't have guessed but it's a great flavor.)", rating: 4, ownerName: "Davkevnic")
            ReviewItem.saveReview(review: review3)
            
            
        }
    }
    
    @IBAction func startAction() {
        let baseURL = baseURLTextField.text ?? ""
        UserDefaults.standard.set(baseURL, forKey: settingsBaseUrlUserDefautlsKey)
        
        UserDefaults.standard.set(filterSwitch.isOn, forKey: settingsFilterSwitchUserDefautlsKey)
        
        UserDefaults.standard.set(badwordAdminApprovalSwitch.isOn, forKey: settingsReviewConfirmAlertSwitchUserDefautlsKey)
        
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTableViewController")
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    @IBAction func clearAllData() {
        UserDefaults.standard.removeObject(forKey: reviewsUserDefautlsKey)
    }

}

extension SSSettingsViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Settings.SpeechToText.allCases.count
    }
    
}

extension SSSettingsViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let caseN: Settings.SpeechToText = Settings.SpeechToText.allCases[row]
        let name = "\(caseN)"
        return name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let caseN: Settings.SpeechToText = Settings.SpeechToText.allCases[row]
        let settingType = "\(caseN)"
        settingsTextField.text = settingType
    }
}

extension Bundle {
    public var appName: String { getInfo("CFBundleName")  }
    public var displayName: String {getInfo("CFBundleDisplayName")}
    public var language: String {getInfo("CFBundleDevelopmentRegion")}
    public var identifier: String {getInfo("CFBundleIdentifier")}
    public var copyright: String {getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\\\n", with: "\n") }
    
    public var appBuild: String { getInfo("CFBundleVersion") }
    public var appVersionLong: String { getInfo("CFBundleShortVersionString") }
    //public var appVersionShort: String { getInfo("CFBundleShortVersion") }
    
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }
}
