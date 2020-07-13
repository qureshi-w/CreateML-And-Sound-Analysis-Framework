//
//  SoundRecognizerViewController.swift
//  RealTimeSoundClassifier
//
//  Created by Waqar Qureshi on 14/12/2019.
//  Copyright © 2019 Anuj Dutt. All rights reserved.
//

import UIKit
import CoreML
import SoundAnalysis
import AVFoundation

class SoundRecognizerViewController: UIViewController {
    @IBOutlet weak var soundName: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    
    // Audio Engine
    var audioEngine = AVAudioEngine()
    
    // Streaming Audio Analyzer
    var streamAnalyzer: SNAudioStreamAnalyzer!
    
    // Serial dispatch queue used to analyze incoming audio buffers.
    let analysisQueue = DispatchQueue(label: "com.apple")
    
    var resultsObserver: ResultsObserver!
    
    // Instantiate the ML Model
    lazy var ml = sound()
    lazy var model: MLModel = ml.model
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the native audio format of the engine's input bus.
        let inputFormat = self.audioEngine.inputNode.inputFormat(forBus: 1)
        
        // Create a new stream analyzer.
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        
        // Create a new observer that will be notified of analysis results.
        // Keep a strong reference to this object.
        resultsObserver = ResultsObserver()
        resultsObserver.sr = self
        
        do {
            // Prepare a new request for the trained model.
            let requestModel = try SNClassifySoundRequest(mlModel: model)
            try streamAnalyzer.add(requestModel, withObserver: resultsObserver)
        } catch {
            print("Unable to prepare request: \(error.localizedDescription)")
            return
        }
        
        // Install an audio tap on the audio engine's input node.
        self.audioEngine.inputNode.installTap(onBus: 1,
                                              bufferSize: 8192, // 8k buffer
        format: inputFormat) { buffer, time in
            // Analyze the current audio buffer.
            self.analysisQueue.async {
                self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
        do {
            // Start the stream of audio data.
            try self.audioEngine.start()
        } catch {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }
    
}
