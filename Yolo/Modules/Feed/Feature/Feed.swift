//
//  Feed.swift
//  Yolo
//
//  Created by Gordon Smith on 28/04/2021.
//

import Foundation

public struct Feed: Hashable {
    public let items: [FeedItem]
    public init(items: [FeedItem]) {
        self.items = items
    }
}
