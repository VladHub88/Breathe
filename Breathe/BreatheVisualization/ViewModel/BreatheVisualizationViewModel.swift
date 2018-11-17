//
//  BreatheVisualizationViewModel.swift
//  Breathe
//
//  Created by Vladyslav Vovk on 11/17/18.
//  Copyright © 2018 Vladyslav Vovk. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

struct BreatheAnimationDataStruct {
    let scaleMultiplier: CGFloat
    let duration: TimeInterval
}

class BreatheVisualizationViewModel {
    var breatheStateMachine: BreatheStateMachine?
    let notificationCenter = NotificationCenter.default
    
    var phaseName = BehaviorSubject<String>(value: "")
    var hideTapHintLabel = BehaviorSubject<Bool>(value: true)
    var hideTimerLabels = BehaviorSubject<Bool>(value: false)
    var squareViewBreatheAnimation = BehaviorSubject<BreatheAnimationDataStruct?>(value: nil)
    var squareViewColor = BehaviorSubject<UIColor?>(value: UIColor.green)
    var totalExecutionTimeLeft = BehaviorSubject<String>(value: "00:00")
    var phaseExecutionTimeLeft = BehaviorSubject<String>(value: "00:00")

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
    
    private func countDownString(fromSeconds seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60 % 60
        let seconds = max(0, Int(seconds) % 60)
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    private func subscribeToStateMachineNotifications() {
        notificationCenter.addObserver(forName: BreatheStateMachineNotifications.breatheStateChanged, object: nil, queue: .main) { [weak self] notification in
            guard let breatheState = notification.userInfo?[BreatheStateMachineNotifications.stateKey] as? BreatheState else {
                return
            }
            
            self?.hideTimerLabels.onNext(breatheState is BreatheStateOff)
            self?.hideTapHintLabel.onNext(breatheState is BreatheStateOn)
        }
        
        notificationCenter.addObserver(forName: BreatheStateMachineNotifications.breathePhaseChanged, object: nil, queue: .main) { [weak self] notification in
            guard let breathePhase = notification.userInfo?[BreatheStateMachineNotifications.phaseKey] as? BreathePhase else {
                return
            }

            self?.squareViewColor.onNext(breathePhase.color)
            self?.phaseName.onNext(breathePhase.type.rawValue.uppercased())
            
            switch breathePhase.type {
            case .inhale:
                let breatheAnimation = BreatheAnimationDataStruct(scaleMultiplier: 0.5, duration: breathePhase.duration)
                self?.squareViewBreatheAnimation.onNext(breatheAnimation)
            case .exhale:
                let breatheAnimation = BreatheAnimationDataStruct(scaleMultiplier: 1.0, duration: breathePhase.duration)
                self?.squareViewBreatheAnimation.onNext(breatheAnimation)
            default:
                break
            }
        }
        
        notificationCenter.addObserver(forName: BreatheStateMachineNotifications.executionTimerUpdated, object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }
            if let totalExecutionTimeLeft = notification.userInfo?[BreatheStateMachineNotifications.totalExecutionTimeKey] as? TimeInterval {
                let formattedCountDownString = self.countDownString(fromSeconds: totalExecutionTimeLeft)
                self.totalExecutionTimeLeft.onNext(formattedCountDownString)
            }
            if let phaseExecutionTimeLeft = notification.userInfo?[BreatheStateMachineNotifications.phaseExecutionTimeKey] as? TimeInterval {
                let formattedCountDownString = self.countDownString(fromSeconds: phaseExecutionTimeLeft)
                self.phaseExecutionTimeLeft.onNext(formattedCountDownString)
            }
        }
    }
}
