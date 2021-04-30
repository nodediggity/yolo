//
//  FeedCardView+TestHelpers.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit
import Yolo

extension FeedCardView {
    
    var renderedImageForUser: Data? {
        userImageView.image?.pngData()
    }
    
    var renderedImageForCard: Data? {
        cardImageView.image?.pngData()
    }
    
    var nameText: String? {
        nameLabel.text
    }
    
    var aboutText: String? {
        aboutLabel.text
    }
    
    var likesText: String? {
        likesCountLabel.text
    }
    
    var commentsText: String? {
        commentsCountLabel.text
    }
    
    var sharesText: String? {
        sharesCountLabel.text
    }
    
    var isShowingAsLiked: Bool {
        likeButton.tintColor == .red
    }
}

