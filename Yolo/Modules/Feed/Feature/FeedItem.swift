//
//  FeedItem.swift
//  Yolo
//
//  Created by Gordon Smith on 28/04/2021.
//

import Foundation

public struct FeedItem: Hashable {
    
    public let id: String
    public let imageURL: URL
    public let user: User
    public let interactions: Interactions
    
    public struct User: Hashable {
        public let id: String
        public let name: String
        public let about: String
        public let imageURL: URL
        public init(id: String, name: String, about: String, imageURL: URL) {
            self.id = id
            self.name = name
            self.about = about
            self.imageURL = imageURL
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
    
    public init(id: String, imageURL: URL, user: User, interactions: Interactions) {
        self.id = id
        self.imageURL = imageURL
        self.user = user
        self.interactions = interactions
    }
}
