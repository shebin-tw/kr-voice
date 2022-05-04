//
//  AudioInstances.swift
//  KRVoice
//
//  Created by Shebin Koshy on 07/04/22.
//

import UIKit
import AVFoundation


protocol AudioInstancesDelegate {
    func audioRecordStarted()
    func audioRecordStoppedAndDataIsProcessing()
    func audioRecordStopped(audioData:Data)
    func talking(isTalking:Bool)
}

class AudioInstances: NSObject {
    private let audioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var isRecording = false
    private var meterTimer: Timer?
    private var recorderApc0: Float = 0
    private var recorderPeak0: Float = 0
    private var lowPassResults: Double = 0
    private var statusForDetection: Double = 0
    private var audioModels = [AudioModel]()
//    private let audioBuffer = AudioBuffer()
    
    var delegate: AudioInstancesDelegate?
    
     override init() {
        super.init()
    }
    
//     init(delegate:AudioInstancesDelegate) {
//        self.delegate = delegate
//    }
    
    func windup(){
        audioRecorder.stop()
        guard let data = self.audioModels.last?.data() else {
            return;
        }
//                let s = saveAudio(data: data, fileName: "sample.wav")
        self.delegate?.audioRecordStopped(audioData:data)
        self.meterTimer?.invalidate()
        self.record()
    }
    
    func record() {
        do {
//            audioBuffer.delegate = self
                    //Start Recording With Audio File name
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "\(UUID().uuidString).wav"
            let fileURL = directory.appendingPathComponent(fileName)
            let fileUrlString = fileURL.absoluteString
            audioModels.append(AudioModel(url: fileUrlString))
            try audioRecorder = AVAudioRecorder(url: fileURL, settings: Settings.Audio.RECORDING_SETTING as [String : AnyObject])
            audioRecorder.delegate = self
//                    recorder = try AVAudioRecorder(url: AudioFileName, settings: settings)
//                    Manager.recorder?.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
//            audioBuffer.buff()
            var timeInterval = 0.01
                    //Tracking Metering values here only
                    meterTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer: Timer) in

                        //Update Recording Meter Values so we can track voice loudness
                        //Getting Recorder from another class
                        //i managed my recorder from Manager class
                        if let recorder = self.audioRecorder
                        {
                            //Start Metering Updates
                            recorder.updateMeters()

                            //Get peak values
                            self.recorderApc0 = recorder.averagePower(forChannel: 0)
                            self.recorderPeak0 = recorder.peakPower(forChannel: 0)
                            
                            
                            var justCame = false
                            if self.recorderPeak0 > -20 {
//                                print("tLKING............")
                                self.delegate?.talking(isTalking: true)
                                timeInterval = 0.50
                                justCame = false
                            } else {
                                self.delegate?.talking(isTalking: false)
//                                print("------NOT=======")
                                if timeInterval == 0.50 {
                                    justCame = true
                                }
                                timeInterval = 0.0
                            }
                            
                            if timeInterval > 5.5 || justCame == true {
//                                []
                                self.windup()
                            }
//                            print("recorderApc0.......\(self.recorderApc0)")
//
//                            print("recorderPeak0.......\(self.recorderPeak0)")
//
//                            //it’s converted to a 0-1 scale, where zero is complete quiet and one is full volume.
//                            let ALPHA: Double = 0.05
//                            let peakPowerForChannel = pow(Double(10), (0.05 * Double(self.recorderPeak0)))
//
//        //                    static var lowPassResults: Double = 0.0
//                            self.lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * self.lowPassResults
//
//                            print(".......\(self.lowPassResults)")
//                            if(self.lowPassResults > 0){
//                                print("Mic blow detected")
//                                //Do what you wanted to do here
//
//                                //if blow is detected update silence value as zero
//                                self.statusForDetection = 0.0
//                            }
//                            else
//                            {
//
//                                //Update Value for Status is blow being detected or not
//                                //As timer is called at interval of 0.10 i.e 0.1 So add value each time in silence Value with 0.1
//                                self.statusForDetection += 0.1
//
//
//                                //if blow is not Detected for 5 seconds
//                                if self.statusForDetection > 2.0 {
//                                    //Update value to zero
//                                    //When value of silence is greater than 5 Seconds
//                                    //Time to Stop recording
//                                    self.statusForDetection = 0.0
//
//                                    //Stop Audio recording
////                                    recorder.stop()
//                                    print("Stop----------------------")
//                                }
//                            }
                        }
                    })

                } catch {
                    //Finish Recording with a Error
                    print("Error Handling: \(error.localizedDescription)")
                    stopRecord()
                }
    }
    
    func stopRecord() {
        meterTimer?.invalidate()
        audioRecorder.stop()
        self.isRecording = false
        self.delegate?.audioRecordStoppedAndDataIsProcessing()
        do {
//            let data =  try Data(contentsOf: audioRecorder.url)
            guard let data = audioModels.last?.data() else {
                return;
            }
//                let s = saveAudio(data: data, fileName: "sample.wav")
            self.delegate?.audioRecordStopped(audioData:data)
        } catch let ex {
            print("KR Client threw an error: \(ex.localizedDescription)")
        }
    }
    
    func toggle() {
        if (self.isRecording) {
            UIApplication.shared.isIdleTimerDisabled = false
            stopRecord()
        } else {
            UIApplication.shared.isIdleTimerDisabled = true
            prepareAudioSession()
            record()
//            audioRecorder.prepareToRecord()
//            audioRecorder.record()
            self.isRecording = true
            self.delegate?.audioRecordStarted()
        }
    }
   
    func saveAudio(data:Data, fileName:String) -> Bool {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            try data.write(to: fileURL)
            print("----fileurl\(fileURL)")
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    
    func prepareAudioSession() {
        do {
//            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let fileURL = directory.appendingPathComponent(Settings.Audio.TEMP_FILE_NAME)
//            try audioRecorder = AVAudioRecorder(url: fileURL, settings: Settings.Audio.RECORDING_SETTING as [String : AnyObject])
//            audioPlayer.delegate = self
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options:[AVAudioSession.CategoryOptions.allowBluetooth, AVAudioSession.CategoryOptions.allowBluetoothA2DP])
        } catch let ex {
            print("Audio session has an error: \(ex.localizedDescription)")
        }
    }
}


extension AudioInstances: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio player is finished playing")
    }
}


extension AudioInstances: AVAudioRecorderDelegate {
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player has an error: \(String(describing: error?.localizedDescription))")
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Audio recorder is finished recording")
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio recorder has an error: \(String(describing: error?.localizedDescription))")
    }
}



extension AudioInstances : AudioBufferDelegate {
    func speaking(isSpeaking: Bool) {
        if isSpeaking == false {
            
        }
    }
    
    
}
