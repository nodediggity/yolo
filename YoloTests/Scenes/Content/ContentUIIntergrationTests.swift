//
//  ContentUIIntergrationTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import XCTest
import Yolo

class ContentUIIntergrationTests: XCTestCase {
    
    // MARK:- Content
    func test_load_actions_request_content_from_loader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadContentCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadContentCallCount, 1)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadContentCallCount, 1)
        
        loader.loadContentCompletes(with: .success(makeContent()))
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadContentCallCount, 2)
    }
    
    func test_loading_indicator_is_visible_while_loading_content() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.loadContentCompletes(with: .success(makeContent()))
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.loadContentCompletes(with: .success(makeContent()), at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_load_content_completion_renders_successfully_loaded_content() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: .none)
        
        let content = makeContent()
        loader.loadContentCompletes(with: .success(content))
        
        assertThat(sut, isRendering: content)
        
        sut.simulateUserInitiatedReload()
        
        let updatedContent = makeContent(interactions: .init(isLiked: false, likes: 100, comments: 200, shares: 300))
        loader.loadContentCompletes(with: .success(updatedContent), at: 1)
        assertThat(sut, isRendering: updatedContent)
        
        sut.simulateUserInitiatedReload()
        let contentNoComments = makeContent(commentCount: 0, interactions: .init(isLiked: true, likes: 100, comments: 200, shares: 300))
        loader.loadContentCompletes(with: .success(contentNoComments), at: 2)
        assertThat(sut, isRendering: contentNoComments)
    }
    
    func test_content_loads_image_for_url_when_visible() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        let model = makeContent()
        loader.loadContentCompletes(with: .success(model))
        XCTAssertTrue(loader.imageLoaderURLs.isEmpty)
        
        sut.simulateContentViewVisible()
        XCTAssertEqual(loader.imageLoaderURLs, [model.content.imageURL])
        
        sut.simulateCommentVisible(at: 0)
        XCTAssertEqual(loader.imageLoaderURLs, [model.content.imageURL, model.comments.imageURL(at: 0)])
    }
    
    func test_content_renders_image_loaded_for_url() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        let model = makeContent()
        loader.loadContentCompletes(with: .success(model))
        
        let view = sut.contentView() as? ContentView
        XCTAssertEqual(view?.renderedImage, .none)
        
        let imageData = UIImage.makeImageData(withColor: .red)
        loader.loadImageCompletes(with: .success(imageData), at: 0)
        
        XCTAssertEqual(view?.renderedImage, imageData)
        
        let commentView = sut.simulateCommentVisible(at: 0)
        
        let commentImageData = UIImage.makeImageData(withColor: .blue)
        loader.loadImageCompletes(with: .success(commentImageData), at: 1)
        
        XCTAssertEqual(commentView?.renderedImage, commentImageData)
    }
    
    func test_content_view_image_loader_dispatches_from_background_to_main_thread() {
        let exp = expectation(description: "await background queue")
        let model = makeContent()
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.loadContentCompletes(with: .success(model))
        sut.simulateContentViewVisible()
        
        let imageData = UIImage.makeImageData(withColor: .red)
        
        DispatchQueue.global().async {
            loader.loadImageCompletes(with: .success(imageData), at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK:- Interactions
    func test_like_feed_item_action_dispatches_request() {
        let model = makeContent()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertTrue(loader.interactionRequests.isEmpty)
        
        loader.loadContentCompletes(with: .success(model))
        
        let view = sut.contentView() as? ContentView
        view?.simulateToggleLikeAction()
        
        XCTAssertEqual(loader.interactionRequests.map(\.id), [model.content.id])
        XCTAssertEqual(loader.interactionRequests.map(\.op), [.unlike])
    }

    func test_like_feed_item_does_not_dispatch_multiple_requests_if_existing_request_is_pending() {
        let model = makeContent()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertTrue(loader.interactionRequests.isEmpty)

        loader.loadContentCompletes(with: .success(model))

        let view = sut.contentView() as? ContentView
        view?.simulateToggleLikeAction()
        XCTAssertEqual(loader.interactionRequests.count, 1)

        view?.simulateToggleLikeAction()
        XCTAssertEqual(loader.interactionRequests.count, 1)
    }

    func test_toggle_like_action_performs_optimistic_state_update() {
        let model = makeContent()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.loadContentCompletes(with: .success(model))

        let view = sut.contentView() as? ContentView
        XCTAssertEqual(view?.likesText, "10")
        XCTAssertEqual(view?.isShowingAsLiked, true)

        view?.simulateToggleLikeAction()
        XCTAssertEqual(view?.likesText, "9")
        XCTAssertEqual(view?.isShowingAsLiked, false)
    }

    func test_toggle_like_failure_reverts_optimistic_state_update() {
        let model = makeContent()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.loadContentCompletes(with: .success(model))

        let view = sut.contentView() as? ContentView
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

private extension ContentUIIntergrationTests {
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ContentUIComposer.compose(loader: loader.loadContentPublisher, imageLoader: loader.loadImagePublisher, interactionService: loader.toggleInteractionPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    func makeContent(commentCount: Int = 5, interactions: Interactions = .init(isLiked: true, likes: 10, comments: 20, shares: 15)) -> (content: Content, comments: [Comment]) {
        (
            content: Content(
                id: "any",
                imageURL: makeURL(),
                user: Content.User(id: "any"),
                interactions: interactions
            ),
            comments: (0..<commentCount).map { Comment(
                id: "\($0)",
                text: "comment \($0)",
                user: Comment.User(id: "any", name: "any name", imageURL: makeURL())
            ) }
        )
    }
}

private extension Array where Element == Comment {
    func imageURL(at index: Index) -> URL? {
        guard indices.contains(index) else { return nil }
        return self[index].user.imageURL
    }
}
