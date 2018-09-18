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
    var mixer: AKMixer!
    let numTracks = 5
    
    init() {
        setUpSequencer()
        setUpSound()
        
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
    
    fileprivate func setUpSound() {
        mixer = AKMixer()
        AudioKit.output = mixer
        oscBank = AKOscillatorBank(waveform: AKTable(.square))
        oscBank >>> mixer
        do { try AudioKit.start()
        } catch {
            fatalError()
        }
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
    
    func clear() {
        seq.stop()
        setUpSequencer()
    }
    
    func loadFromURL(_ url: URL) {
        seq.loadMIDIFile(fromURL: url)
    }

}

extension CustomSequencer: SequencerDelegate {
    func loadFileFromJSON(_ json: [String : Any]) {
        clear()
        _ = seq.parseJSONTracks(json: json)
        
        for track in tracks {
           track.setMIDIOutput(callbackInst.midiIn)
        }
        
        seq.disableLooping()
    }
    
    func getSequencerJSON() -> [String : Any] {
        return seq.jsonifySequence()
    }
}

