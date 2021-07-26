//
//  RootMapperTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 26/07/2021.
//

import XCTest
import Yolo

let rootMapper: StateMapper<String> = { state, event in
    var state = state ?? "any state"
    
    return state
}

class RootMapperTests: XCTestCase {
    func test_on_init_with_no_state_delivers_default_state() {
        struct AnyEvent: Event { }
        let output = rootMapper(nil, AnyEvent())
        XCTAssertNotNil(output)
    }
}
