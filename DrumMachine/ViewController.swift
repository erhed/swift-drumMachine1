//
//  ViewController.swift
//  DrumMachine
//
//  Created by Erik on 2019-03-05.
//  Copyright © 2019 Erik. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var positionArray: [Pad] = []
    var kickDrumArray: [Pad] = []
    var openHHArray: [Pad] = []
    var closedHHArray: [Pad] = []
    var snareArray: [Pad] = []
    
    var soundPlayers: [AVAudioPlayer] = []
    var url = Bundle.main.url(forResource: "Samples/Kick", withExtension: "wav")
    
    var safeSpace: CGFloat = 0
    var tileSpace: CGFloat = 0
    var padSizeX: CGFloat = 0
    
    var isPlaying: Bool = false
    var playButton: UIButton = UIButton()
    var patternPosition: Int = 0
    var playTimer: Timer = Timer()
    
    let colorInactive: UIColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
    let colorActive: UIColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
    let colorInactivePosition: UIColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)
    let colorInactiveBeat: UIColor = UIColor(red: 42/255, green: 42/255, blue: 42/255, alpha: 1)
    let colorBPM: UIColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        safeSpace = (self.view.frame.width / 16)
        tileSpace = self.view.frame.width / 128
        padSizeX = (self.view.frame.width / 16) - tileSpace - (tileSpace / 16) - (safeSpace / 8)
        
        drawLabels()
        drawResetButton()
        drawPlayStopButton()
        drawBpmButton()
        
        drawPads(type: "Position")
        drawPads(type: "KickDrum")
        drawPads(type: "OpenHiHat")
        drawPads(type: "ClosedHiHat")
        drawPads(type: "Snare")
        
        // Remove finished audio players every X seconds
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(removeUnusedPlayers), userInfo: nil, repeats: true)
    }
    
    //
    // Draw UI
    //
    
    func drawBpmButton() {
        let resetButton = UIButton(frame: CGRect(x: self.view.frame.width - (safeSpace + tileSpace) - 75 - 94,
                                                 y: (self.view.frame.height / 22) * 3,
                                                 width: 100,
                                                 height: 40))
        resetButton.setTitle("120 BPM", for: .normal)
        resetButton.setTitleColor(colorBPM, for: .normal)
        resetButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 22.0)
        resetButton.titleLabel?.textAlignment = .right
        
        resetButton.addTarget(self, action: #selector(reset(_:)), for: .touchDown)
        view.addSubview(resetButton)
    }
    
    func drawResetButton() {
        let resetButton = UIButton(frame: CGRect(x: self.view.frame.width - (safeSpace + tileSpace) - 75 - 190,
                                            y: (self.view.frame.height / 22) * 3,
                                            width: 100,
                                            height: 40))
        resetButton.setTitle("RESET", for: .normal)
        resetButton.setTitleColor(.red, for: .normal)
        resetButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 22.0)
        resetButton.titleLabel?.textAlignment = .right
        
        resetButton.addTarget(self, action: #selector(reset(_:)), for: .touchDown)
        view.addSubview(resetButton)
    }
    
    func drawPlayStopButton() {
        playButton = UIButton(frame: CGRect(x: self.view.frame.width - (safeSpace + tileSpace) - 75,
                                            y: (self.view.frame.height / 22) * 3,
                                            width: 100,
                                            height: 40))
        playButton.setTitle("PLAY", for: .normal)
        playButton.setTitleColor(.white, for: .normal)
        playButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 22.0)
        playButton.titleLabel?.textAlignment = .right
        
        playButton.addTarget(self, action: #selector(playStop(_:)), for: .touchDown)
        view.addSubview(playButton)
    }
    
    func drawLabels() {
        // TITLE
        let title = UILabel(frame: CGRect(x: safeSpace + tileSpace,
                                          y: (self.view.frame.height / 22) * 2,
                                          width: 800,
                                          height: 60))
        title.textAlignment = .left
        title.textColor = UIColor.red
        title.font = UIFont(name: "HelveticaNeue-UltraLight",
                            size: 46.0)
        title.text = "DrumPF"
        self.view.addSubview(title)
        
        // KICK
        let kick = UILabel(frame: CGRect(x: safeSpace + tileSpace,
                                         y: (self.view.frame.height / 22) * 7 - 19,
                                         width: 200,
                                         height: 21))
        kick.textAlignment = .left
        kick.textColor = UIColor.white
        kick.font = UIFont(name: "HelveticaNeue-Thin",
                           size: 14.0)
        kick.text = "BASS DRUM"
        self.view.addSubview(kick)
        
        // OPEN
        let ohh = UILabel(frame: CGRect(x: safeSpace + tileSpace,
                                        y: (self.view.frame.height / 22) * 10 - 19,
                                        width: 200,
                                        height: 21))
        ohh.textAlignment = .left
        ohh.textColor = UIColor.white
        ohh.font = UIFont(name: "HelveticaNeue-Thin",
                          size: 14.0)
        ohh.text = "OPEN HI-HAT"
        self.view.addSubview(ohh)
        
        // CLOSED
        let chh = UILabel(frame: CGRect(x: safeSpace + tileSpace,
                                        y: (self.view.frame.height / 22) * 13 - 19,
                                        width: 200,
                                        height: 21))
        chh.textAlignment = .left
        chh.textColor = UIColor.white
        chh.font = UIFont(name: "HelveticaNeue-Thin",
                          size: 14.0)
        chh.text = "CLOSED HI-HAT"
        self.view.addSubview(chh)
        
        // SNARE
        let snare = UILabel(frame: CGRect(x: safeSpace + tileSpace,
                                          y: (self.view.frame.height / 22) * 16 - 19,
                                          width: 200,
                                          height: 21))
        snare.textAlignment = .left
        snare.textColor = UIColor.white
        snare.font = UIFont(name: "HelveticaNeue-Thin",
                            size: 14.0)
        snare.text = "SNARE"
        self.view.addSubview(snare)
        
    }
    
    func drawPads(type: String) {
        
        var padSizeY: CGFloat = (self.view.frame.width / 16) - tileSpace - (tileSpace / 16) - (safeSpace / 8)
        var y_position: CGFloat = 0
        
        switch (type) {
        case "Position":
            y_position = (self.view.frame.height / 22) * 19
        case "KickDrum":
            y_position = (self.view.frame.height / 22) * 7
        case "OpenHiHat":
            y_position = (self.view.frame.height / 22) * 10
        case "ClosedHiHat":
            y_position = (self.view.frame.height / 22) * 13
        case "Snare":
            y_position = (self.view.frame.height / 22) * 16
        default:
            return
        }
        
        if type == "Position" {
            padSizeY = padSizeX / 4
        }
        
        for index in 0...15 {
            let pad = Pad()
            pad.frame = CGRect(x: safeSpace + tileSpace + (tileSpace * CGFloat(index)) + (padSizeX * CGFloat(index)),
                               y: y_position,
                               width: padSizeX,
                               height: padSizeY)
            pad.tag = index
            
            view.addSubview(pad)
            
            if type != "Position" {
                if (index + 1) == 1 || (index % 4) == 0 {
                    pad.backgroundColor = colorInactiveBeat
                }
                else {
                    pad.backgroundColor = colorInactive
                }
            }
            
            if type == "Position" {
                pad.backgroundColor = colorInactivePosition
                positionArray.append(pad)
            }
            
            if type == "KickDrum" {
                pad.addTarget(self, action: #selector(kickDrumHandler(_:)), for: .touchDown)
                kickDrumArray.append(pad)
            }
            
            if type == "OpenHiHat" {
                pad.addTarget(self, action: #selector(openHHHandler(_:)), for: .touchDown)
                openHHArray.append(pad)
            }
            
            if type == "ClosedHiHat" {
                pad.addTarget(self, action: #selector(closedHHHandler(_:)), for: .touchDown)
                closedHHArray.append(pad)
            }
            
            if type == "Snare" {
                pad.addTarget(self, action: #selector(snareHandler(_:)), for: .touchDown)
                snareArray.append(pad)
            }
            
        }
    }
    
    //
    // Button actions
    //
    
    @objc func reset(_ sender: UIButton) {
        for index in 0...15 {
            kickDrumArray[index].active = false
            openHHArray[index].active = false
            closedHHArray[index].active = false
            snareArray[index].active = false
            
            if (index + 1) == 1 || (index % 4) == 0 {
                kickDrumArray[index].backgroundColor = colorInactiveBeat
                openHHArray[index].backgroundColor = colorInactiveBeat
                closedHHArray[index].backgroundColor = colorInactiveBeat
                snareArray[index].backgroundColor = colorInactiveBeat
            }
            else {
                kickDrumArray[index].backgroundColor = colorInactive
                openHHArray[index].backgroundColor = colorInactive
                closedHHArray[index].backgroundColor = colorInactive
                snareArray[index].backgroundColor = colorInactive
            }
        }
    }
    
    @objc func playStop(_ sender: UIButton) {
        if isPlaying {
            playTimer.invalidate()
            playButton.setTitle("PLAY", for: .normal)
            isPlaying = !isPlaying
            patternPosition = 0
            for position in positionArray {
                position.backgroundColor = colorInactivePosition
            }
        }
        else if !isPlaying {
            playTimer = Timer.scheduledTimer(timeInterval: 0.125, target: self, selector: #selector(play), userInfo: nil, repeats: true)
            playButton.setTitle("STOP", for: .normal)
            isPlaying = !isPlaying
        }
    }
    
    //
    // Pattern handlers
    //
    
    @objc func kickDrumHandler(_ sender: Pad) {
        if sender.active {
            kickDrumArray[sender.tag].backgroundColor = colorInactive
            kickDrumArray[sender.tag].active = !kickDrumArray[sender.tag].active
        }
        else if !sender.active {
            kickDrumArray[sender.tag].backgroundColor = colorActive
            kickDrumArray[sender.tag].active = !kickDrumArray[sender.tag].active
        }
    }
    
    @objc func openHHHandler(_ sender: Pad) {
        if sender.active {
            openHHArray[sender.tag].backgroundColor = colorInactive
            openHHArray[sender.tag].active = !openHHArray[sender.tag].active
        }
        else if !sender.active {
            openHHArray[sender.tag].backgroundColor = colorActive
            openHHArray[sender.tag].active = !openHHArray[sender.tag].active
        }
    }
    
    @objc func closedHHHandler(_ sender: Pad) {
        if sender.active {
            closedHHArray[sender.tag].backgroundColor = colorInactive
            closedHHArray[sender.tag].active = !closedHHArray[sender.tag].active
        }
        else if !sender.active {
            closedHHArray[sender.tag].backgroundColor = colorActive
            closedHHArray[sender.tag].active = !closedHHArray[sender.tag].active
        }
    }
    
    @objc func snareHandler(_ sender: Pad) {
        if sender.active {
            snareArray[sender.tag].backgroundColor = colorInactive
            snareArray[sender.tag].active = !snareArray[sender.tag].active
        }
        else if !sender.active {
            snareArray[sender.tag].backgroundColor = colorActive
            snareArray[sender.tag].active = !snareArray[sender.tag].active
        }
    }
    
    //
    // Play sounds
    //
    
    @objc func play() {
        
        // PLAY?
        if kickDrumArray[patternPosition].active {
            playSound(sound: "Samples/Kick", vol: 0.7)
        }
        if openHHArray[patternPosition].active {
            playSound(sound: "Samples/OHH", vol: 0.8)
        }
        if closedHHArray[patternPosition].active {
            playSound(sound: "Samples/CHH", vol: 0.1)
        }
        if snareArray[patternPosition].active {
            playSound(sound: "Samples/Snare2", vol: 0.7)
        }
        
        positionArray[patternPosition].backgroundColor = UIColor.yellow
        
        if patternPosition > 0 {
                positionArray[patternPosition - 1].backgroundColor = colorInactivePosition
        }
        else if patternPosition == 0 {
                positionArray[15].backgroundColor = colorInactivePosition
        }
        
        patternPosition = patternPosition + 1
        
        if patternPosition == 16 {
            patternPosition = 0
        }
    }
    
    func playSound(sound: String, vol: Float) {
        do {
            // Sets path to sound
            url = Bundle.main.url(forResource: sound, withExtension: "wav")
            // Create new sound player for every hit (timer removes finished players)
            let soundPlayer = try AVAudioPlayer(contentsOf: url!)
            soundPlayer.numberOfLoops = 0
            soundPlayer.volume = vol
            soundPlayer.play()
            soundPlayers.append(soundPlayer)
        } catch {
            print(error)
        }
    }
    
    @objc func removeUnusedPlayers() {
        print("Sound players active: \(soundPlayers.count)")
        for player in soundPlayers {
            if player.isPlaying { continue }
            else {
                if let index = soundPlayers.index(of: player) {
                    soundPlayers.remove(at: index)
                }
            }
        }
    }
}

// Adds "active" boolean property to UIButton (Pad)
class Pad: UIButton {
    var active: Bool
    override init(frame: CGRect) {
        active = false
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
