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
    
    func test_feed_with_content() {
        let sut = makeSUT()
        sut.display(makeFeedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone12(style: .light)), named: "FEED_WITH_CONTENT_light")
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
    
    func makeFeedWithContent() -> [FeedCardStub] {
        return [
            FeedCardStub(
                FeedItem(
                    id: UUID().uuidString,
                    imageURL: makeURL(),
                    user: FeedItem.User(id: UUID().uuidString, name: "Some Name", about: "short about text", imageURL: makeURL()),
                    interactions: FeedItem.Interactions(likes: 247, comments: 57, shares: 33)
                )
            ),
            FeedCardStub(
                FeedItem(
                    id: UUID().uuidString,
                    imageURL: makeURL(),
                    user: FeedItem.User(id: UUID().uuidString, name: "Another Name", about: "longer about text that should truncate as it is too long to fit", imageURL: makeURL()),
                    interactions: FeedItem.Interactions(likes: 17, comments: 36, shares: 8)
                )
            )
        ]
    }
    
}

private extension FeedViewController {
    func display(_ stubs: [FeedCardStub]) {
        let cells: [FeedCardCellController] = stubs.map { stub in
            let controller = FeedCardCellController(model: stub.viewModel)
            stub.controller = controller
            return controller
        }
        
        display(cells)
    }
}

private final class FeedCardStub {
    let viewModel: FeedCardViewModel
    weak var controller: FeedCardCellController?
    
    init(_ item: FeedItem) {
        self.viewModel = FeedCardPresenter.map(item)
    }
}
