//
//  SBSpeechRecognizer.swift
//  SBSpeechRecognizer
//
//  Created by Simon Bromberg on 2016-10-10.
//  Copyright © 2016 Bupkis. All rights reserved.
//

import UIKit
import Speech

public protocol SBSpeechRecognizerDelegate: class {
    func speechRecognitionFinished(transcription:String)
    func speechRecognitionPartialResult(transcription:String)
    func speechRecognitionRecordingNotAuthorized()
    func speechRecognitionTimedOut()
}

public class SBSpeechRecognizer: NSObject, SFSpeechRecognizerDelegate {
    public weak var delegate: SBSpeechRecognizerDelegate?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    public override init() {
        super.init()
        
        setupSpeechRecognition()
    }
    
    private func setupSpeechRecognition() {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                if authStatus != .authorized {
                    self.delegate?.speechRecognitionRecordingNotAuthorized()
                }
            }
        }
    }
    
    private var speechRecognitionTimeout: Timer?
    
    public var speechTimeoutInterval: TimeInterval = 2 {
        didSet {
            restartSpeechTimeout()
        }
    }
    
    private func restartSpeechTimeout() {
        speechRecognitionTimeout?.invalidate()
        
        speechRecognitionTimeout = Timer.scheduledTimer(timeInterval:speechTimeoutInterval, target: self, selector: #selector(timedOut), userInfo: nil, repeats: false)
    }
    
    public func startRecording() throws {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.audioEngine.stop()
            self.recognitionTask = nil
            self.recognitionRequest = nil
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            if let result = result {
                isFinal = result.isFinal
                self.delegate?.speechRecognitionPartialResult(transcription: result.bestTranscription.formattedString)
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
            
            if isFinal {
                self.delegate?.speechRecognitionFinished(transcription: result!.bestTranscription.formattedString)
                self.stopRecording()
            }
            else {
                if error == nil {
                    self.restartSpeechTimeout()
                }
                else {
                    // cancel voice recognition
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
    }
    
    @objc private func timedOut() {
        stopRecording()
        
        self.delegate?.speechRecognitionTimedOut()
    }
    
    public func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        speechRecognitionTimeout?.invalidate()
        speechRecognitionTimeout = nil
    }
}
