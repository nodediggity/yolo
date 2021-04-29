//
//  CommentsResponseMapperTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import XCTest
import Yolo

class CommentsResponseMapperTests: XCTestCase {
    
    func test_map_throws_error_on_non_200_HTTPResponse() throws {
        let data = makeJSONData(for: [])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try CommentsResponseMapper.map(data, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throws_error_on_200_HTTPResponse_with_invalid_json() {
        let invalidJSONData = Data("any invalid data".utf8)
        
        XCTAssertThrowsError(
            try CommentsResponseMapper.map(invalidJSONData, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_delivers_no_items_on_200_HTTPResponse_with_empty_json_list() throws {
        let data = makeJSONData(for: [])
        let output = try CommentsResponseMapper.map(data, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(output, [])
    }
    
    func test_map_delivers_items_on_200_HTTPResponse_with_json_items() throws {
        let comments = (0..<0).map(makeComment)
        let model = comments.map(\.model)
        let json = comments.map(\.json)
        
        let data = makeJSONData(for: json)
        
        let output = try CommentsResponseMapper.map(data, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(output, model)
    }
}

private extension CommentsResponseMapperTests {
    
    func makeJSONData(for comments: [[String: Any]]) -> Data {
        let data = try! JSONSerialization.data(withJSONObject: [
            "content": [
                "comments": comments
            ]
        ])
        return data
    }
    
    func makeComment(_ index: Int) -> (model: Comment, json: [String: Any]) {
        let COMMENT_ID = UUID().uuidString
        let COMMENT_TEXT = "comment #\(index)"
        let USER_ID = UUID().uuidString
        let USER_NAME = "any name \(index)"
        let USER_IMAGE_URL = "https://some-user-image-\(index).com"
        
        let model = Comment(
            id: COMMENT_ID,
            text: COMMENT_TEXT,
            user: Comment.User(id: USER_ID, name: USER_NAME, imageURL: makeURL(USER_IMAGE_URL))
        )
        
        let json = [
            "id": COMMENT_ID,
            "text": COMMENT_TEXT,
            "user": [
                "id": USER_ID,
                "name": USER_NAME,
                "imageURL": USER_IMAGE_URL
            ]
        ] as [String : Any]
        
        return (model, json)
    }
}
