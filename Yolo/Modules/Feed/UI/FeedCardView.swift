//
//  FeedCardView.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public final class FeedCardView: UITableViewCell {
    
    private(set) public var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .title2, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
        
    private(set) public var aboutLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private(set) public var optionsButton: UIButton = {
        let image = UIImage(named: "action_icon")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .system)
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(image, for: .normal)
        button.tintColor = #colorLiteral(red: 0.4941176471, green: 0.5568627451, blue: 0.6431372549, alpha: 1)
        return button
    }()
    
    private(set) public var imageViewContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(white: 0, alpha: 0.1)
        view.heightAnchor.constraint(equalToConstant: 184).isActive = true
        view.layer.cornerRadius = 12
        return view
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

private extension FeedCardView {
    func configureUI() {
        
        // Header
        let headerVStack = UIStackView(
            arrangedSubviews: [nameLabel, aboutLabel]
        )
        headerVStack.axis = .vertical
        
        let optionButtonContainer = optionsButton.makeContainer()
        optionButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let headerHStack = UIStackView(
            arrangedSubviews: [headerVStack, optionButtonContainer]
        )
        headerHStack.alignment = .center
        headerHStack.axis = .horizontal
        headerHStack.spacing = 8
        
        // Footer
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
            headerHStack,
            imageViewContainer,
            footerHStack
        ])
        
        container.setCustomSpacing(24, after: imageViewContainer)
        container.axis = .vertical
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        
        let bottomAnchorConstraint = contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 16)
        bottomAnchorConstraint.priority = .defaultLow
        bottomAnchorConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            optionButtonContainer.widthAnchor.constraint(equalToConstant: 6),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            contentView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 24)
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
        label.font = .preferredFont(forTextStyle: .subheadline, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return label
    }
}

extension UIFont {
    static func preferredFont(forTextStyle style: TextStyle, weight: Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
}

extension UIView {
    
    public func makeContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            topAnchor.constraint(equalTo: container.topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        return container
    }
    
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
