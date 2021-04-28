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

    static func map(_ data: Data, from response: HTTPURLResponse) throws  {
        let decoder = JSONDecoder()
        guard isOK(response), let _ = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
    }
}

private extension FeedResponseMapper {
    static var OK_200: Int { 200 }

    static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == OK_200
    }
    
    struct Root: Decodable { }
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
}

private extension FeedResponseMapperTests {
    
    func makeJSONData(for feed: [String: Any]) -> Data {
        let data = try! JSONSerialization.data(withJSONObject: feed)
        return data
    }
}
