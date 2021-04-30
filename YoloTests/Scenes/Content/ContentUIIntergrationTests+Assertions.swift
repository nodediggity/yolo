//
//  ContentUIIntergrationTests+Assertions.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import XCTest
import Yolo

extension ContentUIIntergrationTests {
    func assertThat(_ sut: ListViewController, isRendering model: (content: Content, comments: [Comment])?, file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        if let model = model {
            let (content, comments) = model
            
            assertThat(sut, hasViewConfiguredFor: content, at: 0, file: file, line: line)
            
            if comments.isEmpty {
                XCTAssertTrue(sut.isShowingNoCommentPlaceholder, file: file ,line: line)
            } else {
                guard sut.numberOfRenderedComments == comments.count else {
                    return XCTFail("Expected \(comments.count) but got \(sut.numberOfRenderedComments) instead", file: file, line: line)
                }
                
                comments.indices.forEach { index in
                    let comment = comments[index]
                    assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
                }
            }
            
        } else if sut.numberOfSections > 0, sut.numberOfRenderedItems(in: 0) > 0 {
            XCTFail("Expected 0 items but got \(sut.numberOfRenderedItems(in: 0)) instead", file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    func assertThat(_ sut: ListViewController, hasViewConfiguredFor content: Content, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.contentView()
        guard let cell = view as? ContentView else {
            return XCTFail("Expected \(ContentView.self) instance but got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.likesText, "\(content.interactions.likes)", file: file, line: line)
        XCTAssertEqual(cell.commentsText, "\(content.interactions.comments)", file: file, line: line)
        XCTAssertEqual(cell.sharesText, "\(content.interactions.shares)", file: file, line: line)
        XCTAssertEqual(cell.isShowingAsLiked, content.interactions.isLiked, file: file, line: line)
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
    
}
