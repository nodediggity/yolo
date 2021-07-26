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
        
        let view0 = sut.simulateFeedCardVisible(at: 0)
        
        XCTAssertEqual(view0?.renderedImageForUser, makeUserImageData())
        XCTAssertEqual(view0?.renderedImageForCard, makeCardImageData())
        
        let view1 = sut.simulateFeedCardVisible(at: 1)
        XCTAssertEqual(view1?.renderedImageForUser, makeUserImageData())
        XCTAssertEqual(view1?.renderedImageForCard, makeCardImageData())

    }
    
    func test_on_launch_with_no_connectivity_displays_empty_feed() {
        let sut = launch(httpClient: .offline)
        XCTAssertEqual(sut.numberOfRenderedFeedItems, 0)
    }
    
    func test_on_select_content_action_routes_to_content_scene() {
        let sut = launch(httpClient: .online(response))
        
        sut.simulateFeedCardSelection(at: 0)
        RunLoop.current.run(until: Date())
        
        let content = sut.navigationController?.topViewController as! ListViewController
        XCTAssertEqual(content.numberOfRenderedComments, 2)
        
        let view = content.contentView() as? ContentView
        XCTAssertEqual(view?.renderedImage, makeCardImageData())
    }
    
    func test_on_feed_load_success_dispatches_event_to_store() {
        var output: [FeedLoadedEvent] = []
        let sut = launch(httpClient: .online(response), store: Store(state: .init(), mapper: { state, event in
            if let event = event as? FeedLoadedEvent {
                output.append(event)
            } else {
                XCTFail("Expected `FeedLoadedEvent` but got \(type(of: event)) instead")
            }
           return state!
        }))
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(output.isEmpty)
    }
}

private extension FeedAcceptanceTests {
    func launch(httpClient: HTTPClientStub = .offline, store: Store = Store(state: nil, mapper: { _, _ in AppState() })) -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        let window = UIWindow(frame: .zero)
        sut.configure(window: window)
        
        let nav = sut.window?.rootViewController as! UINavigationController
        return nav.topViewController as! ListViewController
    }
    
    func response(for request: URLRequest) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: request.url!), response)
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
    
    func makeContentData() -> Data {
        try! JSONSerialization.data(withJSONObject: ["content": makeContent()])
    }
    
    func makeCommentsData() -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "content": [
                "comments": [makeComment(0), makeComment(1)]
            ]
        ])
    }
    
    func makeData(for url: URL) -> Data {
        switch url.path {
        case "/user-image-0", "/user-image-1":
            return makeUserImageData()
        case "/card-image-0", "/card-image-1":
            return makeCardImageData()
        case "/feed":
            return makeFeedData(itemCount: 5)
        case "/content/item-0":
            return makeContentData()
        case "/comments/item-0":
            return makeCommentsData()
        default: return makeData()
        }
    }
    
    func makeFeed(itemCount: Int = 5) -> [String: Any] {
        let items = (0..<itemCount).map(makeFeedItem(_:))
        return [
            "content": items
        ]
    }
    
    func makeFeedItem(_ index: Int) -> [String: Any] {
        let ITEM_ID = "item-\(index)"
        let IMAGE_URL = "https://some-card-image.com/card-image-\(index)"
        let USER_ID = UUID().uuidString
        let USER_NAME = "any name \(index)"
        let USER_ABOUT = "some text \(index)"
        let USER_IMAGE_URL = "https://some-user-image.com/user-image-\(index)"
        let IS_LIKED = true
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
                "isLiked": IS_LIKED,
                "likes": LIKES,
                "comments": COMMENTS,
                "shares": SHARES
            ]
        ] as [String : Any]
    }

    func makeContent() -> [String: Any] {
        let ITEM_ID = UUID().uuidString
        let IMAGE_URL = "https://some-card-image.com/card-image-0"
        let USER_ID = UUID().uuidString
        let IS_LIKED = true
        let LIKES = 5
        let COMMENTS = 10
        let SHARES = 12
    
        return [
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
    }
    
    func makeComment(_ index: Int) -> [String: Any] {
        let COMMENT_ID = UUID().uuidString
        let COMMENT_TEXT = "comment #\(index)"
        let USER_ID = UUID().uuidString
        let USER_NAME = "any name \(index)"
        let USER_IMAGE_URL = "https://some-user-image.com/user-image-\(index)"

        return [
            "id": COMMENT_ID,
            "text": COMMENT_TEXT,
            "user": [
                "id": USER_ID,
                "name": USER_NAME,
                "imageURL": USER_IMAGE_URL
            ]
        ] as [String : Any]
    }
}
