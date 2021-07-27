//
//  FeedMapperTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 27/07/2021.
//

import XCTest
import Yolo

struct FeedState: Equatable { }

let feedMapper: StateMapper<FeedState> = { state, event in
    FeedState()
}

class FeedMapperTests: XCTestCase {

    func test_on_init_with_no_state_delivers_default_state() {
        struct AnyEvent: Event { }
        let output = feedMapper(nil, AnyEvent())
        XCTAssertEqual(output, FeedState())
    }

}
