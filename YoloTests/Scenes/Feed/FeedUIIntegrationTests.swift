//
//  FeedUIIntegrationTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import XCTest
import Combine
import Yolo

class FeedUIIntegrationTests: XCTestCase {
    
    func test_scene_has_title() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.title, title)
    }
    
    // Feed
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
    
    func test_load_feed_completion_renders_successfully_loaded_feed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        let page0 = makeFeed(itemCount: 5)
        loader.loadFeedCompletes(with: .success(page0.items))
        
        assertThat(sut, isRendering: page0.items)
        
        sut.simulateUserInitiatedReload()
        
        let refreshedPage0 = makeFeed(itemCount: 10)
        loader.loadFeedCompletes(with: .success(refreshedPage0.items), at: 1)
        
        assertThat(sut, isRendering: refreshedPage0.items)
    }
    
    func test_load_feed_completion_renders_empty_feed_after_non_empty_feed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        let feed = makeFeed(itemCount: 5)
        loader.loadFeedCompletes(with: .success(feed.items))
        
        assertThat(sut, isRendering: feed.items)
        
        sut.simulateUserInitiatedReload()
        loader.loadFeedCompletes(with: .success([]), at: 1)
        
        assertThat(sut, isRendering: [])
    }
    
    func test_load_feed_completion_does_not_alter_currently_rendered_feed_state_on_error() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        let feed = makeFeed(itemCount: 5)
        loader.loadFeedCompletes(with: .success(feed.items))
        
        assertThat(sut, isRendering: feed.items)
        
        sut.simulateUserInitiatedReload()
        
        let error = makeError()
        loader.loadFeedCompletes(with: .failure(error), at: 1)
        
        assertThat(sut, isRendering: feed.items)
    }
    
    func test_load_feed_dispatches_from_background_to_main_thread() {
        let exp = expectation(description: "await background queue")
        let feed = makeFeed(itemCount: 5)
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        DispatchQueue.global().async {
            loader.loadFeedCompletes(with: .success(feed.items))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // Images
    func test_feed_card_view_loads_image_url_for_when_visible() {
        let feed = makeFeed(itemCount: 2)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.loadFeedCompletes(with: .success(feed.items))
        XCTAssertTrue(loader.imageLoaderURLs.isEmpty)
        
        sut.simulateFeedCardVisible(at: 0)
        XCTAssertEqual(loader.imageLoaderURLs, feed.images(forItemAt: 0))
        
        sut.simulateFeedCardVisible(at: 1)
        XCTAssertEqual(loader.imageLoaderURLs, feed.images(forItemAt: 0) + feed.images(forItemAt: 1))
    }
    
    func test_feed_card_view_cancels_load_image_url_requests_when_no_longer_visible() {
        let feed = makeFeed(itemCount: 2)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.loadFeedCompletes(with: .success(feed.items))
        XCTAssertTrue(loader.cancelledImageLoaderURLs.isEmpty)
        
        sut.simulateFeedCardNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageLoaderURLs, feed.images(forItemAt: 0))
        
        sut.simulateFeedCardNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageLoaderURLs, feed.images(forItemAt: 0) + feed.images(forItemAt: 1))
    }
    
    func test_feed_card_view_renders_image_loaded_for_url() {
        let feed = makeFeed(itemCount: 2)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.loadFeedCompletes(with: .success(feed.items))
        
        sut.simulateFeedCardVisible(at: 0)
        XCTAssertEqual(sut.renderedFeedCardUserImageData(at: 0), .none)
        XCTAssertEqual(sut.renderedFeedCardBodyImageData(at: 0), .none)
        
        let userImageData0 = UIImage.makeImageData(withColor: .red)
        let bodyImageData0 = UIImage.makeImageData(withColor: .blue)
        
        loader.loadImageCompletes(with: .success(userImageData0), at: 0)
        
        XCTAssertEqual(sut.renderedFeedCardUserImageData(at: 0), userImageData0)
        XCTAssertEqual(sut.renderedFeedCardBodyImageData(at: 0), .none)
        
        loader.loadImageCompletes(with: .success(bodyImageData0), at: 1)

        XCTAssertEqual(sut.renderedFeedCardUserImageData(at: 0), userImageData0)
        XCTAssertEqual(sut.renderedFeedCardBodyImageData(at: 0), bodyImageData0)

        sut.simulateFeedCardVisible(at: 1)
        XCTAssertEqual(sut.renderedFeedCardUserImageData(at: 1), .none)
        XCTAssertEqual(sut.renderedFeedCardBodyImageData(at: 1), .none)

        let userImageData1 = UIImage.makeImageData(withColor: .gray)
        let bodyImageData1 = UIImage.makeImageData(withColor: .yellow)

        loader.loadImageCompletes(with: .success(userImageData1), at: 2)

        XCTAssertEqual(sut.renderedFeedCardUserImageData(at: 1), userImageData1)
        XCTAssertEqual(sut.renderedFeedCardBodyImageData(at: 1), .none)

        loader.loadImageCompletes(with: .success(bodyImageData1), at: 3)

        XCTAssertEqual(sut.renderedFeedCardUserImageData(at: 1), userImageData1)
        XCTAssertEqual(sut.renderedFeedCardBodyImageData(at: 1), bodyImageData1)
    }
    
    func test_feed_card_view_preloads_image_loaded_for_url() {
        let feed = makeFeed(itemCount: 2)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.loadFeedCompletes(with: .success(feed.items))
        XCTAssertTrue(loader.imageLoaderURLs.isEmpty)
        
        sut.simulateFeedCardNearVisible(at: 0)
        XCTAssertEqual(loader.imageLoaderURLs, feed.images(forItemAt: 0))
        
        sut.simulateFeedCardNearVisible(at: 1)
        XCTAssertEqual(loader.imageLoaderURLs, feed.images(forItemAt: 0) + feed.images(forItemAt: 1))
    }
}

private extension FeedUIIntegrationTests {
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.compose(loader: loader.loadFeedPublisher, imageLoader: loader.loadImagePublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    func assertThat(_ sut: FeedViewController, isRendering feed: [FeedItem], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedFeedItems == feed.count else {
            return XCTFail("Expected \(feed.count) items but got \(sut.numberOfRenderedFeedItems) instead.", file: file, line: line)
        }
        
        feed.indices.forEach { index in
            let item = feed[index]
            assertThat(sut, hasViewConfiguredFor: item, at: index, file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    func assertThat(_ sut: FeedViewController, hasViewConfiguredFor item: FeedItem, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedCardView(at: index)
        guard let cell = view as? FeedCardView else {
            return XCTFail("Expected \(FeedCardView.self) instance but got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let viewModel = FeedCardPresenter.map(item)
        
        XCTAssertEqual(cell.nameText, viewModel.name, file: file, line: line)
        XCTAssertEqual(cell.aboutText, viewModel.about, file: file, line: line)
        XCTAssertEqual(cell.likesText, viewModel.likes, file: file, line: line)
        XCTAssertEqual(cell.commentsText, viewModel.comments, file: file, line: line)
        XCTAssertEqual(cell.sharesText, viewModel.shares, file: file, line: line)
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
            case let .failure(error): loadFeedRequests[index].send(completion: .failure(error))
            }
        }
        
        // Image Loader
        var imageLoaderURLs: [URL] {
            loadImageRequests.map(\.url)
        }
        
        private(set) var cancelledImageLoaderURLs: [URL] = []
        
        private var loadImageRequests: [(url: URL, publisher: PassthroughSubject<Data, Error>)] = []
        
        func loadImagePublisher(_ imageURL: URL) -> AnyPublisher<Data, Error> {
            let publisher = PassthroughSubject<Data, Error>()
            loadImageRequests.append((imageURL, publisher))
            return publisher
                .handleEvents(receiveCancel: { [weak self] in self?.cancelledImageLoaderURLs.append(imageURL) })
                .eraseToAnyPublisher()
        }
        
        func loadImageCompletes(with result: Result<Data, Error>, at index: Int = 0) {
            switch result {
            case let .success(data): loadImageRequests[index].publisher.send(data)
            case let .failure(error): loadImageRequests[index].publisher.send(completion: .failure(error))
            }
        }
    }
    
    func makeFeed(itemCount: Int = 5) -> Feed {
        let items = (0..<itemCount).map(makeFeedItem(_:))
        return Feed(items: items)
    }
    
    func makeFeedItem(_ index: Int) -> FeedItem {
        let ITEM_ID = UUID().uuidString
        let IMAGE_URL = "https://some-image-\(index).com"
        let USER_ID = UUID().uuidString
        let USER_NAME = "any name \(index)"
        let USER_ABOUT = "some text \(index)"
        let USER_IMAGE_URL = "https://some-user-image-\(index).com"
        let LIKES = Int.random(in: 0..<5)
        let COMMENTS = Int.random(in: 0..<10)
        let SHARES = Int.random(in: 0..<15)
        
        return FeedItem(
            id: ITEM_ID,
            imageURL: makeURL(IMAGE_URL),
            user: FeedItem.User(id: USER_ID, name: USER_NAME, about: USER_ABOUT, imageURL: makeURL(USER_IMAGE_URL)),
            interactions: FeedItem.Interactions(likes: LIKES, comments: COMMENTS, shares: SHARES)
        )
    }
}

private extension FeedViewController {
    
    private var FEED_SECTION: Int { 0 }
    
    var isShowingLoadingIndicator: Bool {
        guard let refreshControl = refreshControl else { return false }
        return refreshControl.isRefreshing
    }
    
    var numberOfRenderedFeedItems: Int {
        guard tableView.numberOfSections > FEED_SECTION else { return 0 }
        return tableView.numberOfRows(inSection: FEED_SECTION)
    }
    
    func feedCardView(at row: Int) -> UITableViewCell? {
        let indexPath = IndexPath(row: row, section: FEED_SECTION)
        return tableView(tableView, cellForRowAt: indexPath)
    }
    
    @discardableResult
    func simulateFeedCardVisible(at row: Int) -> FeedCardView? {
        return feedCardView(at: row) as? FeedCardView
    }
    
    @discardableResult
    func simulateFeedCardNotVisible(at row: Int) -> FeedCardView? {
        let view = simulateFeedCardVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: FEED_SECTION)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    func simulateFeedCardNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: FEED_SECTION)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func renderedFeedCardUserImageData(at row: Int) -> Data? {
        return simulateFeedCardVisible(at: row)?.renderedImageForUser
    }
    
    func renderedFeedCardBodyImageData(at row: Int) -> Data? {
        return simulateFeedCardVisible(at: row)?.renderedImageForCard
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.beginRefreshing()
        scrollViewDidEndDragging(tableView, willDecelerate: false)
    }
}

private extension FeedCardView {
    
    var renderedImageForUser: Data? {
        userImageView.image?.pngData()
    }
    
    var renderedImageForCard: Data? {
        cardImageView.image?.pngData()
    }
    
    var nameText: String? {
        nameLabel.text
    }
    
    var aboutText: String? {
        aboutLabel.text
    }
    
    var likesText: String? {
        likesCountLabel.text
    }
    
    var commentsText: String? {
        commentsCountLabel.text
    }
    
    var sharesText: String? {
        sharesCountLabel.text
    }
}


extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}

func executeRunLoopToCleanUpReferences() {
    RunLoop.current.run(until: Date())
}

private extension Feed {
    func userImageURL(at index: Int) -> URL? {
        guard items.indices.contains(index) else { return nil }
        return items[index].user.imageURL
    }
    
    func cardImageURL(at index: Int) -> URL? {
        guard items.indices.contains(index) else { return nil }
        return items[index].imageURL
    }
    
    func images(forItemAt index: Int) -> [URL?] {
        guard items.indices.contains(index) else { return [] }
        return [
            userImageURL(at: index),
            cardImageURL(at: index)
        ]
    }
}
