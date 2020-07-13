//
//  ResultsObserver.swift
//  SoundClassifier
//
//  Created by Waqar Qureshi.
//  Copyright © 2019 Waqar Qureshi. All rights reserved.
//
import UIKit
import Foundation
import SoundAnalysis

// Observer object that is called as analysis results are found.
@available(iOS 13.0, *)

class ResultsObserver : NSObject, SNResultsObserving {
    
    weak var vc: ViewController?
    weak var sr: SoundRecognizerViewController?
    
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        
        // Get the top classification.
        guard let result = result as? SNClassificationResult,
            let classification = result.classifications.first else { return }
        
        let confidence = classification.confidence * 100.0
        
        if vc != nil
        {
            var staus = ""
            if classification.identifier ==  Constant.Speach && confidence > 99.5
            {
                staus = "Speaking"
                self.vc?.speechData.append(staus)
            }
            else
            {
                self.vc?.speechData.append(Constant.Pause)
                staus = "Pause"
            }
            DispatchQueue.main.async {
                self.vc?.predictedLabel.text = staus
            }
        }
        else{
            
            DispatchQueue.main.async {
                if confidence > 70
                {   self.sr?.soundName.text = classification.identifier
                    self.sr?.image.image = try! UIImage(imageName: "\(classification.identifier).jpg")
                }
                else{
                    self.sr?.image.image = try! UIImage(imageName: "undecided.jpg")
                    self.sr?.soundName.text = "I am confused"
                }
            }
        }
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}
