//
//  StateContainerTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 26/07/2021.
//

import XCTest
import Combine
import Yolo

class StateContainerTests: XCTestCase {

    func test_on_init_emits_initial_state() {
        let state = "initial state"
        let sut = StateContainer<String>(state: state, mapper: { _, _ in state })
        var output: [String] = []
        _ = sut.state
            .sink(receiveValue: { output.append($0) })
        
        XCTAssertEqual(output, [state])
    }
    
    func test_on_init_with_no_initial_state_delivers_reducer_default_state() {
        let state = "mapper state"
        let sut = StateContainer<String>(state: nil, mapper: { _, _ in state })
        var output: [String] = []
        _ = sut.state
            .sink(receiveValue: { output.append($0) })
        
        XCTAssertEqual(output, [state])
    }
    
    func test_on_event_dispatch_delivers_current_state_to_mapper() {
        
        struct AnyEvent: Event { }
        
        let state = "initial state"
        var output: [String?] = []
        let sut = StateContainer<String>(state: state, mapper: { state, _ in output.append(state); return "any" })

        sut.dispatch(AnyEvent())

        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output, [state])
    }
    
    func test_on_event_dispatch_notifies_mapper_of_received_event() {
        
        struct AnyEvent: Event { }
        
        var output: [Event] = []
        let sut = StateContainer<String>(state: "any", mapper: { _, event in output.append(event); return "any" })

        sut.dispatch(AnyEvent())
        XCTAssertEqual(output.count, 1)
        XCTAssertNotNil(output.first as? AnyEvent)
    }
}
