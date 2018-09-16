//
//  CustomSequencer.swift
//  MIDIToJSON
//
//  Created by Jeff Holtzkener on 2018-09-16.
//  Copyright © 2018 crashingbooth. All rights reserved.
//

import Foundation
import AudioKit

class CustomSequencer {
    var seq: AKSequencer!
    var callbackInst: AKCallbackInstrument!
    var tracks: [AKMusicTrack]!
    var oscBank: AKOscillatorBank!
    var midiNode: AKMIDINode!
    var mixer: AKMixer!
    let numTracks = 5
    
    init() {
        setUpSequencer()
        setUpOsc()
        
    }
    
    fileprivate func setUpSequencer() {
        seq = AKSequencer()
        tracks = [AKMusicTrack]()
        callbackInst = AKCallbackInstrument()
        callbackInst.callback = callback
        for _ in 0 ..< numTracks {
            let track = seq.newTrack()!
            track.setMIDIOutput(callbackInst.midiIn)
            tracks.append(track)
        }
    }
    
    fileprivate func setUpOsc() {
        oscBank = AKOscillatorBank(waveform: AKTable(.square))
        midiNode = AKMIDINode(node: oscBank)
    }
    
    func callback(_ status: AKMIDIStatus, _ note: MIDINoteNumber, _ vel: MIDIVelocity) {
        if status == .noteOn {
            oscBank.play(noteNumber: note, velocity: vel)
            print(note)
        }  else if status == .noteOff {
            oscBank.stop(noteNumber: note)
        }
    }
    
    
    func play() {
        seq.play()
    }
    
    func stop() {
        seq.stop()
    }
    
    
}
