//
//  InteractionResposneMapperTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import XCTest
import Yolo

class InteractionResposneMapperTests: XCTestCase {
    
    func test_map_throws_error_on_non_200_HTTPResponse() throws {
        let data = makeJSONData(for: [:])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try InteractionResposneMapper.map(data, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throws_error_on_200_HTTPResponse_with_invalid_json() {
        let invalidJSONData = Data("any invalid data".utf8)
        
        XCTAssertThrowsError(
            try InteractionResposneMapper.map(invalidJSONData, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_delivers_items_on_200_HTTPResponse_with_json_items() throws {
        let (model, json) = makeInteractions()
        let data = makeJSONData(for: json)
        
        let output = try InteractionResposneMapper.map(data, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(output, model)
    }
}

private extension InteractionResposneMapperTests {
    
    func makeJSONData(for interactions: [String: Any]) -> Data {
        let data = try! JSONSerialization.data(withJSONObject: [
            "content": interactions
        ])
        return data
    }
    
    
    func makeInteractions() -> (model: Interactions, json: [String: Any]) {
        let IS_LIKED = true
        let LIKES = 5
        let COMMENTS = 10
        let SHARES = 12
        
        let model = Interactions(isLiked: IS_LIKED, likes: LIKES, comments: COMMENTS, shares: SHARES)
        
        let json = [
            "isLiked": IS_LIKED,
            "likes": LIKES,
            "comments": COMMENTS,
            "shares": SHARES
        ] as [String : Any]
        
        return (model, json)
    }
}
