//
//  XCTestCase+URL.swift
//  YoloTests
//
//  Created by Gordon Smith on 28/04/2021.
//

import XCTest

extension XCTestCase {
    func makeURL(_ str: String = "https://any-given-url.com") -> URL {
        URL(string: str)!
    }
}
