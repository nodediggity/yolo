//
//  Memoize.swift
//  Yolo
//
//  Created by Gordon Smith on 27/07/2021.
//

import Foundation

func memoize<T: Hashable, U>(_ fn: @escaping (T) -> U) -> (T) -> U {
    var memo = Dictionary<T, U>()
    
    func result(selector: T) -> U {
        if let q = memo[selector] { return q }
        let r = fn(selector)
        memo[selector] = r
        return r
    }
    
    return result
}
