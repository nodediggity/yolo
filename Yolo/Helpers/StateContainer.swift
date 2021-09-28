//
//  StateContainer.swift
//  Yolo
//
//  Created by Gordon Smith on 26/07/2021.
//

import Foundation
import Combine
import OrderedCollections

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

public struct AppState: Hashable {
    let feed: FeedState
    public init(feed: FeedState = .init()) {
        self.feed = feed
    }
}

public let rootMapper: StateMapper<AppState> = { state, event in
    AppState(
        feed: feedMapper(state?.feed, event)
    )
}

public struct FeedLoadedEvent: Event {
    public let payload: [FeedItem]
    public init(payload: [FeedItem]) {
        self.payload = payload
    }
}

public struct FeedState: Hashable {
    public var items: OrderedDictionary<String, FeedItem>
    public init(items: OrderedDictionary<String, FeedItem> = [:]) {
        self.items = items
    }
}

public let feedMapper: StateMapper<FeedState> = { state, event in
    var state = state ?? FeedState()
    
    if let event = event as? FeedLoadedEvent {
        event.payload.forEach { item in
            state.items[item.id] = item
        }
        return state
    }
    
    if let event = event as? LikeInteractionEvent, let item = state.items[event.payload.id] {
        state.items[event.payload.id] = event.payload.isLiked ? item.cloneAsLiked() : item.cloneAsUnliked()
        return state
    }
    
    return state
}

public let stateSelector = { (state: AppState) in state }
public let feedSelector = createSelector(selector1: stateSelector, { state -> [FeedItem] in
    let feed = state.feed
    return feed.items.reduce([FeedItem]()) { acc, e in
        var acc = acc
        acc.append(e.value)
        return acc
    }
})

public struct LikeInteractionEvent: Event {
    public let payload: (id: String, isLiked: Bool)
    public init(payload: (id: String, isLiked: Bool)) {
        self.payload = payload
    }
}
