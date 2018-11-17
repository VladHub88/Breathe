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
        
        var totalExecutionTimeLeft: TimeInterval = 0
        phasesQueue.filter({ $0.type != .auxiliary }).forEach { breathePhase in
            totalExecutionTimeLeft += breathePhase.duration
        }
        
        totalExecutionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            totalExecutionTimeLeft -= 1
            let userInfo = [BreatheStateMachineNotifications.totalExecutionTimeKey: totalExecutionTimeLeft]
            self.notificationCenter.post(name: BreatheStateMachineNotifications.executionTimerUpdated, object: nil, userInfo: userInfo)
        }
        totalExecutionTimer?.fire()
        executeBreathePhase(at: phasesQueue.startIndex, phasesQueue: phasesQueue)
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        dispatchedBreathePhase?.cancel()
        totalExecutionTimer?.invalidate()
        totalExecutionTimer = nil
        phaseExecutionTimer?.invalidate()
        phaseExecutionTimer = nil
    }
    
    // MARK: - Private
    
    private let phasesQueue: [BreathePhase]
    private var totalExecutionTimer: Timer?
    private var phaseExecutionTimer: Timer?
    private var dispatchedBreathePhase: DispatchWorkItem?
    
    private func executeBreathePhase(at phaseIdx: Int, phasesQueue:[BreathePhase]) {
        guard let phase = phasesQueue[safe: phaseIdx] else {
            print("No phases left in queue")
            stateMachine?.enter(BreatheStateOff.self)
            return
        }
        
        print("Executing phase \(phase.type.rawValue)")
        
        phaseExecutionTimer?.invalidate()
        phaseExecutionTimer = nil
        if phase.type != .auxiliary {
            var phaseExecutionTimeLeft: TimeInterval = phase.duration
            phaseExecutionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                phaseExecutionTimeLeft -= 1
                let userInfo = [BreatheStateMachineNotifications.phaseExecutionTimeKey: phaseExecutionTimeLeft]
                self.notificationCenter.post(name: BreatheStateMachineNotifications.executionTimerUpdated, object: nil, userInfo: userInfo)
            }
            phaseExecutionTimer?.fire()
        }
        
        notificationCenter.post(name: BreatheStateMachineNotifications.breathePhaseChanged, object: nil, userInfo: [BreatheStateMachineNotifications.phaseKey: phase])
        
        let duration = phase.duration
        dispatchedBreathePhase = DispatchWorkItem { [weak self] in
            self?.executeBreathePhase(at: phaseIdx + 1, phasesQueue: phasesQueue)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration, execute: dispatchedBreathePhase!)
    }
}
