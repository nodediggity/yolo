//
//  CommentPresenterTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import XCTest
import Yolo

class CommentPresenterTests: XCTestCase {

    func test_map_creates_view_model() {
        let item = Comment(
            id: "any",
            text: "some text",
            user: .init(id: "any", name: "some name", imageURL: makeURL())
        )
        let output = CommentPresenter.map(item)
        let expected = CommentViewModel(name: "some name", text: "some text")
        
        
        XCTAssertEqual(output, expected)
    }

}
