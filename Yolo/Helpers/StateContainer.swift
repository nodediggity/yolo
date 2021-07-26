//
//  StateContainer.swift
//  Yolo
//
//  Created by Gordon Smith on 26/07/2021.
//

import Foundation
import Combine

public protocol Event { }

public typealias StateMapper<T> = (_ state: T?, _ event: Event) -> T

typealias Store = StateContainer<AppState>

public final class StateContainer<T> {
    private(set) public var state: CurrentValueSubject<T, Never>
    private let mapper: StateMapper<T>
    
    public init(state: T?, mapper: @escaping StateMapper<T>) {
        if let state = state {
            self.state = .init(state)
        } else {
            self.state = .init(mapper(nil, StateInit()))
        }
        self.mapper = mapper
    }
    
    public func dispatch(_ event: Event) {
        let next = mapper(state.value, event)
        state.send(next)
    }
}

private extension StateContainer {
    struct StateInit: Event { }
}

public struct AppState: Equatable {
    public init() { }
}

public let rootMapper: StateMapper<AppState> = { state, event in
    var state = state ?? AppState()
    
    return state
}

struct FeedLoadedEvent: Event {
    let payload: [FeedItem]
}
