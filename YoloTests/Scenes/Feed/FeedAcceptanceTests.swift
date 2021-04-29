//
//  FeedAcceptanceTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import XCTest
@testable import Yolo

class FeedAcceptanceTests: XCTestCase {
    
    func test_on_launch_displays_remote_feed_when_user_has_connectivity() {
        let sut = launch(httpClient: .online(response))
        XCTAssertEqual(sut.numberOfRenderedFeedItems, 5)
        XCTAssertEqual(sut.renderedFeedCardUserImageData(at: 0), makeUserImageData())
        XCTAssertEqual(sut.renderedFeedCardBodyImageData(at: 0), makeCardImageData())

        XCTAssertEqual(sut.renderedFeedCardUserImageData(at: 1), makeUserImageData())
        XCTAssertEqual(sut.renderedFeedCardBodyImageData(at: 1), makeCardImageData())
    }
    
    func test_on_launch_with_no_connectivity_displays_empty_feed() {
        let sut = launch(httpClient: .offline)
        XCTAssertEqual(sut.numberOfRenderedFeedItems, 0)
    }
}

private extension FeedAcceptanceTests {
    func launch(httpClient: HTTPClientStub = .offline) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient)
        let window = UIWindow(frame: .zero)
        sut.configure(window: window)
        
        return sut.window?.rootViewController as! FeedViewController
    }
    
    func response(for request: URLRequest) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: request.url!), response)
    }
    
    func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "https://some-user-image-0.com", "https://some-user-image-1.com":
            return makeUserImageData()
        case "https://some-image-0.com", "https://some-image-1.com":
            return makeCardImageData()
        default:
            return makeFeedData(itemCount: 5)
        }
    }
    
    func makeCardImageData() -> Data {
        UIImage.makeImageData(withColor: .red)
    }
    
    func makeUserImageData() -> Data {
        UIImage.makeImageData(withColor: .blue)
    }
    
    func makeFeedData(itemCount: Int = 5) -> Data {
        try! JSONSerialization.data(withJSONObject: makeFeed(itemCount: itemCount))
    }
    
    func makeFeed(itemCount: Int = 5) -> [String: Any] {
        let items = (0..<itemCount).map(makeFeedItem(_:))
        return [
            "content": items
        ]
    }
    
    func makeFeedItem(_ index: Int) -> [String: Any] {
        let ITEM_ID = UUID().uuidString
        let IMAGE_URL = "https://some-image-\(index).com"
        let USER_ID = UUID().uuidString
        let USER_NAME = "any name \(index)"
        let USER_ABOUT = "some text \(index)"
        let USER_IMAGE_URL = "https://some-user-image-\(index).com"
        let LIKES = 5
        let COMMENTS = 10
        let SHARES = 12
        
        return [
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
    }
}

class HTTPClientStub: HTTPClient {
    
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    private let stub: (URLRequest) -> HTTPClient.Result
    
    init(stub: @escaping (URLRequest) -> HTTPClient.Result) {
        self.stub = stub
    }
    
    func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(stub(request))
        return Task()
    }
}

extension HTTPClientStub {
    static var offline: HTTPClientStub {
        HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
    }
    
    static func online(_ stub: @escaping (URLRequest) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        HTTPClientStub { request in .success(stub(request)) }
    }
}
