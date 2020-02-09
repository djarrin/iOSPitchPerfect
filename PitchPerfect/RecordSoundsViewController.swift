//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by David Jarrin on 1/31/20.
//  Copyright © 2020 David Jarrin. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRecordingUI(recording: false)
    }

    @IBAction func recordAudio(_ sender: Any) {
        configureRecordingUI(recording: true)
        
        // set up file path
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        // start session
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)

        // record audio
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        configureRecordingUI(recording: false)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording failed")
        }
    }
    
    // before moving to the actually performing the segue we need to set some properties
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            // first setting the destination property to the controller we will be using for the next view
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            // Then setting a property for this new class that will contain our info
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    func configureRecordingUI(recording: Bool) {
        recordingLabel.text = recording ? "Recording in Progress" : "Tap to Record"
        recordButton.isEnabled = !recording
        stopRecordingButton.isEnabled = recording
    }
}

