//
//  Interactions+Toggle.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import Foundation

extension Interactions {
    func asUnliked() -> Self {
        Interactions(isLiked: false, likes: likes - 1, comments: comments, shares: shares)
    }

    func asLiked() -> Self {
        Interactions(isLiked: true, likes: likes + 1, comments: comments, shares: shares)
    }
}
