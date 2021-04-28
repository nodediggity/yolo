//
//  HTTPClient.swift
//  Yolo
//
//  Created by Gordon Smith on 28/04/2021.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(data: Data, response: HTTPURLResponse), Error>

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
