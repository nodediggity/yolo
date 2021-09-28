//
//  FeedSelectorTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 27/07/2021.
//

import XCTest
import Yolo

class FeedSelectorTests: XCTestCase {

    func test_selector_maps_current_state() {
        let item = makeItem()
        let state = FeedState(items: [item.id: item])
        let output = feedSelector(.init(feed: state))
        XCTAssertEqual(output, [item])
    }

}

private extension FeedSelectorTests {
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
