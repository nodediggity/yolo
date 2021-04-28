//
//  FeedResponseMapperTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 28/04/2021.
//

import XCTest
import Yolo

enum FeedResponseMapper {
    enum Error: Swift.Error {
        case invalidData
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> Feed {
        let decoder = JSONDecoder()
        guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return root.asFeedDTO
    }
}

private extension FeedResponseMapper {
    static var OK_200: Int { 200 }
    
    static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == OK_200
    }
    
    struct Root: Decodable {
        let content: [Content]
                
        struct Content: Decodable {
            let id: String
            let imageURL: URL
            let user: User
            let interactions: Interactions
            
            struct User: Decodable {
                let id: String
                let name: String
                let about: String
                let imageURL: URL
            }
            
            struct Interactions: Decodable {
                let likes: Int
                let comments: Int
                let shares: Int
            }
        }
        
        var asFeedDTO: Feed {
            Feed(
                items: content.map { item in
                    FeedItem(
                        id: item.id,
                        imageURL: item.imageURL,
                        user: .init(id: item.user.id, name: item.user.name, about: item.user.about, imageURL: item.user.imageURL),
                        interactions: .init(likes: item.interactions.likes, comments: item.interactions.comments, shares: item.interactions.shares)
                    )
                }
            )
        }
    }
}

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
        let LIKES = 5
        let COMMENTS = 10
        let SHARES = 12
        
        let model = FeedItem(
            id: ITEM_ID,
            imageURL: makeURL(IMAGE_URL),
            user: FeedItem.User(id: USER_ID, name: USER_NAME, about: USER_ABOUT, imageURL: makeURL(USER_IMAGE_URL)),
            interactions: FeedItem.Interactions(likes: LIKES, comments: COMMENTS, shares: SHARES)
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
                "likes": LIKES,
                "comments": COMMENTS,
                "shares": SHARES
            ]
        ] as [String : Any]
        
        return (model, json)
    }
}
