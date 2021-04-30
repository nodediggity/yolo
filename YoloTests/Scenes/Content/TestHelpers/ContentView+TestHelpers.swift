//
//  ContentView+TestHelpers.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import UIKit
import Yolo

extension ContentView {

    var renderedImage: Data? {
        contentImageView.image?.pngData()
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
    
    func simulateToggleLikeAction() {
        likeButton.simulateTap()
    }
}
