//
//  SpeechRecognitionView.swift
//  SpeechRecognizerExample
//
//  Created by Simon Bromberg on 2023-12-01.
//

import SBSpeechRecognizer
import SwiftUI

class SpeechObserver: ObservableObject, SBSpeechRecognizerDelegate {
  func speechRecognitionFinished(transcription: String) {
    self.transcription = transcription
  }

  func speechRecognitionPartialResult(transcription: String) {
    self.transcription = transcription
  }

  func speechRecognitionRecordingNotAuthorized() {
    print(#function)
  }

  func speechRecognitionTimedOut() {
    timedOut = true
  }

  private let speechRecognizer: SBSpeechRecognizer

  @Published var transcription: String = ""
  @Published var timedOut: Bool = false

  func start() throws {
    timedOut = false
    try speechRecognizer.startRecording()
  }

  func stop() {
    timedOut = false
    speechRecognizer.stopRecording()
  }

  init() {
    speechRecognizer = SBSpeechRecognizer()
    speechRecognizer.delegate = self
  }
}

struct SpeechRecognitionView: View {
  @State private var isRecording = false {
    didSet {
      do {
        try isRecording ? speechObserver.start() : speechObserver.stop()
      } catch {
        print(error)
      }
    }
  }

  @ObservedObject private var speechObserver = SpeechObserver()

  var body: some View {
    VStack {
      Button("\(isRecording ? "Stop" : "Start") Speech Recognition") {
        isRecording.toggle()
      }
      ProgressView()
        .opacity(isRecording ? 1 : 0)
      Text(speechObserver.transcription)
    }
    .padding()
    .onChange(of: speechObserver.timedOut) {
      if speechObserver.timedOut {
        isRecording = false
      }
    }
  }
}

#Preview {
  SpeechRecognitionView()
}
