//
//  InteractionResposneMapper.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import Foundation

public enum InteractionResposneMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Interactions{
        let decoder = JSONDecoder()
        guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return root.asInteractionsDTO
    }
}

private extension InteractionResposneMapper {
    static var OK_200: Int { 200 }
    
    static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == OK_200
    }
    
    struct Root: Decodable {
        let content: RemoteContent

        struct RemoteContent: Decodable {
            let isLiked: Bool
            let likes: Int
            let comments: Int
            let shares: Int
        }
        
        var asInteractionsDTO: Interactions {
            Interactions(isLiked: content.isLiked, likes: content.likes, comments: content.comments, shares: content.shares)
        }
    }
}
