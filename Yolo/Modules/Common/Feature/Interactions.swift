//
//  Interactions.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import Foundation

public struct Interactions: Hashable {
    public let isLiked: Bool
    public let likes: Int
    public let comments: Int
    public let shares: Int
    public init(isLiked: Bool, likes: Int, comments: Int, shares: Int) {
        self.isLiked = isLiked
        self.likes = likes
        self.comments = comments
        self.shares = shares
    }
}
