//
//  UIImage+TestHelpers.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    static func makeImageData(withColor color: UIColor) -> Data {
        make(withColor: color).pngData()!
    }
}
