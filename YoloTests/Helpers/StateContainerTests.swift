//
//  StateContainerTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 26/07/2021.
//

import XCTest
import Combine

typealias StateMapper<T> = (_ state: T?) -> T

class StateContainer<T> {
    private(set) var state: CurrentValueSubject<T, Never>

    init(state: T?, mapper: @escaping StateMapper<T>) {
        if let state = state {
            self.state = .init(state)
        } else {
            self.state = .init(mapper(nil))
        }
    }
}

class StateContainerTests: XCTestCase {

    func test_on_init_emits_initial_state() {
        let state = "initial state"
        let sut = StateContainer<String>(state: state, mapper: { _ in state })
        var output: [String] = []
        _ = sut.state
            .sink(receiveValue: { output.append($0) })
        
        XCTAssertEqual(output, [state])
    }
    
    func test_on_init_with_no_initial_state_delivers_reducer_default_state() {
        let state = "mapper state"
        let sut = StateContainer<String>(state: nil, mapper: { _ in state })
        var output: [String] = []
        _ = sut.state
            .sink(receiveValue: { output.append($0) })
        
        XCTAssertEqual(output, [state])
    }
}
