//
//  FeedCardPresenter.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import Foundation

public struct FeedCardViewModel {
    public let name: String
    public let about: String
    public let isLiked: Bool
    public let likes: String
    public let comments: String
    public let shares: String
}

public enum FeedCardPresenter {
    
    public static func map(_ item: FeedItem) -> FeedCardViewModel {
        FeedCardViewModel(
            name: item.user.name,
            about: item.user.about,
            isLiked: item.interactions.isLiked,
            likes: "\(item.interactions.likes)",
            comments: "\(item.interactions.comments)",
            shares: "\(item.interactions.shares)"
        )
    }
}
