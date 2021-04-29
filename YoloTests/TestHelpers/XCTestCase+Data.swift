//
//  XCTestCase+Data.swift
//  YoloTests
//
//  Created by Gordon Smith on 28/04/2021.
//

import XCTest

extension XCTestCase {
    func makeData(_ value: String = "") -> Data {
        Data(value.utf8)
    }
}
