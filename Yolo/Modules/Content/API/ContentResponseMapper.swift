//
//  ContentResponseMapper.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import Foundation

public enum ContentResponseMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Content {
        let decoder = JSONDecoder()
        guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return root.asContentDTO
    }
}

private extension ContentResponseMapper {
    static var OK_200: Int { 200 }
    
    static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == OK_200
    }
    
    struct Root: Decodable {
        let content: RemoteContent
        
        struct RemoteContent: Decodable {
            let id: String
            let imageURL: URL
            let user: User
            let interactions: Interactions
            
            struct User: Decodable {
                let id: String
            }
            
            struct Interactions: Decodable {
                let isLiked: Bool
                let likes: Int
                let comments: Int
                let shares: Int
            }
        }
        
        var asContentDTO: Content {
            Content(
                id: content.id,
                imageURL: content.imageURL,
                user: Content.User(id: content.user.id),
                interactions: Interactions(
                    isLiked: content.interactions.isLiked,
                    likes: content.interactions.likes,
                    comments: content.interactions.comments,
                    shares: content.interactions.shares
                )
            )
        }
    }
}

