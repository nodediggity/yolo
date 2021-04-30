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
    
    // MARK:- Feed
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
    
    func test_feed_card_selection_notifies_handler() {
        let feed = makeFeed()
        var request: [FeedItem] = []
        
        let (sut, loader) = makeSUT(onSelection: { request.append($0) })
        sut.loadViewIfNeeded()
        loader.loadFeedCompletes(with: .success(feed.items))

        sut.simulateFeedCardSelection(at: 0)
        XCTAssertEqual(request, [feed.items[0]])
        
        sut.simulateFeedCardSelection(at: 1)
        XCTAssertEqual(request, [feed.items[0], feed.items[1]])
    }
    
    // MARK:- Images
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
        
        let view0 = sut.simulateFeedCardVisible(at: 0)
        
        XCTAssertEqual(view0?.renderedImageForUser, .none)
        XCTAssertEqual(view0?.renderedImageForCard, .none)
        
        let userImageData0 = UIImage.makeImageData(withColor: .red)
        let bodyImageData0 = UIImage.makeImageData(withColor: .blue)
        
        loader.loadImageCompletes(with: .success(userImageData0), at: 0)
        
        XCTAssertEqual(view0?.renderedImageForUser, userImageData0)
        XCTAssertEqual(view0?.renderedImageForCard, .none)
        
        loader.loadImageCompletes(with: .success(bodyImageData0), at: 1)

        XCTAssertEqual(view0?.renderedImageForUser, userImageData0)
        XCTAssertEqual(view0?.renderedImageForCard, bodyImageData0)
        
        let view1 = sut.simulateFeedCardVisible(at: 1)
        
        XCTAssertEqual(view1?.renderedImageForUser, .none)
        XCTAssertEqual(view1?.renderedImageForCard, .none)
        
        let userImageData1 = UIImage.makeImageData(withColor: .purple)
        let bodyImageData1 = UIImage.makeImageData(withColor: .darkGray)
        
        loader.loadImageCompletes(with: .success(userImageData1), at: 2)
        
        XCTAssertEqual(view1?.renderedImageForUser, userImageData1)
        XCTAssertEqual(view1?.renderedImageForCard, .none)
        
        loader.loadImageCompletes(with: .success(bodyImageData1), at: 3)
        
        XCTAssertEqual(view1?.renderedImageForUser, userImageData1)
        XCTAssertEqual(view1?.renderedImageForCard, bodyImageData1)
    }
    
    func test_feed_card_view_preloads_image_loaded_for_url_when_near_visible() {
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
    
    func test_feed_card_view_cancels_preloaf_image_for_url_when_no_longer_near_visible() {
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
    
    func test_load_feed_car_view_image_loader_dispatches_from_background_to_main_thread() {
        let exp = expectation(description: "await background queue")
        let feed = makeFeed(itemCount: 5)
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.loadFeedCompletes(with: .success(feed.items))
        sut.simulateFeedCardVisible(at: 0)
        
        let imageData = UIImage.makeImageData(withColor: .red)
        
        DispatchQueue.global().async {
            loader.loadImageCompletes(with: .success(imageData), at: 0)
            loader.loadImageCompletes(with: .success(imageData), at: 1)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_feed_card_view_does_not_render_loaded_image_when_not_visible_anymore() {
        let feed = makeFeed(itemCount: 5)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.loadFeedCompletes(with: .success(feed.items))
        
        let view = sut.simulateFeedCardNotVisible(at: 0)
        loader.loadImageCompletes(with: .success(UIImage.makeImageData(withColor: .blue)))
        loader.loadImageCompletes(with: .success(UIImage.makeImageData(withColor: .red)))

        XCTAssertNil(view?.renderedImageForUser)
        XCTAssertNil(view?.renderedImageForCard)
    }
    
    // MARK:- Interactions
    func test_like_feed_item_action_dispatches_request() {
        let feed = makeFeed()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertTrue(loader.interactionRequests.isEmpty)
        
        loader.loadFeedCompletes(with: .success(feed.items))
        
        let view = sut.feedCardView(at: 0) as? FeedCardView
        view?.simulateToggleLikeAction()
        
        XCTAssertEqual(loader.interactionRequests.map(\.id), [feed.items.first?.id])
        XCTAssertEqual(loader.interactionRequests.map(\.op), [.unlike])
    }

    func test_like_feed_item_does_not_dispatch_multiple_requests_if_existing_request_is_pending() {
        let feed = makeFeed()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertTrue(loader.interactionRequests.isEmpty)
        
        loader.loadFeedCompletes(with: .success(feed.items))
        
        let view = sut.feedCardView(at: 0) as? FeedCardView
        view?.simulateToggleLikeAction()
        XCTAssertEqual(loader.interactionRequests.count, 1)
        
        view?.simulateToggleLikeAction()
        XCTAssertEqual(loader.interactionRequests.count, 1)
    }

    func test_toggle_like_action_performs_optimistic_state_update() {
        let feed = makeFeed()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.loadFeedCompletes(with: .success(feed.items))

        let view = sut.feedCardView(at: 0) as? FeedCardView
        XCTAssertEqual(view?.likesText, "10")
        XCTAssertEqual(view?.isShowingAsLiked, true)

        view?.simulateToggleLikeAction()
        XCTAssertEqual(view?.likesText, "9")
        XCTAssertEqual(view?.isShowingAsLiked, false)
    }

    func test_toggle_like_failure_reverts_optimistic_state_update() {
        let feed = makeFeed()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.loadFeedCompletes(with: .success(feed.items))

        let view = sut.feedCardView(at: 0) as? FeedCardView
        XCTAssertEqual(view?.likesText, "10")
        XCTAssertEqual(view?.isShowingAsLiked, true)

        view?.simulateToggleLikeAction()
        XCTAssertEqual(view?.likesText, "9")
        XCTAssertEqual(view?.isShowingAsLiked, false)
        
        loader.toggleInteractionCompletes(with: .failure(makeError()))
        
        XCTAssertEqual(view?.likesText, "10")
        XCTAssertEqual(view?.isShowingAsLiked, true)
    }
}

private extension FeedUIIntegrationTests {
    
    func makeSUT(onSelection: @escaping (FeedItem) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.compose(loader: loader.loadFeedPublisher, imageLoader: loader.loadImagePublisher, interactionService: loader.toggleInteractionPublisher, selection: onSelection)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    var title: String {
        FeedPresenter.title
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
        let IS_LIKED = true
        let LIKES = 10
        let COMMENTS = Int.random(in: 0..<10)
        let SHARES = Int.random(in: 0..<15)
        
        return FeedItem(
            id: ITEM_ID,
            imageURL: makeURL(IMAGE_URL),
            user: FeedItem.User(id: USER_ID, name: USER_NAME, about: USER_ABOUT, imageURL: makeURL(USER_IMAGE_URL)),
            interactions: Interactions(isLiked: IS_LIKED, likes: LIKES, comments: COMMENTS, shares: SHARES)
        )
    }
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
