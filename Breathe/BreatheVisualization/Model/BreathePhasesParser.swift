//
//  BreathePhasesParser.swift
//  Breathe
//
//  Created by Vladyslav Vovk on 11/17/18.
//  Copyright © 2018 Vladyslav Vovk. All rights reserved.
//

import Foundation
import UIKit

enum BreathePhaseType: String {
    case auxiliaryStart, auxiliaryEnd, hold, inhale, exhale
}

struct BreathePhase {
    let type: BreathePhaseType
    let color: UIColor
    let duration: TimeInterval
    
    var isAuxiliary: Bool {
        return type == .auxiliaryStart || type == .auxiliaryEnd
    }
}

class BreathePhasesParser {
    class func parse(jsonData: Data) -> [BreathePhase]? {
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] else {
            print("Failed to deserialize breathe phases from given json data.")
            return nil
        }
        
        let result = json?.compactMap({ phaseJson -> BreathePhase? in
            guard let typeString = phaseJson[Constants.typeKey] as? String,
                let type = BreathePhaseType(rawValue: typeString),
                let duration = phaseJson[Constants.durationKey] as? TimeInterval,
                let colorHex = phaseJson[Constants.colorKey] as? String else {
                
                print("Failed to parse breathe phase with json: \(phaseJson)")
                return nil
            }
            
            return BreathePhase(type: type, color: UIColor(hexString: colorHex), duration: duration)
        })

        return result
    }
    
    // MARK: - Private
    
    private struct Constants {
        static let typeKey = "type"
        static let durationKey = "duration"
        static let colorKey = "color"
    }
}
