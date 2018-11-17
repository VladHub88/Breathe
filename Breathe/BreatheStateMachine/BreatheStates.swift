//
//  BreatheStates.swift
//  Breathe
//
//  Created by Vladyslav Vovk on 11/17/18.
//  Copyright © 2018 Vladyslav Vovk. All rights reserved.
//

import Foundation
import GameKit

class BreatheState: GKState {
    let notificationCenter: NotificationCenter
    
    init(notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.notificationCenter = notificationCenter
    }
    
    func handleTap() {
        print("Handling user tap while in \(String(describing: self)) state")
    }
    
    override func didEnter(from previousState: GKState?) {
        print("\(String(describing: self)) did enter")
        notificationCenter.post(name: BreatheStateMachineNotifications.breatheStateChanged, object: nil, userInfo: [BreatheStateMachineNotifications.stateKey: self])
    }
    
    override func willExit(to nextState: GKState) {
        print("\(String(describing: self)) will exit")
    }
}

class BreatheStateOff: BreatheState {
    override func handleTap() {
        super.handleTap()
        stateMachine?.enter(BreatheStateOn.self)
    }
}

class BreatheStateOn: BreatheState {
    init(phasesQueue: [BreathePhase]) {
        self.phasesQueue = phasesQueue
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        executionTimer = Timer(fire: Date(), interval: 1, repeats: true, block: { timer in
            // TODO: Handle execution timer
        })
        executeBreathePhase(at: phasesQueue.startIndex, phasesQueue: phasesQueue)
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        dispatchedBreathePhase?.cancel()
        executionTimer?.invalidate()
        executionTimer = nil
    }
    
    // MARK: - Private
    
    private let phasesQueue: [BreathePhase]
    private var executionTimer: Timer?
    private var dispatchedBreathePhase: DispatchWorkItem?
    
    private func executeBreathePhase(at phaseIdx: Int, phasesQueue:[BreathePhase]) {
        guard let phase = phasesQueue[safe: phaseIdx] else {
            print("No phases left in queue")
            stateMachine?.enter(BreatheStateOff.self)
            return
        }
        
        print("Executing phase \(phase.type.rawValue)")
        notificationCenter.post(name: BreatheStateMachineNotifications.breathePhaseChanged, object: nil, userInfo: [BreatheStateMachineNotifications.phaseKey: phase])
        
        let duration = phase.duration
        dispatchedBreathePhase = DispatchWorkItem { [weak self] in
            self?.executeBreathePhase(at: phaseIdx + 1, phasesQueue: phasesQueue)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration, execute: dispatchedBreathePhase!)
    }
}
