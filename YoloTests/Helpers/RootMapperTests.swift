//
//  RootMapperTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 26/07/2021.
//

import XCTest
import Yolo

class RootMapperTests: XCTestCase {
    func test_on_init_with_no_state_delivers_default_state() {
        struct AnyEvent: Event { }
        let output = rootMapper(nil, AnyEvent())
        XCTAssertEqual(output, AppState())
    }
    
    func test_on_init_with_state_delivers_given_state() {
        struct AnyEvent: Event { }
        let state = AppState()
        let output = rootMapper(state, AnyEvent())
        XCTAssertEqual(output, state)
    }
}
