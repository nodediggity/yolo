//
//  UIView+LayoutCycle.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}

func executeRunLoopToCleanUpReferences() {
    RunLoop.current.run(until: Date())
}
