//
//  FeedUIIntegrationTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import XCTest
import Combine
import Yolo

class FeedViewController: UITableViewController {
    
    public var onLoad: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl(frame: .zero)
        load()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard refreshControl?.isRefreshing == true else { return }
        load()
    }
}

private extension FeedViewController {
    func load() {
        onLoad?()
    }
}

enum FeedPresenter {
    static var title: String {
        "Discover"
    }
}

enum FeedUIComposer {
    
    typealias FeedLoader = () -> AnyPublisher<[FeedItem], Error>
    
    static func compose(loader: @escaping FeedLoader) -> FeedViewController {
        
        let adapter = FeedPresentationAdapter(loader: loader)
        
        let viewController = FeedViewController()
        viewController.title = FeedPresenter.title
        
        viewController.onLoad = adapter.execute
        
        return viewController
    }
}

class FeedPresentationAdapter {
    private let loader: () -> AnyPublisher<[FeedItem], Error>
    private var cancellable: Cancellable?
    
    private var isPending = false
    
    init(loader: @escaping () -> AnyPublisher<[FeedItem], Error>) {
        self.loader = loader
    }
    
    func execute() {
        guard !isPending else { return }
        isPending = true
        cancellable = loader()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isPending = false
            })
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.isPending = false
                }
            )
    }
}

class FeedUIIntegrationTests: XCTestCase {

    func test_scene_has_title() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.title, title)
    }

    func test_load_actions_request_feed_from_loader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 1)
        
        loader.loadFeedCompletes(with: .success([]))
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2)
    }
}

private extension FeedUIIntegrationTests {
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.compose(loader: loader.loadFeedPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    var title: String {
        FeedPresenter.title
    }
    
    class LoaderSpy {
        
        // Feed Loader
        var loadFeedCallCount: Int {
            loadFeedRequests.count
        }
        
        private var loadFeedRequests: [PassthroughSubject<[FeedItem], Error>] = []
        
        func loadFeedPublisher() -> AnyPublisher<[FeedItem], Error> {
            let publisher = PassthroughSubject<[FeedItem], Error>()
            loadFeedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func loadFeedCompletes(with result: Result<[FeedItem], Error>, at index: Int = 0) {
            switch result {
            case let .success(feed): loadFeedRequests[index].send(feed)
            default: break
            }
        }
    }

}

private extension FeedViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.beginRefreshing()
        scrollViewDidEndDragging(tableView, willDecelerate: false)
    }
}
