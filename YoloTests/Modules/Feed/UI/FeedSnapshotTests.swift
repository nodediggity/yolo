//
//  FeedSnapshotTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import XCTest
import Yolo

class FeedSnapshotTests: XCTestCase {
    
    func test_empty_feed() {
        let sut = makeSUT()
        sut.display(makeEmptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iPhone12(style: .light)), named: "EMPTY_FEED_light")
    }
    
}

private extension FeedSnapshotTests {
    func makeSUT() -> FeedViewController {
        let controller = FeedViewController()
        controller.loadViewIfNeeded()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    func makeEmptyFeed() -> [FeedCardCellController] {
        []
    }
    
}
