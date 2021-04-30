//
//  ContentResponseMapperTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import XCTest
import Yolo

class ContentResponseMapperTests: XCTestCase {
    
    func test_map_throws_error_on_non_200_HTTPResponse() throws {
        let data = makeJSONData(for: [:])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ContentResponseMapper.map(data, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throws_error_on_200_HTTPResponse_with_invalid_json() {
        let invalidJSONData = Data("any invalid data".utf8)
        
        XCTAssertThrowsError(
            try ContentResponseMapper.map(invalidJSONData, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_delivers_no_items_on_200_HTTPResponse_with_empty_json_list() throws {
        let (model, json) = makeContent()
        let data = makeJSONData(for: json)
        
        let output = try ContentResponseMapper.map(data, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(output, model)
    }
    
    func test_map_delivers_items_on_200_HTTPResponse_with_json_items() throws {
        let (model, json) = makeContent()
        let data = makeJSONData(for: json)
        
        let output = try ContentResponseMapper.map(data, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(output, model)
    }
}

private extension ContentResponseMapperTests {
    
    func makeJSONData(for content: [String: Any]) -> Data {
        let data = try! JSONSerialization.data(withJSONObject: [
            "content": content
        ])
        return data
    }
    
    func makeContent() -> (model: Content, json: [String: Any]) {
        let ITEM_ID = UUID().uuidString
        let IMAGE_URL = "https://some-image.com"
        let USER_ID = UUID().uuidString
        let IS_LIKED = true
        let LIKES = 5
        let COMMENTS = 10
        let SHARES = 12
        
        let model = Content(
            id: ITEM_ID,
            imageURL: makeURL(IMAGE_URL),
            user: Content.User(id: USER_ID),
            interactions: Interactions(isLiked: IS_LIKED, likes: LIKES, comments: COMMENTS, shares: SHARES)
        )
        
        let json = [
            "id": ITEM_ID,
            "imageURL": IMAGE_URL,
            "user": [
                "id": USER_ID
            ],
            "interactions": [
                "isLiked": IS_LIKED,
                "likes": LIKES,
                "comments": COMMENTS,
                "shares": SHARES
            ]
        ] as [String : Any]
        
        return (model, json)
    }
}
