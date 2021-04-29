//
//  XCTestCase+Error.swift
//  YoloTests
//
//  Created by Gordon Smith on 28/04/2021.
//

import XCTest

extension XCTestCase {
    func makeError(_ desc: String = "uh oh, something went wrong") -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: desc]
        return NSError(domain: "com.example.error", code: 0, userInfo: userInfo)
    }
}
