//
//  BreatheVisualizationViewController.swift
//  Breathe
//
//  Created by Vladyslav Vovk on 11/17/18.
//  Copyright © 2018 Vladyslav Vovk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BreatheVisualizationViewController: UIViewController {
    
    var viewModel: BreatheVisualizationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe(viewModel: viewModel)
    }
    
    // MARK: - Private
    
    private var disposeBag = DisposeBag()
    private var originalSquareViewTransform: CGAffineTransform!
    
    @IBOutlet private weak var squareView: UIView! {
        didSet {
            squareView.layer.borderWidth = 1
            squareView.layer.borderColor = UIColor.black.cgColor
            originalSquareViewTransform = squareView.transform
        }
    }
    @IBOutlet private weak var squareViewSideLengthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tapHereToBreatheLabel: UILabel!
    @IBOutlet private weak var remainingTimeStackView: UIStackView!
    @IBOutlet private weak var remainingTitleLabel: UILabel!
    @IBOutlet private weak var remainingValueLabel: UILabel!
    @IBOutlet private weak var phaseDescriptionStackView: UIStackView!
    @IBOutlet private weak var phaseNameLabel: UILabel!
    @IBOutlet private weak var phaseRemainingLabel: UILabel!
    
    @IBAction private func handleSquareViewTap(_ sender: UITapGestureRecognizer) {
        viewModel.handleSquareViewTap()
    }
    
    private func subscribe(viewModel: BreatheVisualizationViewModel) {
        viewModel.hideTimerLabels.bind(to: phaseDescriptionStackView.rx.isHidden).disposed(by: disposeBag)
        viewModel.hideTimerLabels.bind(to: remainingTimeStackView.rx.isHidden).disposed(by: disposeBag)
        viewModel.hideTapHintLabel.bind(to: tapHereToBreatheLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.phaseName.bind(to: phaseNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.totalExecutionTimeLeft.bind(to: remainingValueLabel.rx.text).disposed(by: disposeBag)
        viewModel.phaseExecutionTimeLeft.bind(to: phaseRemainingLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.squareViewColor.asObserver().subscribe(onNext: { [weak self] color in
            self?.squareView.backgroundColor = color
        }).disposed(by: disposeBag)
        
        viewModel.squareViewBreatheAnimation.asObserver().subscribe(onNext: { [weak self] breatheAnimation in
            guard let self = self, let breatheAnimation = breatheAnimation else { return }
            let scaledTransform = self.originalSquareViewTransform.scaledBy(x: breatheAnimation.scaleMultiplier, y: breatheAnimation.scaleMultiplier)
            UIView.animate(withDuration: breatheAnimation.duration, animations: {
                self.squareView.transform = scaledTransform
            })
        }).disposed(by: disposeBag)
    }
}
