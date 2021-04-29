//
//  ImageResponseMapperTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import XCTest
import Yolo

class ImageResponseMapperTests: XCTestCase {
    func test_map_throws_error_on_non_200_HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageResponseMapper.map(makeData(), from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_delivers_invalid_data_error_on_200_HTTPResponse_with_empty_data() {
        let emptyData = makeData()
        XCTAssertThrowsError(
            try ImageResponseMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200))
        )
    }

    func test_map_delivers_receive_non_empty_data_on_200_HTTPResponse() throws {
        let nonEmptyData = makeData("non-empty data")
        let result = try ImageResponseMapper.map(nonEmptyData, from: HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, nonEmptyData)
    }
}
