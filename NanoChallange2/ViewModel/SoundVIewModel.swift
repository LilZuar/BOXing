//
//  SoundVIewModel.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 26/05/24.
//

import AVFoundation

class SoundPlayer {
    var player: AVAudioPlayer?
    
    func playSound(soundName: String, soundExtension: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: soundExtension) else {
            print("Sound file not found.")
            print(soundName)
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func playEffect(soundName: String, soundExtension: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: soundExtension) else {
            print("Sound file not found.")
            print(soundName)
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.numberOfLoops = 1
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    
    func stopSound() {
            player?.stop()
        }
}
