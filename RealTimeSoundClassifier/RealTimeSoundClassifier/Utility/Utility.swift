//
//  Utility.swift
//  RealTimeSoundClassifier
//
//  Created by Waqar Qureshi on 13/12/2019.
//  Copyright © 2019 Anuj Dutt. All rights reserved.
//

import UIKit

class Utility: NSObject {
    
    static var shared = Utility()
    
    static func getAnlysis(_ data: [String : Int])  -> String
    {
        var total = 0
        for (_, value) in data{
            
            total += value
        }
        
        var pausePer = 0
        if let pause = data[Sound.Pause.rawValue]{
            pausePer =  (100 / total) * pause
        }
        
        if 0 ... 20 ~= pausePer {
            return "You are speaking too fast!! Calm Down :)"
        }
        else  if 20 ... 60 ~= pausePer {
            return "Your are doing Great!! Keep it UP :)"
        }
        else
        {
            return "Your are to slow! Speak Up!! :)"
        }
    }
}

enum VoiceStatus: String
{
    case Fast = "Fast"
    case Intermediate = "Intermediate"
    case Slow = "Slow"
}

enum Sound: String
{
    case Speech = "speach"
    case Pause = "pause"
}
