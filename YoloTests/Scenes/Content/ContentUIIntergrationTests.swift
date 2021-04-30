//
//  ContentUIIntergrationTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import XCTest
import Combine

@testable import Yolo

enum ContentUIComposer {
    
    typealias Loader = () -> AnyPublisher<(content: Content, comments: [Comment]), Error>
    
    static func compose(loader: @escaping Loader) -> ListViewController {
        
        let adapter = ResourcePresentationAdapter<(content: Content, comments: [Comment]), ContentViewAdapter>(service: loader)
        
        let viewController = ListViewController()
        
        viewController.onLoad = adapter.execute
        
        return viewController
    }
}

final class ContentViewAdapter {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
}

extension ContentViewAdapter: ResourceView {
    typealias ResourceViewModel = (content: Content, comments: [Comment])
    
    func display(_ viewModel: ResourceViewModel) {
        
    }
}

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
    
    class LoaderSpy {
        
        var loadContentCallCount: Int { contentRequests.count }
        
        // Content
        
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
