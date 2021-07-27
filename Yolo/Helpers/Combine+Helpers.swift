//
//  Combine+Helpers.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import Foundation
import Combine

extension HTTPClient {
    typealias Publisher = AnyPublisher<(data: Data, response: HTTPURLResponse), Error>

    func dispatchPublisher(for request: URLRequest) -> Publisher {
        var task: HTTPClientTask?

        return Deferred {
            Future { completion in
                task = self.dispatch(request, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func select(from store: Store, using selector: @escaping (AppState) -> Output) -> AnyPublisher<Output, Failure> {
        flatMap { _ in store.state.map(selector).setFailureType(to: Failure.self) }.eraseToAnyPublisher()
    }
}
