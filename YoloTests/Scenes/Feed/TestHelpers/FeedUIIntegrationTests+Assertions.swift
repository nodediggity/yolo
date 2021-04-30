//
//  FeedUIIntegrationTests+TestHelpers.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import XCTest
import Yolo

extension FeedUIIntegrationTests {
    func assertThat(_ sut: ListViewController, isRendering feed: [FeedItem], file: StaticString = #filePath, line: UInt = #line) {
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
    
    func assertThat(_ sut: ListViewController, hasViewConfiguredFor item: FeedItem, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
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
        XCTAssertEqual(cell.isShowingAsLiked, viewModel.isLiked, file: file, line: line)
    }
    
}
