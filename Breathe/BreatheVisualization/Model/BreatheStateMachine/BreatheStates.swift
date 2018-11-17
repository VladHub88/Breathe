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
        executeBreathePhase(at: phasesQueue.startIndex, phasesQueue: phasesQueue)
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        currentPhaseIdx = nil
        dispatchedBreathePhase?.cancel()
        phaseExecutionTimer?.invalidate()
        phaseExecutionTimer = nil
    }
    
    // MARK: - Private
    
    private let phasesQueue: [BreathePhase]
    private var phaseExecutionTimer: Timer?
    private var dispatchedBreathePhase: DispatchWorkItem?
    private var currentPhaseIdx: Int? = nil
    
    private func executeBreathePhase(at phaseIdx: Int, phasesQueue:[BreathePhase]) {
        guard let phase = phasesQueue[safe: phaseIdx] else {
            print("No phases left in queue")
            stateMachine?.enter(BreatheStateOff.self)
            return
        }
        
        print("Executing phase \(phase.type.rawValue)")
        
        currentPhaseIdx = phaseIdx
        phaseExecutionTimer?.invalidate()
        phaseExecutionTimer = nil
        if !phase.isAuxiliary {
            var futurePhasesExecutionTime: TimeInterval = 0
            phasesQueue[phaseIdx + 1..<phasesQueue.count].filter({ $0.type != .auxiliaryStart && $0.type != .auxiliaryEnd }).forEach { breathePhase in
                futurePhasesExecutionTime += breathePhase.duration
            }
            
            var phaseExecutionTimeLeft: TimeInterval = phase.duration
            phaseExecutionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                phaseExecutionTimeLeft -= 1
                let totalExecutionTimeLeft: TimeInterval = phaseExecutionTimeLeft + futurePhasesExecutionTime
                let userInfo: [AnyHashable : Double] = [BreatheStateMachineNotifications.totalExecutionTimeKey: totalExecutionTimeLeft,
                                BreatheStateMachineNotifications.phaseExecutionTimeKey: phaseExecutionTimeLeft]
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
