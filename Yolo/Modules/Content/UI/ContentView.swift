//
//  ContentView.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import UIKit

public final class ContentView: UITableViewCell {
    
    public var onToggleLikeAction: (() -> Void)?
    
    private(set) public var imageViewContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(white: 0, alpha: 0.1)
        view.heightAnchor.constraint(equalToConstant: 400).isActive = true
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private(set) public var contentImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private(set) public lazy var likeButton: UIButton = {
        makeInteractionButton(image: "like_icon")
    }()
    
    private(set) public lazy var likesCountLabel: UILabel = {
        makeInteractionCountLabel()
    }()
    
    private(set) public lazy var commentsButton: UIButton = {
        makeInteractionButton(image: "comment_icon")
    }()
    
    private(set) public lazy var commentsCountLabel: UILabel = {
        makeInteractionCountLabel()
    }()
    
    private(set) public lazy var shareButton: UIButton = {
        makeInteractionButton(image: "share_icon")
    }()
    
    private(set) public lazy var sharesCountLabel: UILabel = {
        makeInteractionCountLabel()
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
    
}

private extension ContentView {
    func configureUI() {
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)

        let footerHStack = UIStackView(arrangedSubviews: [
            likeButton.makeContainer(),
            likesCountLabel,
            commentsButton.makeContainer(),
            commentsCountLabel,
            shareButton.makeContainer(),
            sharesCountLabel,
            UIView()
        ])
        footerHStack.axis = .horizontal
        footerHStack.spacing = 12
        footerHStack.alignment = .center
        
        // Container
        let container = UIStackView(arrangedSubviews: [
            imageViewContainer,
            footerHStack
        ])
        
        container.setCustomSpacing(24, after: imageViewContainer)
        container.axis = .vertical
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        imageViewContainer.addSubview(contentImageView)
        
        let bottomAnchorConstraint = contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 16)
        bottomAnchorConstraint.priority = .defaultLow
        bottomAnchorConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            contentView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 24),
            contentImageView.topAnchor.constraint(equalTo: imageViewContainer.topAnchor),
            contentImageView.leadingAnchor.constraint(equalTo: imageViewContainer.leadingAnchor),
            imageViewContainer.bottomAnchor.constraint(equalTo: contentImageView.bottomAnchor),
            imageViewContainer.trailingAnchor.constraint(equalTo: contentImageView.trailingAnchor)
        ])
    }
    
    func makeInteractionButton(image: String) -> UIButton {
        let image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(image, for: .normal)
        button.tintColor = #colorLiteral(red: 0.4941176471, green: 0.5568627451, blue: 0.6431372549, alpha: 1)
        [button.heightAnchor, button.widthAnchor].forEach { $0.constraint(equalToConstant: 24).isActive = true }
        return button
    }
    
    func makeInteractionCountLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.4941176471, green: 0.5568627451, blue: 0.6431372549, alpha: 1)
        label.font = .preferredFont(forTextStyle: .subheadline, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        label.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return label
    }
    
    @objc func likeButtonTapped() {
        onToggleLikeAction?()
    }
}
