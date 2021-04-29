//
//  UIImage+Size.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
