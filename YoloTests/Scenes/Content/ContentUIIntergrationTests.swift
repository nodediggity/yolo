//
//  ContentUIIntergrationTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import XCTest
import Combine
import Yolo

class ContentUIIntergrationTests: XCTestCase {
    
    // Content
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
        
        let updatedContent = makeContent(interactions: .init(likes: 100, comments: 200, shares: 300))
        loader.loadContentCompletes(with: .success(updatedContent), at: 1)
        assertThat(sut, isRendering: updatedContent)
    }
    
}

private extension ContentUIIntergrationTests {
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ContentUIComposer.compose(loader: loader.loadContentPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    func makeContent(commentCount: Int = 5, interactions: Content.Interactions = .init(likes: 10, comments: 20, shares: 15)) -> (content: Content, comments: [Comment]) {
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
    
    func assertThat(_ sut: ListViewController, isRendering model: (content: Content, comments: [Comment])?, file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        if let model = model {
            let (_, comments) = model
            
            guard sut.numberOfRenderedComments == comments.count else {
                return XCTFail("Expected \(comments.count) but got \(sut.numberOfRenderedComments) instead", file: file, line: line)
            }
            
            comments.indices.forEach { index in
                let comment = comments[index]
                assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
            }
            
        } else if sut.numberOfSections > 0, sut.numberOfRenderedItems(in: 0) > 0 {
            XCTFail("Expected 0 items but got \(sut.numberOfRenderedItems(in: 0)) instead", file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    func assertThat(_ sut: ListViewController, hasViewConfiguredFor item: Comment, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.commentView(at: index)
        guard let cell = view as? CommentView else {
            return XCTFail("Expected \(CommentView.self) instance but got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let viewModel = CommentPresenter.map(item)
        XCTAssertEqual(cell.nameText, viewModel.name, file: file, line: line)
        XCTAssertEqual(cell.bodyText, viewModel.text, file: file, line: line)
    }
    
    class LoaderSpy {
                
        // Content
        var loadContentCallCount: Int {
            contentRequests.count
        }

        private var contentRequests: [PassthroughSubject<(content: Content, comments: [Comment]), Error>] = []
        
        func loadContentPublisher() -> AnyPublisher<(content: Content, comments: [Comment]), Error> {
            let publisher = PassthroughSubject<(content: Content, comments: [Comment]), Error>()
            contentRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func loadContentCompletes(with result: Result<(content: Content, comments: [Comment]), Error>, at index: Int = 0) {
            switch result {
            case let .success(values): contentRequests[index].send(values)
            default: break
            }
        }
        
    }
}

extension CommentView {
    var nameText: String? {
        nameLabel.text
    }
    
    var bodyText: String? {
        bodyTextLabel.text
    }
}
