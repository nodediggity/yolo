//
//  ImageResponseMapper.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import Foundation

public enum ImageResponseMapper {
    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard isOK(response), !data.isEmpty else {
            throw Error.invalidData
        }

        return data
    }
}

private extension ImageResponseMapper {
    static var OK_200: Int { 200 }

    static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == OK_200
    }
}
