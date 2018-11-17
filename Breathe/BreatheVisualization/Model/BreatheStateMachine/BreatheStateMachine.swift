//
//  BreatheStateMachine.swift
//  Breathe
//
//  Created by Vladyslav Vovk on 11/17/18.
//  Copyright © 2018 Vladyslav Vovk. All rights reserved.
//

import GameKit

class BreatheStateMachine {
    private var stateMachine: GKStateMachine!
    
    convenience init?(jsonData: Data) {
        guard let baseBreathePhases = BreathePhasesParser.parse(jsonData: jsonData) else {
            print("Failed to initialize breathe state machine due to incorrect json data provided")
            return nil
        }
        
        let breatheStateOff = BreatheStateOff()
        let breatheStateOn = BreatheStateOn(phasesQueue: baseBreathePhases)
        let breatheStates = [breatheStateOff, breatheStateOn]
        
        self.init(states: breatheStates, initialStateIdx: 0)
    }
    
    init?(states: [BreatheState], initialStateIdx: Int) {
        guard let initialState = states[safe: initialStateIdx] else {
            print("Failed to initialize breathe state machine due to incorrect initial state index.")
            return
        }
        
        stateMachine = GKStateMachine(states: states)
        stateMachine.enter(type(of: initialState))
    }
    
    func handleTap() {
        (stateMachine.currentState as? BreatheState)?.handleTap()
    }
}
