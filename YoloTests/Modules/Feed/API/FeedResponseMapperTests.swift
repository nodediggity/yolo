//
//  FeedResponseMapperTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 28/04/2021.
//

import XCTest
import Yolo

class FeedResponseMapperTests: XCTestCase {
    
    func test_map_throws_error_on_non_200_HTTPResponse() throws {
        let data = makeJSONData(for: [:])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedResponseMapper.map(data, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throws_error_on_200_HTTPResponse_with_invalid_json() {
        let invalidJSONData = Data("any invalid data".utf8)
        
        XCTAssertThrowsError(
            try FeedResponseMapper.map(invalidJSONData, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_delivers_no_items_on_200_HTTPResponse_with_empty_json_list() throws {
        let (model, json) = makeFeed(itemCount: 0)
        let data = makeJSONData(for: json)
        
        let output = try FeedResponseMapper.map(data, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(output, model)
    }
    
    func test_map_delivers_items_on_200_HTTPResponse_with_json_items() throws {
        let (model, json) = makeFeed(itemCount: 5)
        let data = makeJSONData(for: json)
        
        let output = try FeedResponseMapper.map(data, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(output, model)
    }
}

private extension FeedResponseMapperTests {
    
    func makeJSONData(for feed: [String: Any]) -> Data {
        let data = try! JSONSerialization.data(withJSONObject: feed)
        return data
    }
    
    func makeFeed(itemCount: Int = 5) -> (model: Feed, json: [String: Any]) {
        
        let items = (0..<itemCount).map(makeFeedItem(_:))
        
        let model = Feed(
            items: items.map(\.model)
        )
        
        let json = [
            "content": items.map(\.json)
        ]
        return (model, json)
    }
    
    func makeFeedItem(_ index: Int) -> (model: FeedItem, json: [String: Any]) {
        let ITEM_ID = UUID().uuidString
        let IMAGE_URL = "https://some-image-\(index).com"
        let USER_ID = UUID().uuidString
        let USER_NAME = "any name \(index)"
        let USER_ABOUT = "some text \(index)"
        let USER_IMAGE_URL = "https://some-user-image-\(index).com"
        let IS_LIKED = true
        let LIKES = 5
        let COMMENTS = 10
        let SHARES = 12
        
        let model = FeedItem(
            id: ITEM_ID,
            imageURL: makeURL(IMAGE_URL),
            user: FeedItem.User(id: USER_ID, name: USER_NAME, about: USER_ABOUT, imageURL: makeURL(USER_IMAGE_URL)),
            interactions: FeedItem.Interactions(isLiked: IS_LIKED, likes: LIKES, comments: COMMENTS, shares: SHARES)
        )
        
        let json = [
            "id": ITEM_ID,
            "imageURL": IMAGE_URL,
            "user": [
                "id": USER_ID,
                "name": USER_NAME,
                "about": USER_ABOUT,
                "imageURL": USER_IMAGE_URL
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
