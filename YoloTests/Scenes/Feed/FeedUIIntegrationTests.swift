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

extension FeedViewController: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView: class {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedItem]
}

protocol FeedView: class {
    func display(_ viewModel: FeedViewModel)
}

class FeedPresenter {
    static var title: String {
        "Discover"
    }
    
    weak var view: FeedView?
    weak var loadingView: FeedLoadingView?
    
    func didStartLoadingFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedItem]) {
        view?.display(FeedViewModel(feed: feed))
        loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
}

enum FeedUIComposer {
    
    typealias FeedLoader = () -> AnyPublisher<[FeedItem], Error>
    
    static func compose(loader: @escaping FeedLoader) -> FeedViewController {
        
        let viewController = FeedViewController()
        viewController.title = FeedPresenter.title
        
        let adapter = FeedPresentationAdapter(loader: loader)
        
        let presenter = FeedPresenter()
        presenter.loadingView = viewController
        
        adapter.presenter = presenter
        
        viewController.onLoad = adapter.execute
        
        return viewController
    }
}

class FeedPresentationAdapter {
    
    var presenter: FeedPresenter?

    private let loader: () -> AnyPublisher<[FeedItem], Error>
    private var cancellable: Cancellable?
    
    private var isPending = false
    
    init(loader: @escaping () -> AnyPublisher<[FeedItem], Error>) {
        self.loader = loader
    }
    
    func execute() {
        guard !isPending else { return }
        isPending = true
        presenter?.didStartLoadingFeed()
        cancellable = loader()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isPending = false
            })
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoadingFeed(with: feed)
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
    
    func test_loading_indicator_is_visible_while_loading_feed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.loadFeedCompletes(with: .success([]))
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.loadFeedCompletes(with: .success([]), at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
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
    
    var isShowingLoadingIndicator: Bool {
        guard let refreshControl = refreshControl else { return false }
        return refreshControl.isRefreshing
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.beginRefreshing()
        scrollViewDidEndDragging(tableView, willDecelerate: false)
    }
}
