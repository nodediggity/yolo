//
//  Content.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import Foundation

public struct Content: Hashable {
    
    public let id: String
    public let imageURL: URL
    public let user: User
    public let interactions: Interactions
    
    public init(id: String, imageURL: URL, user: User, interactions: Interactions) {
        self.id = id
        self.imageURL = imageURL
        self.user = user
        self.interactions = interactions
    }
}

extension Content {
    
    public struct User: Hashable {
        public let id: String
        public init(id: String) {
            self.id = id
        }
    }
    
    public struct Interactions: Hashable {
        public let likes: Int
        public let comments: Int
        public let shares: Int
        public init(likes: Int, comments: Int, shares: Int) {
            self.likes = likes
            self.comments = comments
            self.shares = shares
        }
    }
}
