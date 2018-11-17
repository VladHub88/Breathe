//
//  BreatheStateMachineConstants.swift
//  Breathe
//
//  Created by Vladyslav Vovk on 11/17/18.
//  Copyright © 2018 Vladyslav Vovk. All rights reserved.
//

import Foundation

struct BreatheStateMachineNotifications {
    static let breatheStateChanged = Notification.Name("BreatheStateMachine.Notifications.BreatheStateChanged")
    static let breathePhaseChanged = Notification.Name("BreatheStateMachine.Notifications.BreathePhaseChanged")
    static let executionTimerUpdated = Notification.Name("ExecutionTimerUpdated")
    static let totalExecutionTimeKey = "totalExecutionTimeLeftKey"
    static let phaseExecutionTimeKey = "phaseExecutionTimeLeftKey"
    static let stateKey = "stateKey"
    static let phaseKey = "phaseKey"
}
