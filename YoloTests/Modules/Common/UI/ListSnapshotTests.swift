//
//  ListSnapshotTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import XCTest
import Yolo

class ListSnapshotTests: XCTestCase {
    
    func test_empty_list() {
        let sut = makeSUT()
        sut.display(makeEmptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iPhone12(style: .light)), named: "EMPTY_LIST_light")
    }
}

private extension ListSnapshotTests {
    func makeSUT() -> ListViewController {
        let controller = ListViewController()
        controller.loadViewIfNeeded()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    func makeEmptyFeed() -> [CellController] {
        []
    }
}
