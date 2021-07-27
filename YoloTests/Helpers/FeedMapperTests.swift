//
//  FeedMapperTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 27/07/2021.
//

import XCTest
import Yolo
import OrderedCollections

struct FeedState: Equatable {
    var items: OrderedDictionary<String, FeedItem> = [:]
}

let feedMapper: StateMapper<FeedState> = { state, event in
    var state = state ?? FeedState()
    
    if let event = event as? FeedLoadedEvent {
        event.payload.forEach { item in
            state.items[item.id] = item
        }
        return state
    }

    return state
}

class FeedMapperTests: XCTestCase {

    func test_on_init_with_no_state_delivers_default_state() {
        struct AnyEvent: Event { }
        let output = feedMapper(nil, AnyEvent())
        XCTAssertEqual(output, FeedState())
    }
    
    func test_on_init_with_state_delivers_given_state() {
        struct AnyEvent: Event { }
        let item = makeItem()
        let state = FeedState(items: [item.id: item])
        let output = feedMapper(state, AnyEvent())
        XCTAssertEqual(output, state)
    }
    
    func test_on_feed_loaded_event_maps_payload_to_state() {
        let item = makeItem()
        let event = FeedLoadedEvent(payload: [item])
        let output = feedMapper(nil, event)
        
        XCTAssertEqual(output.items, [item.id: item])
    }
    
    func test_does_not_update_state_on_unhandled_event() {
        struct IgnoredEvent: Event { }

        let item = makeItem()
        let event = FeedLoadedEvent(payload: [item])

        let output1 = feedMapper(nil, event)
        XCTAssertEqual(output1.items, [item.id: item])
        
        let output2 = feedMapper(output1, IgnoredEvent())
        XCTAssertEqual(output2.items, [item.id: item])
    }

}

private extension FeedMapperTests {
    func makeItem() -> FeedItem {
        FeedItem(
            id: "any",
            imageURL: makeURL(),
            user: .init(id: "any", name: "any", about: "any", imageURL: makeURL()),
            interactions: .init(
                isLiked: false,
                likes: 0,
                comments: 0,
                shares: 0
            )
        )
    }
}
