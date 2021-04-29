//
//  CommentsResponseMapper.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import Foundation

public enum CommentsResponseMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Comment] {
        let decoder = JSONDecoder()        
        guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return root.asCommentsDTO
    }
}

private extension CommentsResponseMapper {
    static var OK_200: Int { 200 }
    
    static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == OK_200
    }
    
    struct Root: Decodable {
        let content: Content
        
        struct Content: Decodable {
            let comments: [Comment]
            
            struct Comment: Decodable {
                let id: String
                let text: String
                let user: User
                
                struct User: Decodable {
                    let id: String
                    let name: String
                    let imageURL: URL
                }
            }
        }
        
        var asCommentsDTO: [Comment] {
            content.comments.map { comment in
                Comment(
                    id: comment.id,
                    text: comment.text,
                    user: Comment.User(id: comment.user.id, name: comment.user.name, imageURL: comment.user.imageURL)
                )
            }
        }
    }
}
