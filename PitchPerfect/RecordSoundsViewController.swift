//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Khabya on 07/11/19.
//  Copyright © 2019 Khabya. All rights reserved.
//

import UIKit
import AVFoundation // This framework contains the AVAudioRecorder

// A class can inherit from only one super class but it can conform to as many as protocols as we want so here we have AVAudioRecorderDelegate which is used to connect the two pages with the recorded sound.
class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // This below property gives the View Controller the ability to use and reference the audioRecorder in multiple places
    // This is useful because we want to reference the audioRecorder in different functions. One for beginning recording and one when we're stopping recording.
    var audioRecorder: AVAudioRecorder!

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        stopRecordingButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // viewWillAppear code happens right before the root view appears on screen
        print("viewWillAppear called")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // viewDidAppear code is called immediately after the view appears on screen
        
    }

    @IBAction func recordAudio(_ sender: Any) {
        print("record button was pressed")
        recordingLabel.text = "Recording in Progress"
        stopRecordingButton.isEnabled = true
        recordButton.isEnabled = false
        
        // This line is used to get the directory path.
        // Specifically this line of code grab the application's documentDirectory and stores in as a String in the dirPath constant.
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        // The directory path then gets combined wiht the filename for the recording called recordedVoice.wav
        let recordingName = "recordedVoice.wav"
        // The below two lines are the lines that actually combine both the directory path and the recording name to create a full path to our file.
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        print(filePath as Any)
        
        // Here the audio session is setup using 'AVAudioSession.sharedInstance()'
        // The AVAudioSession is needed to either record or playback audio. The AVAudioSession class is basically an abstraction of the entire Audio Hardware. Since there is only one Audio Hardware for device there's only one instance of AVAudioSession. Hence this is why we use the sharedInstance which is the shared AVAudioSession across all apps on the device.
        // The sharedInstance that we access here is a AVAudioSession that's already created by default once our app starts running and it can be used with a minimal amount of setup.
        let session = AVAudioSession.sharedInstance()
        // This line of the code sets up the session for playing and recording audio.
        // One can see the try statement here. Here the exclamation marks indicates that it does not handle any errors if this line to code fails.
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        // The same try code here with same intension.
        // Here we have created a AVAudioRecorder.
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        // This line says that the recordingAudio is the delegate.
        audioRecorder.delegate = self
        // With AVAudioRecorder created, we set the isMeteringEnabled to true, then we prepare to record and then we record.
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        print("stop recording button was pressed")
        recordingLabel.text = "Tap to Record"
        recordButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        
        // The below line stop the audio recorder and set the shared AVAudioSession to inactive
        audioRecorder.stop()
        let audioSesssion = AVAudioSession.sharedInstance()
        try! audioSesssion.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finished recording")
        
        // The audioRecordedDidFinishRecording function receives a 'flag' indicating if saving the recording was successful or not
        if flag {
            // here we need to call the stop recording segue and send along with it the path to our recorded sound.
            // Here we have called the 'stopRecording' segue and send it to the path where the recorded file is located.
            // Here the path is in the form of url but is essentially a regular file path.
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not successful.")
        }
    }
    
    // This function is before Storyboard executes the segue, it will call our RecordSoundsViewController to prepare for that segue. In preparing, the RecordSoundsViewController will store away the path to the recorded audio.
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        // here first we check if this is the segue that we want, that is has to stopRecording identifier that we set up in storyboard.
        if segue.identifier == "stopRecording" {
            // THen we grab the ViewController that were transitioning to the destination from this handy destination property that's part of the segue.
            // Because this property is of type UIViewController, but we know its a PlaySoundsViewController, we can up cast it to a PlaySoundsViewController using a forced up cast.
            let playSoundVC = segue.destination as! PlaySoundsViewController
            // Here we grab the sender which is the recorded audio URL. This may seems a little strange, but if we look back to where we're performing the segue, our sender is indeed the recorded audio URL.
            let recordedAudioURL = sender as! URL
            // Lastly we set the recordedAudioURL in the PlaySoundsViewController. Now the PlaySoundsViewController is receiving the recorded audio URL and we're ready to playback.
            playSoundVC.recordedAudioURL = recordedAudioURL
        }
    }
    
}

// Remember that protocols act as a kind of contract. AVAudioRecorder does not know what classes you have in your app. However, if you say that your class conforms to the AVAudioRecorderDelegate protocol, then it knows it can call a specific function in your class.
// The specific function has been defined in the protocol (in this case, the AVAudioRecorderDelegate protocol). This way your class and the AVAudioRecorder are loosely coupled, and they can work together without having to know much about each other.
