
//  Created by Shebin Koshy on 2/18/22.
//  Copyright © 2022 Shebin Koshy. All rights reserved.

import Foundation
import AVFoundation

struct Settings {
    
    struct Audio {
//        static let TEMP_FILE_NAME = "KR_iOS.wav"
        static let RECORDING_SETTING =
            [AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 1,
             AVSampleRateKey: 16000.0] as [String : Any]
        
        
    }
    
    var speechToText:SpeechToText = SpeechToText.multipleFile
    
    enum SpeechToText: CaseIterable {
      case multipleFile//oneFile, chunk, 
    }
    
    var profanityFilter: Bool {
        (UserDefaults.standard.object(forKey: settingsFilterSwitchUserDefautlsKey) as? Bool) ?? true
    }
    
    var settingsReviewConfirmAlertSwitch: Bool {
        (UserDefaults.standard.object(forKey: settingsReviewConfirmAlertSwitchUserDefautlsKey) as? Bool) ?? true
    }
}
