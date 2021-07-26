//
//  StateContainerTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 26/07/2021.
//

import XCTest
import Combine

class StateContainer<T> {
    private(set) var state: CurrentValueSubject<T, Never>

    init(state: T) {
        self.state = .init(state)
    }
}

class StateContainerTests: XCTestCase {

    func test_on_init_emits_initial_state() {
        let state = "initial state"
        let sut = StateContainer<String>(state: state)
        var output: [String] = []
        _ = sut.state
            .sink(receiveValue: { output.append($0) })
        
        XCTAssertEqual(output, [state])
    }
}
