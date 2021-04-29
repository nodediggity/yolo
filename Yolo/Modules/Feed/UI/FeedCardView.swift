//
//  FeedCardView.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public final class FeedCardView: UITableViewCell {
    
    private(set) public var nameLabel = UILabel(frame: .zero)
    private(set) public var aboutLabel = UILabel(frame: .zero)
    private(set) public var likesCountLabel = UILabel(frame: .zero)
    private(set) public var commentsCountLabel = UILabel(frame: .zero)
    private(set) public var sharesCountLabel = UILabel(frame: .zero)

    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
}
