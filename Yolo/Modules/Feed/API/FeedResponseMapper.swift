//
//  FeedResponseMapper.swift
//  Yolo
//
//  Created by Gordon Smith on 28/04/2021.
//

import Foundation

public enum FeedResponseMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Feed {
        let decoder = JSONDecoder()
        guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return root.asFeedDTO
    }
}

private extension FeedResponseMapper {
    static var OK_200: Int { 200 }
    
    static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == OK_200
    }
    
    struct Root: Decodable {
        let content: [Content]
        
        struct Content: Decodable {
            let id: String
            let imageURL: URL
            let user: User
            let interactions: Interactions
            
            struct User: Decodable {
                let id: String
                let name: String
                let about: String
                let imageURL: URL
            }
            
            struct Interactions: Decodable {
                let isLiked: Bool
                let likes: Int
                let comments: Int
                let shares: Int
            }
        }
        
        var asFeedDTO: Feed {
            Feed(
                items: content.map { item in
                    FeedItem(
                        id: item.id,
                        imageURL: item.imageURL,
                        user: .init(
                            id: item.user.id,
                            name: item.user.name,
                            about: item.user.about,
                            imageURL: item.user.imageURL
                        ),
                        interactions: .init(
                            isLiked: item.interactions.isLiked,
                            likes: item.interactions.likes,
                            comments: item.interactions.comments,
                            shares: item.interactions.shares
                        )
                    )
                }
            )
        }
    }
}
