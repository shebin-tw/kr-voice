//
//  AudioBuffer.swift
//  KRVoice
//
//  Created by Shebin Koshy on 12/04/22.
//

import Foundation

import Accelerate
import AVFoundation

protocol AudioBufferDelegate {
    func speaking(isSpeaking:Bool)
}


class AudioBuffer {
    private var audioEngine: AVAudioEngine?
        private var averagePowerForChannel0: Float = 0
        private var averagePowerForChannel1: Float = 0
    let LEVEL_LOWPASS_TRIG:Float32 = 0.30
    var delegate: AudioBufferDelegate?
    
    func buff() {
        audioEngine = AVAudioEngine()
        let inputNode = audioEngine!.inputNode//since i need microphone audio level i have used `inputNode` otherwise you have to use `mainMixerNode`
        let recordingFormat: AVAudioFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {[weak self] (buffer:AVAudioPCMBuffer, when:AVAudioTime) in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.audioMetering(buffer: buffer)
        }
        try? audioEngine?.start()
    }
    
    private func audioMetering(buffer:AVAudioPCMBuffer) {
                buffer.frameLength = 1024
                let inNumberFrames:UInt = UInt(buffer.frameLength)
                if buffer.format.channelCount > 0 {
                    let samples = (buffer.floatChannelData![0])
                    var avgValue:Float32 = 0
                    vDSP_meamgv(samples,1 , &avgValue, inNumberFrames)
                    var v:Float = -100
                    if avgValue != 0 {
                        v = 20.0 * log10f(avgValue)
                    }
                    self.averagePowerForChannel0 = (self.LEVEL_LOWPASS_TRIG*v) + ((1-self.LEVEL_LOWPASS_TRIG)*self.averagePowerForChannel0)
                    self.averagePowerForChannel1 = self.averagePowerForChannel0
                    print("mmmmmmmmmmm=\(self.averagePowerForChannel0)")
                }

                if buffer.format.channelCount > 1 {
                    let samples = buffer.floatChannelData![1]
                    var avgValue:Float32 = 0
                    vDSP_meamgv(samples, 1, &avgValue, inNumberFrames)
                    var v:Float = -100
                    if avgValue != 0 {
                        v = 20.0 * log10f(avgValue)
                    }
                    self.averagePowerForChannel1 = (self.LEVEL_LOWPASS_TRIG*v) + ((1-self.LEVEL_LOWPASS_TRIG)*self.averagePowerForChannel1)
                }
        
                if self.averagePowerForChannel1 < -41 {
                    delegate?.speaking(isSpeaking: true)
                } else {
                    delegate?.speaking(isSpeaking: false)
                }
        }
}
