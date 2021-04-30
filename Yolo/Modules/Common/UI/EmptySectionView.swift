//
//  EmptySectionView.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import UIKit

public final class EmptySectionView: UITableViewCell {
    
    private(set) public lazy var messageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline, weight: .light)
        label.textColor = #colorLiteral(red: 0.4941176471, green: 0.5568627451, blue: 0.6431372549, alpha: 1)
        label.textAlignment = .center
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 124),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor)
        ])
        
        return label
    }()
}
