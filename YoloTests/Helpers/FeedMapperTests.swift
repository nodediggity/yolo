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
