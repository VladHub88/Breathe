//
//  BreatheVisualizationViewModel.swift
//  Breathe
//
//  Created by Vladyslav Vovk on 11/17/18.
//  Copyright © 2018 Vladyslav Vovk. All rights reserved.
//

import Foundation

class BreatheVisualizationViewModel {
    var breatheStateMachine: BreatheStateMachine?
    let notificationCenter = NotificationCenter.default

    init(breathePhasesJsonName: String = "phases") {
        let bundle = Bundle(for: type(of: self))
        let breathePhasesJsonUrl = bundle.url(forResource: breathePhasesJsonName, withExtension: "json")
        if let breathePhasesJsonData = try? Data(contentsOf: breathePhasesJsonUrl!) {
            subscribeToStateMachineNotifications()
            breatheStateMachine = BreatheStateMachine(jsonData: breathePhasesJsonData)
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    func handleSquareViewTap() {
        breatheStateMachine?.handleTap()
    }
    
    // MARK: - Private
    
    private func subscribeToStateMachineNotifications() {
        notificationCenter.addObserver(forName: BreatheStateMachineNotifications.breatheStateChanged, object: nil, queue: .main) { notification in
            guard let breatheState = notification.userInfo?[BreatheStateMachineNotifications.stateKey] else {
                return
            }
            
        }
        
        notificationCenter.addObserver(forName: BreatheStateMachineNotifications.breathePhaseChanged, object: nil, queue: .main) { notification in
            guard let breathePhase = notification.userInfo?[BreatheStateMachineNotifications.phaseKey] else {
                return
            }
            
        }
    }
}
