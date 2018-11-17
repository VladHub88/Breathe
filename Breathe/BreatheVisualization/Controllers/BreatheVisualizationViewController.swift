//
//  BreatheVisualizationViewController.swift
//  Breathe
//
//  Created by Vladyslav Vovk on 11/17/18.
//  Copyright © 2018 Vladyslav Vovk. All rights reserved.
//

import Foundation
import UIKit

class BreatheVisualizationViewController: UIViewController {
    
    var viewModel: BreatheVisualizationViewModel!
    
    // MARK: - Private
    
    @IBOutlet private weak var squareView: UIView!
    @IBOutlet private weak var squareViewSideLengthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var remainingTitleLabel: UILabel!
    @IBOutlet private weak var remainingValueLabel: UILabel!
    @IBOutlet private weak var phaseNameLabel: UILabel!
    @IBOutlet private weak var phaseRemainingLabel: UILabel!
    
    @IBAction private func handleSquareViewTap(_ sender: UITapGestureRecognizer) {
        viewModel.handleSquareViewTap()
    }
    
}
