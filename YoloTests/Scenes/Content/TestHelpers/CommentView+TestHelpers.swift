//
//  CommentView+TestHelpers.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import UIKit
import Yolo

extension CommentView {
    
    var renderedImage: Data? {
        userImageView.image?.pngData()
    }
    
    var nameText: String? {
        nameLabel.text
    }
    
    var bodyText: String? {
        bodyTextLabel.text
    }
}
