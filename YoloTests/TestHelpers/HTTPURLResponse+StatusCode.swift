//
//  HTTPURLResponse+StatusCode.swift
//  YoloTests
//
//  Created by Gordon Smith on 28/04/2021.
//

import Foundation

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: URL(string: "https://any-url.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
