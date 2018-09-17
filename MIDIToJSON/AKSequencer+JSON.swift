//
//  AKSequencer+JSON.swift
//  MIDIToJSON
//
//  Created by Jeff Holtzkener on 2018-09-16.
//  Copyright © 2018 crashingbooth. All rights reserved.
//

import Foundation
import AudioKit


extension AKMIDINoteData {
    func jsonify() -> [String: Any] {
        var json = [String: Any]()
        json["noteNumber"] = noteNumber
        json["velocity"] = velocity
        json["channel"] = channel
        json["position"] = position.beats
        json["duration"] = duration.beats
        
        return json
    }
    
    init?(json: [String : Any]) {
        guard let noteNum = json["noteNumber"] as? MIDINoteNumber,
            let vel = json["velocity"] as? MIDIVelocity,
            let chan = json["channel"] as? MIDIChannel,
            let pos = json["position"] as? Double,
            let dur = json["duration"] as? Double else { return nil }
        self.init(noteNumber: noteNum,
                  velocity: vel,
                  channel: chan,
                  duration: AKDuration(beats: dur),
                  position: AKDuration(beats: pos))
    }
}

extension AKMusicTrack {
    func jsonify() -> [String: Any] {
        let data = getMIDINoteData()
        var result = [String: Any]()
        result["events"] = data.map { $0.jsonify() }
        result["channel"] = !data.isEmpty ? data[0].channel : 0
        return result
    }
    
    func writeTrackFromJSON(_ json: [String: Any]) {
        guard let events = json["events"] as?  [[String: Any]] else {
            AKLog("couldn't parse events")
            return
        }
        let data = events.compactMap { AKMIDINoteData(json: $0) }
        print(data)
        replaceMIDINoteData(with: data)
    }
}

extension AKTimeSignature {
    func jsonify() -> [String : Any] {
        var result = [String : Any]()
        result["topvalue"] = topValue
        result["bottomvalue"] = bottomValue.rawValue
        return result
    }
    
    init?(_ json: [String : Any]) {
        guard let upper = json["topvalue"] as? UInt8,
            let lowerRaw = json["bottomvalue"] as? UInt8,
            let lower = AKTimeSignature.TimeSignatureBottomValue(rawValue: lowerRaw) else { return nil }
        self.init(topValue: upper, bottomValue: lower)
    }
}

extension AKSequencer {
    func jsonifySequence() -> [String: Any]{
        var result = [String: Any]()
        result["tracks"] = jsonifyTracks()
        result["tempos"] = allTempoEvents.map { ["position": $0.0, "tempo": $0.1]}
        result["timesignatures"] = allTimeSignatureEvents.map {["position": $0.0, "event": $0.1.jsonify()] }
        return result
    }
    
    func jsonifyTracks() -> [String : Any] {
        var result = [String : Any] ()
        for (i, track) in tracks.enumerated() {
            if !track.getMIDINoteData().isEmpty {
                let title: String = "track" + String(format: "%03d", i)
                result[title] = track.jsonify()
            }
        }
        
        return result
    }
    
    func parseJSONTracks(json: [String: Any], overWritingTracks: [AKMusicTrack] = [AKMusicTrack]()) -> [AKMusicTrack]? {
        // Tempo Track
        if let tempos = json["tempos"] as? [[String: Double]] {
            parseAndWriteTempos(tempos)
        }
        
        // Time Signatures
        if let timeSigEvents = json["timesignatures"] as? [[String : Any]] {
            parseAndWriteTimeSignatures(timeSigEvents)
        }
        guard let allTracks = json["tracks"] as? [String : Any] else {
            AKLog("Could not parse JSON tracks")
            return nil
        }
        
        
        
        
        var returnTracks = [AKMusicTrack]()
        
        let trackKeys = allTracks.keys.sorted()
        for (i, trackKey) in trackKeys.enumerated() {
            guard let jsonTrack = allTracks[trackKey] as? [String : Any ] else { continue }
            let trk = i < overWritingTracks.count ? overWritingTracks[i] : newTrack()!
            trk.writeTrackFromJSON(jsonTrack)
            returnTracks.append(trk)
        }
        return returnTracks
    }
    
    func parseAndWriteTempos(_ tempos: [[String : Double]]) {
        guard !tempos.isEmpty else {
            AKLog("No tempo events")
            return
        }
        
        // clears events - this event will get overwritten if there is initial tempo event
        setTempo(120)
        for tempoEvent in tempos {
            if let pos = tempoEvent["position"],
                let tempo = tempoEvent["tempo"]  {
                if pos == 0 {
                    setTempo(tempo)
                } else {
                    addTempoEventAt(tempo: tempo, position: AKDuration(beats: pos))
                }
            }
        }
    }
    
    func parseAndWriteTimeSignatures(_ timeSigs: [[String : Any]]) {
        guard !timeSigs.isEmpty else {
            AKLog("No time signature events")
            return
        }
        
        // clear events only on first successful time signature
        var willClearEvents = true
        for event in timeSigs {
            guard let pos = event["position"] as? Double,
                let rawEvent = event["event"] as? [String : Any],
                let timeSig = AKTimeSignature(rawEvent) else { continue }
            
            addTimeSignatureEvent(at: pos, timeSignature: timeSig,  clearExistingEvents: willClearEvents)
            willClearEvents = false
        }
    }
}





