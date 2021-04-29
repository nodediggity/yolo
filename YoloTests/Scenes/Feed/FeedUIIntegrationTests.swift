//
//  FeedUIIntegrationTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import XCTest
import Yolo

class FeedViewController: UIViewController {
    
}

enum FeedPresenter {
    static var title: String {
        "Discover"
    }
}

enum FeedUIComposer {
    static func compose() -> FeedViewController {
        let viewController = FeedViewController()
        viewController.title = FeedPresenter.title
        return viewController
    }
}

class FeedUIIntegrationTests: XCTestCase {

    func test_scene_has_title() {
        let sut = makeSUT()
        XCTAssertEqual(sut.title, title)
    }

}

private extension FeedUIIntegrationTests {
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedViewController {
        let sut = FeedUIComposer.compose()
        return sut
    }
    
    
    var title: String {
        FeedPresenter.title
    }
}
