//
//  CommentPresenter.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import Foundation

public struct CommentViewModel: Equatable {
    public let name: String
    public let text: String
    public init(name: String, text: String) {
        self.name = name
        self.text = text
    }
}

public enum CommentPresenter {
    
    public static func map(_ item: Comment) -> CommentViewModel {
        CommentViewModel(name: item.user.name, text: item.text)
    }
}
