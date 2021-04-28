//
//  URLSessionHTTPClientTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 28/04/2021.
//

import XCTest
import Yolo

class URLSessionHTTPClientTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.removeStub()
    }

    func test_dispatch_fails_on_request_error() {
        let error = makeError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: error)
        XCTAssertNotNil(receivedError)
    }

    func test_dispatch_fails_on_all_nil_response_values() {
        let receivedError = resultErrorFor(data: nil, response: nil, error: nil)
        XCTAssertNotNil(receivedError)
    }

    func test_dispatch_performs_request_with_given_object() {
        let requestID = UUID().uuidString
        let exp = expectation(description: "await completion")
        let sut = makeSUT()
        let requestURL = makeURL()
        var request = URLRequest(url: requestURL)
        request.addValue(requestID, forHTTPHeaderField: "REQUEST_ID")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, requestURL)
            XCTAssertEqual(request.value(forHTTPHeaderField: "REQUEST_ID"), requestID)
            exp.fulfill()
        }

        _ = sut.dispatch(request, completion: { _ in })

        wait(for: [exp], timeout: 0.1)
    }

    func test_dispatch_fails_on_invalid_representation_cases() {
        /*
         These cases should *never* happen, however as `URLSession` represents these fields as optional
         it is possible in some obscure way that this state _could_ exist.
         | Data?    | URLResponse?      | Error?   |
         |----------|-------------------|----------|
         | nil      | nil               | nil      |
         | nil      | URLResponse       | nil      |
         | value    | nil               | nil      |
         | value    | nil               | value    |
         | nil      | URLResponse       | value    |
         | nil      | HTTPURLResponse   | value    |
         | value    | HTTPURLResponse   | value    |
         | value    | URLResponse       | nil      |
         */

        let nonHTTPURLResponse = URLResponse(url: makeURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let httpResponse = HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = makeData()
        let error = makeError()

        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: data, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: data, response: nil, error: error))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: error))
        XCTAssertNotNil(resultErrorFor(data: nil, response: httpResponse, error: error))
        XCTAssertNotNil(resultErrorFor(data: data, response: nonHTTPURLResponse, error: error))
        XCTAssertNotNil(resultErrorFor(data: data, response: httpResponse, error: error))
        XCTAssertNotNil(resultErrorFor(data: data, response: nonHTTPURLResponse, error: nil))
    }

    func test_dispatch_succeeds_on_http_url_response_with_data() {
        let data = makeData()
        let httpResponse = HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let output = resultValuesFor(data: data, response: httpResponse, error: nil)

        XCTAssertEqual(output?.data, data)
        XCTAssertEqual(output?.response.url, httpResponse?.url)
        XCTAssertEqual(output?.response.statusCode, httpResponse?.statusCode)
    }

    func test_dispatch_succeeds_with_empty_data_on_http_url_response_with_nil_data() {
        let emptyData = makeData()
        let httpResponse = HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let output = resultValuesFor(data: nil, response: httpResponse, error: nil)

        XCTAssertEqual(output?.data, emptyData)
        XCTAssertEqual(output?.response.url, httpResponse?.url)
        XCTAssertEqual(output?.response.statusCode, httpResponse?.statusCode)
    }

    func test_cancel_task_cancels_pending_request() {
        let sut = makeSUT()
        let exp = expectation(description: "await completion")

        let task = sut.dispatch(URLRequest(url: makeURL()), completion: { result in
            switch result {
            case let .failure(error as NSError) where error.code == URLError.cancelled.rawValue: break
            default: XCTFail("Expected cancelled result, got \(result) instead")
            }
            exp.fulfill()
        })

        task.cancel()
        wait(for: [exp], timeout: 0.1)
    }
}

private extension URLSessionHTTPClientTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)

        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        var receivedError: Error?
        let exp = expectation(description: "await completion")
        let sut = makeSUT(file: file, line: line)

        _ = sut.dispatch(URLRequest(url: makeURL()), completion: { result in
            switch result {
            case let .failure(error): receivedError = error
            default: XCTFail("Expected failure but got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        })

        wait(for: [exp], timeout: 1)
        return receivedError
    }

    func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        var receivedValues: (Data, HTTPURLResponse)?
        let exp = expectation(description: "await completion")
        let sut = makeSUT(file: file, line: line)

        _ = sut.dispatch(URLRequest(url: makeURL()), completion: { result in
            switch result {
            case let .success(values): receivedValues = values
            default: XCTFail("Expected success but got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        })

        wait(for: [exp], timeout: 0.1)
        return receivedValues
    }
}
