//
//  AudioModel.swift
//  KRVoice
//
//  Created by Shebin Koshy on 11/04/22.
//

import Foundation

class AudioModel {
    let url: String?
    var uploaded: Bool = false
    
    init(url: String) {
        self.url = url
    }
    
    func data() -> Data? {
        guard let urlString = url else {
            return nil
        }
        guard let url1 = URL(string: urlString) else { return  nil }
//        guard let url1 = URL(fileURLWithPath: urlString) else {
//            return nil
//        }
        do {
            let data =  try Data(contentsOf: url1)
//                let s = saveAudio(data: data, fileName: "sample.wav")
//            self.delegate?.audioRecordStopped(audioData:data)
            return data
        } catch let ex {
            print("KR Client threw an error: \(ex.localizedDescription)")
        }
        return nil
    }
}
