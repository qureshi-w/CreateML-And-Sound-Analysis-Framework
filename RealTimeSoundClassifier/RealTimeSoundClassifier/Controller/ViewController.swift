//
//  ViewController.swift
//  SoundClassifier
//
//  Created by Waqar Qureshi.
//  Copyright © 2019 Waqar Qureshi. All rights reserved.
//

// Steps to Make Changes:
// Just Delete the Existing CoreML Model [Remove Reference].
// Drag and Drop the New Model under Sound Classifier

import UIKit
import CoreML
import SoundAnalysis
import AVFoundation
import SwiftyGif

@available(iOS 13.0, *)
class ViewController: UIViewController {
    
    @IBOutlet weak var predictedLabel: UILabel!
    @IBOutlet weak var gifView: UIImageView!
    var speechData : [String] = []
    @IBOutlet weak var btnStart: UIButton!
    
    @IBOutlet weak var count: UILabel!
    // Audio Engine
    var audioEngine = AVAudioEngine()
    
    // Streaming Audio Analyzer
    var streamAnalyzer: SNAudioStreamAnalyzer!
    
    // Serial dispatch queue used to analyze incoming audio buffers.
    let analysisQueue = DispatchQueue(label: "com.apple.AnalysisQueue")
    
    var resultsObserver: ResultsObserver!
    
    // Instantiate the ML Model
    lazy var speechRecognizerClassifier = SpeechRecognizer()
    lazy var model: MLModel = speechRecognizerClassifier.model
    
    
    var timer : Timer!
    var second = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            let gif = try UIImage(gifName: "mic1.gif")
            self.gifView.setGifImage(gif)
        }
        catch{}
        
        gifView.stopAnimatingGif()
        
        // Get the native audio format of the engine's input bus.
        let inputFormat = self.audioEngine.inputNode.inputFormat(forBus: 0)
        
        // Create a new stream analyzer.
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        
        // Create a new observer that will be notified of analysis results.
        // Keep a strong reference to this object.
        resultsObserver = ResultsObserver()
        resultsObserver.vc = self
        
        do {
            // Prepare a new request for the trained model.
            let requestModel = try SNClassifySoundRequest(mlModel: model)
            try streamAnalyzer.add(requestModel, withObserver: resultsObserver)
        } catch {
            print("Unable to prepare request: \(error.localizedDescription)")
            return
        }
        
        // Install an audio tap on the audio engine's input node.
        self.audioEngine.inputNode.installTap(onBus: 0,
                                              bufferSize: 8192, // 8k buffer
        format: inputFormat) { buffer, time in
            // Analyze the current audio buffer.
            self.analysisQueue.async {
                self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
        //  self.startAudioEngine()
        print("Result....")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        predictedLabel.text = ""
        count.text = ""
        btnStart.isUserInteractionEnabled = true
        if let _ = timer{
            timer.invalidate()
        }
        
    }
    
    @IBAction func start(_ sender: Any) {
        
        btnStart.isUserInteractionEnabled = false
        gifView.startAnimatingGif()
        self.speechData.removeAll()
        second = 0
        self.startAudioEngine()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stop), userInfo: nil, repeats: true)
        
    }
    
    // Function to Start Audio Engine for Recording Audio
    func startAudioEngine() {
        do {
            // Start the stream of audio data.
            try self.audioEngine.start()
        } catch {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }
    
    @objc func stop()
    {
        second += 1
        DispatchQueue.main.async {
            self.count.text = "Seconds: \(self.second)"
            
            if self.second == 10
            {
                if let _ = self.timer{
                    self.timer.invalidate()
                    self.timer = nil
                }
                self.gifView.stopAnimatingGif()
                self.performSegue(withIdentifier: "result", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is PieChartViewController
        {
            self.audioEngine.stop()
            second = 0
        
            
            var counts: [String: Int] = [:]
            speechData.forEach { counts[$0, default: 0] += 1 }
            let vc = segue.destination as? PieChartViewController
            vc?.pieChartData = counts
         
        }
    }
}
