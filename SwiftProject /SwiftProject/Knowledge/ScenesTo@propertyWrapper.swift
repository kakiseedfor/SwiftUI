//
//  ScenesTo@propertyWrapper.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/28.
//

import Foundation

@propertyWrapper struct TypeWrapper<T> {
    var value: T!
    var wrappedValue: T {
        get { value }
        set {
            if type(of: newValue) == Int?.self {
                value = (newValue as? Int ?? 0) as? T
            } else if type(of: newValue) == Float?.self {
                value = (newValue as? Float ?? 0.0) as? T
            } else if type(of: newValue) == Bool?.self {
                value = (newValue as? Bool ?? false) as? T
            } else if type(of: newValue) == String?.self {
                value = (newValue as? String ?? "") as? T
            } else {
                value = newValue
            }
        }
    }
    
    init(wrappedValue value: T) {
        wrappedValue = value
    }
}
