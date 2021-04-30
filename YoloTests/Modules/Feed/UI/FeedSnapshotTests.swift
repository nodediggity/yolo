//
//  FeedSnapshotTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import XCTest
import Yolo

class FeedSnapshotTests: XCTestCase {
    
    func test_feed_with_content() {
        let sut = makeSUT()
        sut.display(makeFeedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone12(style: .light)), named: "FEED_WITH_CONTENT_light")
    }
    
}

private extension FeedSnapshotTests {
    func makeSUT() -> ListViewController {
        let controller = ListViewController()
        controller.configure = { tableView in
            tableView.register(FeedCardView.self)
        }
        controller.loadViewIfNeeded()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    func makeFeedWithContent() -> [FeedCardStub] {
        return [
            FeedCardStub(
                FeedItem(
                    id: UUID().uuidString,
                    imageURL: makeURL(),
                    user: FeedItem.User(id: UUID().uuidString, name: "Some Name", about: "short about text", imageURL: makeURL()),
                    interactions: FeedItem.Interactions(isLiked: true, likes: 247, comments: 57, shares: 33)
                ),
                userImage: UIImage.make(withColor: .red),
                cardImage: UIImage.make(withColor: .blue)
            ),
            FeedCardStub(
                FeedItem(
                    id: UUID().uuidString,
                    imageURL: makeURL(),
                    user: FeedItem.User(id: UUID().uuidString, name: "Another Name", about: "longer about text that should truncate as it is too long to fit", imageURL: makeURL()),
                    interactions: FeedItem.Interactions(isLiked: false, likes: 17, comments: 36, shares: 8)
                ),
                userImage: UIImage.make(withColor: .green),
                cardImage: UIImage.make(withColor: .yellow)
            )
        ]
    }
    
}

private extension ListViewController {
    func display(_ stubs: [FeedCardStub]) {
        let cells: [CellController] = stubs.map { stub in
            let controller = FeedCardCellController(model: stub.viewModel)
            stub.controller = controller
            controller.onLoadImage = stub.displayImages
            return .init(controller)
        }
        
        display(cells)
    }
}

private final class FeedCardStub {
    let viewModel: FeedCardViewModel
    weak var controller: FeedCardCellController?
    
    private var userImage: UIImage?
    private var cardImage: UIImage?
    
    init(_ item: FeedItem, userImage: UIImage? = nil, cardImage: UIImage? = nil) {
        self.viewModel = FeedCardPresenter.map(item)
        self.userImage = userImage
        self.cardImage = cardImage
    }
    
    func displayImages() {
        if let image = userImage {
            controller?.displayImage(for: .user(image))
        }

        if let image = cardImage {
            controller?.displayImage(for: .body(image))
        }
    }
}
