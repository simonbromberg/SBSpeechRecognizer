//
//  ViewController.swift
//  SBSpeechRecognizer
//
//  Created by Simon Bromberg on 10/19/2016.
//  Copyright (c) 2016 Simon Bromberg. All rights reserved.
//

import UIKit
import SBSpeechRecognizer

class ViewController: UIViewController, SBSpeechRecognizerDelegate {

    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var isRecording = false {
        didSet {
            if isRecording {
                activityIndicator.startAnimating()
            }
            else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    private var speechRecognizer: SBSpeechRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = nil
        
        speechRecognizer = SBSpeechRecognizer()
        speechRecognizer.delegate = self
    }
    
    @IBAction func toggleSpeechRecognition() {
        #if targetEnvironment(simulator)
            let alert = UIAlertController(title: "Simulator unsupported", message: "Microphone usage is currently unsupported on the iOS simulator", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        
        #else
        
        isRecording = !isRecording
        updateButtonText()
        
        if isRecording {
            do {
                try speechRecognizer.startRecording()
            }
            catch {
                print(error)
            }
        }
        
        else {
            speechRecognizer.stopRecording()
        }
        
        #endif
    }
    
    func updateButtonText() {
        button.setTitle((isRecording ? "Stop" : "Start") + " Speech Recognition", for: .normal)
    }
    
    // MARK: SBSpeechRecognitionDelegate
    
    func speechRecognitionFinished(transcription:String) {
        self.textView.text = transcription
    }
    
    func speechRecognitionPartialResult(transcription:String) {
        self.textView.text = transcription
    }
    
    func speechRecognitionTimedOut() {
        toggleSpeechRecognition()
    }
    
    func speechRecognitionRecordingNotAuthorized() {
        let alert = UIAlertController(title: "Not authorized", message: "Microphone and speech recognition access must be enabled for this app in order to perform speech recognition. Go to iOS privacy settings to fix this.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

