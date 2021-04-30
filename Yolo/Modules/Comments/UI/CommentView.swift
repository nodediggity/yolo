//
//  CommentView.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import UIKit

public final class CommentView: UITableViewCell {
    
    private(set) public var userImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        [imageView.widthAnchor, imageView.heightAnchor].forEach { $0.constraint(equalToConstant: 48).isActive = true }
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        imageView.backgroundColor = .init(white: 0, alpha: 0.1)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private(set) public var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .headline, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private(set) public var bodyTextLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = #colorLiteral(red: 0.4941176471, green: 0.5568627451, blue: 0.6431372549, alpha: 1)
        label.font = .preferredFont(forTextStyle: .body, weight: .light)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private var seperatorLine: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(white: 0, alpha: 0.1)
        return view
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
}

private extension CommentView {
    func configureUI() {
        let vStack = UIStackView(arrangedSubviews: [
            nameLabel,
            bodyTextLabel
        ])
        vStack.axis = .vertical
        vStack.spacing = 0
        
        let hStack = UIStackView(arrangedSubviews: [userImageView, vStack])
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.spacing = 16
        hStack.alignment = .top
        
        contentView.addSubview(hStack)
        addSubview(seperatorLine)
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            contentView.bottomAnchor.constraint(equalTo: hStack.bottomAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: hStack.trailingAnchor, constant: 24),
            
            seperatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomAnchor.constraint(equalTo: seperatorLine.bottomAnchor),
            trailingAnchor.constraint(equalTo: seperatorLine.trailingAnchor),
            seperatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])

    }
}
