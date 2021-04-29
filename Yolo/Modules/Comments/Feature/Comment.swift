//
//  Comment.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import Foundation

public struct Comment: Hashable {
    public let id: String
    public let text: String
    public let user: User
    
    public struct User: Hashable {
        public let id: String
        public let name: String
        public let imageURL: URL
        public init(id: String, name: String, imageURL: URL) {
            self.id = id
            self.name = name
            self.imageURL = imageURL
        }
    }
    
    public init(id: String, text: String, user: User) {
        self.id = id
        self.text = text
        self.user = user
    }
}
