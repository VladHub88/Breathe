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
    case auxiliary, hold, inhale, exhale
}

struct BreathePhase {
    let type: BreathePhaseType
    let color: UIColor
    let duration: TimeInterval
}

class BreathePhasesParser {
    class func parse(jsonData: Data) throws -> [BreathePhase] {
        return []
    }
}
