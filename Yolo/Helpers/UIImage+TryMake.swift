//
//  UIImage+TryMake.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public extension UIImage {
    struct InvalidImageData: Error {}
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}
